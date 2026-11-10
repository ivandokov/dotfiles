# Load the operating system specific aliases and functions.
#
# oh-my-zsh only globs the top level of $ZSH_CUSTOM, so files under os/ are not
# sourced automatically. The zz- prefix puts this last in that glob, which lets
# an OS file override something defined in the shared aliases or functions.
for _os_file in "$ZSH_CUSTOM/os/$DOTFILES_OS"/*.zsh(N); do
    source "$_os_file"
done
unset _os_file
