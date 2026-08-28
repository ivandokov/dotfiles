#!/bin/bash
#
# Exclude dependency directories (node_modules, Composer vendor) under the
# project roots below from Time Machine backups.
#
# Uses the sticky per-item exclusion (the com.apple.metadata:com_apple_backup_excludeItem
# extended attribute), so no root privileges are needed and the exclusion
# travels with the directory if it moves.
#
# Notes on the approach:
#
#   1. No depth limit. Package level node_modules in a monorepo sit six or
#      seven levels down, so a shallow search finds almost nothing.
#   2. Directories that already carry the attribute are filtered out inside
#      find itself via -xattrname, so a run with nothing new to do does very
#      little work.
#   3. The attribute is written directly with xattr rather than via
#      "tmutil addexclusion". tmutil round-trips through backupd, which takes
#      roughly 11 seconds per call when the destination is a network share.
#      The direct write takes about 2 milliseconds and tmutil isexcluded
#      reports the result as excluded either way.
#   4. Not every directory named "vendor" is a dependency directory. Laravel
#      keeps hand edited template and translation overrides in
#      resources/views/vendor and resources/lang/vendor, and published package
#      assets in public/vendor. Those are source and must stay backed up, so a
#      vendor directory is only excluded when it actually looks like a
#      Composer install (it contains autoload.php or a composer subdirectory).
#   5. node_modules is pruned before vendor is considered, so vendor
#      directories nested inside node_modules are skipped as already covered
#      by their parent.

set -uo pipefail

ROOTS=(
  "$HOME/Code"
  "$HOME/.paseo"
  "$HOME/.t3"
)

XATTR="com.apple.metadata:com_apple_backup_excludeItem"
VALUE='<?xml version="1.0" encoding="UTF-8"?><plist version="1.0"><string>com.apple.backupd</string></plist>'
LOCKDIR="${TMPDIR:-/tmp}/tm-exclude-node-modules.lock"

# Never let two runs overlap.
if ! mkdir "$LOCKDIR" 2>/dev/null; then
  exit 0
fi
trap 'rmdir "$LOCKDIR" 2>/dev/null' EXIT

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*"; }

# A vendor directory counts as a dependency directory only if Composer put it
# there. Anything else named vendor is project source.
is_composer_vendor() {
  [ -e "$1/autoload.php" ] || [ -d "$1/composer" ]
}

total=0
failed=0

for root in "${ROOTS[@]}"; do
  [ -d "$root" ] || continue

  while IFS= read -r -d '' dir; do
    if [ "$(basename "$dir")" = vendor ] && ! is_composer_vendor "$dir"; then
      continue
    fi

    if xattr -w "$XATTR" "$VALUE" "$dir" 2>/dev/null; then
      total=$((total + 1))
      log "excluded: $dir"
    else
      failed=$((failed + 1))
      log "FAILED:   $dir" >&2
    fi
  done < <(find "$root" \( \
      -type d -name node_modules -prune ! -xattrname "$XATTR" -print0 \
      -o \
      -type d -name vendor       -prune ! -xattrname "$XATTR" -print0 \
    \) 2>/dev/null)
done

if [ "$total" -gt 0 ] || [ "$failed" -gt 0 ]; then
  log "done: $total newly excluded, $failed failed"
fi
