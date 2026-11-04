#!/bin/bash
#
# Keep ~/.dotfiles in step across machines.
#
# Pulls the latest commits, commits any local changes as a "sync from <host>"
# commit, and pushes. Runs every 15 minutes via the com.ivan.dotfiles-sync
# LaunchAgent, and on demand with `dot sync`.
#
# Rebase conflicts are left for a human: the script aborts the rebase, prints
# a message and exits non zero, and the next run tries again from a clean state.

set -u

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

# Sync commits are unsigned. Signing needs the SSH key unlocked in an agent,
# which a LaunchAgent cannot count on.
export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=commit.gpgsign GIT_CONFIG_VALUE_0=false
cd "$HOME/.dotfiles" || exit 1

# Another git process (an interactive rebase, a merge) is in progress.
if [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ] || [ -f .git/MERGE_HEAD ]; then
    echo "dotfiles-sync: repository busy, skipping"
    exit 0
fi

if ! git pull --rebase --autostash --quiet; then
    git rebase --abort 2>/dev/null
    echo "dotfiles-sync: pull failed (offline or conflict), will retry later"
    exit 1
fi

git add -A
if ! git diff --cached --quiet; then
    git commit --quiet -m "sync from $(hostname -s)"
fi

if [ -n "$(git log --oneline @{u}.. 2>/dev/null)" ]; then
    git push --quiet || { echo "dotfiles-sync: push failed, will retry later"; exit 1; }
fi
