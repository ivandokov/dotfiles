# fnm
FNM_PATH="/Users/ivan/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/Users/ivan/.local/share/fnm:$PATH"
#  eval "`fnm env`"
  eval "$(fnm env --use-on-cd --version-file-strategy=recursive --corepack-enabled --shell zsh)"
fi
