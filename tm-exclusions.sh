#!/bin/bash
#
# List Time Machine exclusions.
#
# The System Settings panel only lists fixed-path exclusions, the ones stored
# in Time Machine's own preferences and created with the + button or
# "tmutil addexclusion -p". Sticky exclusions live as an extended attribute on
# the item itself and never appear there, so the only way to see them is to
# scan the filesystem. That is what this script does.
#
# Usage:
#   tm-exclusions.sh              scan the usual project roots
#   tm-exclusions.sh -a           scan all of $HOME (slower)
#   tm-exclusions.sh PATH...      scan the given paths
#   tm-exclusions.sh -s ...       add sizes and a total (slower)

set -uo pipefail

XATTR="com.apple.metadata:com_apple_backup_excludeItem"

DEFAULT_ROOTS=(
  "$HOME/Code"
  "$HOME/.paseo"
  "$HOME/.t3"
)

show_sizes=0
roots=()

while [ $# -gt 0 ]; do
  case "$1" in
    -s) show_sizes=1 ;;
    -a) roots=("$HOME") ;;
    -h|--help) sed -n '3,16p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)  roots+=("$1") ;;
  esac
  shift
done

[ ${#roots[@]} -gt 0 ] || roots=("${DEFAULT_ROOTS[@]}")

echo "Fixed-path exclusions (these are what System Settings lists)"
paths=$(defaults read /Library/Preferences/com.apple.TimeMachine.plist SkipPaths 2>/dev/null)
if [ -n "$paths" ]; then
  echo "$paths" | sed 's/^/  /'
else
  echo "  none"
fi

echo
echo "Excluded volumes"
vols=$(tmutil destinationinfo 2>/dev/null | grep -i "^Name" | sed 's/^/  /')
excluded_vols=$(defaults read /Library/Preferences/com.apple.TimeMachine.plist ExcludedVolumeUUIDs 2>/dev/null)
if [ -n "$excluded_vols" ]; then
  echo "$excluded_vols" | sed 's/^/  /'
else
  echo "  none"
fi

echo
echo "Sticky exclusions under: ${roots[*]}"

# -prune at each match so the topmost excluded item is reported and its
# contents are not walked.
tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

for root in "${roots[@]}"; do
  [ -e "$root" ] || continue
  find "$root" -xattrname "$XATTR" -prune -print0 2>/dev/null >> "$tmpfile"
done

count=$(tr -dc '\0' < "$tmpfile" | wc -c | tr -d ' ')

if [ "$count" -eq 0 ]; then
  echo "  none"
  exit 0
fi

if [ "$show_sizes" -eq 1 ]; then
  xargs -0 du -sk < "$tmpfile" 2>/dev/null \
    | sort -rn \
    | awk '{
        size = $1
        $1 = ""
        sub(/^ /, "")
        total += size
        if (size >= 1048576) printf "  %8.1f GiB  %s\n", size/1048576, $0
        else                 printf "  %8.1f MiB  %s\n", size/1024, $0
      }
      END { printf "\n  %d items, %.1f GiB total\n", NR, total/1048576 }'
else
  xargs -0 -n 1 echo "  " < "$tmpfile" 2>/dev/null | sort
  echo
  echo "  $count items (pass -s for sizes)"
fi
