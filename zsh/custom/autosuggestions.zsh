# zsh-autosuggestions, wherever the platform's package manager put it.
for _autosuggestions in \
    /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
do
    [ -f "$_autosuggestions" ] && source "$_autosuggestions" && break
done
unset _autosuggestions
