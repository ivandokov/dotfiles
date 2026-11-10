#!/usr/bin/env bash
#
# Usage: bin/push-ssh.sh <target>      e.g. bin/push-ssh.sh omarchy
#
# Copies the SSH identity to another machine of mine: the config, the known
# hosts, the key pairs, and the authorized_keys that lets the other machines in
# here. Private keys are involved, so this runs over an existing SSH connection
# and never through the dotfiles repository, which is public.
#
# The transfer goes through tar rather than rsync, which Arch does not install
# by default, and tar carries the file modes across unchanged.
#
# Safe to re-run. The target's existing ~/.ssh is copied aside on the first run.

set -euo pipefail

TARGET=${1:?usage: push-ssh.sh <target>}

KEYS=(ivan_2026 ivan_old miguide miguide-deploy)

FILES=(config known_hosts authorized_keys)
for key in "${KEYS[@]}"; do
    [ -f "$HOME/.ssh/$key" ] && FILES+=("$key")
    [ -f "$HOME/.ssh/$key.pub" ] && FILES+=("$key.pub")
done

echo "Sending to $TARGET:"
printf '  %s\n' "${FILES[@]}"
echo

ssh "$TARGET" '
    set -eu
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    if [ ! -d ~/.ssh.bak-before-push ] && [ -n "$(ls -A ~/.ssh 2>/dev/null)" ]; then
        cp -a ~/.ssh ~/.ssh.bak-before-push
        echo "Kept a copy of the old ~/.ssh in ~/.ssh.bak-before-push"
    fi
'

tar -C "$HOME/.ssh" -cf - "${FILES[@]}" \
    | ssh "$TARGET" 'tar -C ~/.ssh -xpf - && chmod 700 ~/.ssh && chmod go-rwx ~/.ssh/* && chmod 644 ~/.ssh/*.pub'

ssh "$TARGET" '
    set -eu
    echo
    echo "Identities now on $(uname -n):"
    for k in ~/.ssh/*; do
        case "$k" in *.pub|*known_hosts*|*config|*authorized_keys) continue ;; esac
        [ -f "$k" ] && ssh-keygen -lf "$k" 2>/dev/null
    done
'

echo
echo "Check it reaches GitHub from there:"
echo "  ssh $TARGET \"ssh -o StrictHostKeyChecking=accept-new -T git@github.com\""
