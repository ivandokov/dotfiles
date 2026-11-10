# Aliases that work on every machine. The ls colour flags, and anything that
# drives a macOS or Linux only tool, live in os/<os>/aliases.zsh.

alias la='ll'

alias gut='git'
alias got='git'
alias gti='git'
alias nah='git reset --hard && git clean -df'

alias a='php artisan'
alias s='sail'
alias c='composer'
alias cu='composer update'
alias cr='composer require'
alias ci='composer install'
alias cda='composer dump-autoload -o'
alias mfs='php artisan migrate:fresh --seed'

alias fixpermissions="find . -type d -exec chmod 755 {} \; && find . -type f -exec chmod 644 {} \;"

alias key='cat ~/.ssh/ivan_2026.pub | clipcopy'

alias flush-redis="redis-cli FLUSHALL"

# GREP_OPTIONS was removed from GNU grep, which now warns about it on every
# call, so colour is requested per invocation instead.
alias grep='grep --color=auto'

# Enable aliases to be sudo'ed
alias sudo='sudo '
