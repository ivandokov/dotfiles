# fnm. The env eval is repeated in zshrc.darwin after Herd loads its own nvm,
# which would otherwise shadow the fnm managed node.
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
    path=("$FNM_PATH" $path)
    eval "$(fnm env --use-on-cd --version-file-strategy=recursive --corepack-enabled --shell zsh)"
fi
