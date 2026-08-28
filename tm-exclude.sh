#!/bin/bash
#
# Exclude regenerable and already-replicated data from Time Machine backups.
#
# Two kinds of rule:
#
#   NAME rules  scan the project roots for directories with a given name
#               (node_modules, Composer vendor) at any depth.
#   PATH rules  exclude a specific fixed location outright (caches, VM disk
#               images, cloud mirrors).
#
# Uses the sticky per-item exclusion (the com.apple.metadata:com_apple_backup_excludeItem
# extended attribute), so no root privileges are needed and the exclusion
# travels with the directory if it moves.
#
# Notes on the approach:
#
#   1. No depth limit on the name rules. Package level node_modules in a
#      monorepo sit six or seven levels down, so a shallow search finds almost
#      nothing.
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
#
# Anything listed here is either rebuilt on demand or held somewhere else.
# Nothing here is the only copy of anything.

set -uo pipefail

# Project roots scanned by the name rules. Missing roots are skipped, so the
# same list works on every machine.
ROOTS=(
  "$HOME/Code"
  "$HOME/.paseo"
  "$HOME/.t3"
)

# Fixed locations excluded outright. Missing paths are skipped.
PATHS=(
  # Apple aerial and dynamic wallpaper video, re-downloaded on demand.
  "$HOME/Library/Application Support/com.apple.wallpaper"
  "$HOME/Library/Containers/com.apple.wallpaper.extension.aerials"
  "$HOME/Library/Containers/com.apple.wallpaper.agent"

  # Docker's VM disk image. A single multi-gigabyte file rewritten on every
  # container run, so Time Machine recopies the whole thing each time.
  # Images are re-pullable. Named volumes live inside it, so anything kept
  # only in a volume is not backed up.
  "$HOME/Library/Containers/com.docker.docker"
  "$HOME/Library/Application Support/com.docker.install"

  # Package manager caches, refetched from the network.
  "$HOME/Library/pnpm/store"
  "$HOME/.npm"

  # Cloud mirrors. The authoritative copy is with the provider, and File
  # Provider mounts are awkward for Time Machine regardless.
  "$HOME/Library/CloudStorage"
)

XATTR="com.apple.metadata:com_apple_backup_excludeItem"
VALUE='<?xml version="1.0" encoding="UTF-8"?><plist version="1.0"><string>com.apple.backupd</string></plist>'
LOCKDIR="${TMPDIR:-/tmp}/tm-exclude.lock"

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

exclude() {
  local dir=$1
  if xattr -w "$XATTR" "$VALUE" "$dir" 2>/dev/null; then
    total=$((total + 1))
    log "excluded: $dir"
  else
    failed=$((failed + 1))
    log "FAILED:   $dir" >&2
  fi
}

# Name rules.
for root in "${ROOTS[@]}"; do
  [ -d "$root" ] || continue

  while IFS= read -r -d '' dir; do
    if [ "$(basename "$dir")" = vendor ] && ! is_composer_vendor "$dir"; then
      continue
    fi
    exclude "$dir"
  done < <(find "$root" \( \
      -type d -name node_modules -prune ! -xattrname "$XATTR" -print0 \
      -o \
      -type d -name vendor       -prune ! -xattrname "$XATTR" -print0 \
    \) 2>/dev/null)
done

# Path rules.
for path in "${PATHS[@]}"; do
  [ -e "$path" ] || continue
  xattr -p "$XATTR" "$path" >/dev/null 2>&1 && continue
  exclude "$path"
done

if [ "$total" -gt 0 ] || [ "$failed" -gt 0 ]; then
  log "done: $total newly excluded, $failed failed"
fi
