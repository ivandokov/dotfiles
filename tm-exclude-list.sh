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
#   tm-exclude-list.sh              scan all of $HOME, about 20 seconds
#   tm-exclude-list.sh -q           quick, only the project roots
#   tm-exclude-list.sh -s           add sizes and a total, slower
#   tm-exclude-list.sh PATH...      scan the given paths

set -uo pipefail

XATTR="com.apple.metadata:com_apple_backup_excludeItem"

PROJECT_ROOTS=(
  "$HOME/Code"
  "$HOME/.paseo"
  "$HOME/.t3"
)

show_sizes=0
roots=()

while [ $# -gt 0 ]; do
  case "$1" in
    -s) show_sizes=1 ;;
    -q) roots=("${PROJECT_ROOTS[@]}") ;;
    -a) roots=("$HOME") ;;
    -h|--help) sed -n '3,17p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)  roots+=("$1") ;;
  esac
  shift
done

[ ${#roots[@]} -gt 0 ] || roots=("$HOME")

echo "Fixed-path exclusions (these are what System Settings lists)"
paths=$(defaults read /Library/Preferences/com.apple.TimeMachine.plist SkipPaths 2>/dev/null)
if [ -n "$paths" ]; then
  echo "$paths" | sed 's/^/  /'
else
  echo "  none"
fi

echo
echo "Excluded volumes"
excluded_vols=$(defaults read /Library/Preferences/com.apple.TimeMachine.plist ExcludedVolumeUUIDs 2>/dev/null)
if [ -n "$excluded_vols" ]; then
  echo "$excluded_vols" | sed 's/^/  /'
else
  echo "  none"
fi

echo
echo "Sticky exclusions under: ${roots[*]}"

# -prune at each match so the topmost excluded item is reported and its
# contents are not walked. That is also what keeps a full $HOME scan quick,
# since the biggest directories are the excluded ones.
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
    | awk -F'\t' '{
        total += $1
        if ($1 >= 1048576) printf "  %8.1f GiB  %s\n", $1/1048576, $2
        else               printf "  %8.1f MiB  %s\n", $1/1024, $2
      }
      END { printf "\n  %d items, %.1f GiB total\n", NR, total/1048576 }'
else
  tr '\0' '\n' < "$tmpfile" | sort | sed 's/^/  /'
  echo
  echo "  $count items (pass -s for sizes)"
fi
