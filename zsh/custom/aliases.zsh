alias l='ls -lFhG'
alias ll='ls -laFhG'
alias la='ll'

alias dnsclear='dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

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

alias key='cat ~/.ssh/ivan_2026.pub | pbcopy'

alias backup-photos='rsync -arv /Users/ivan/Pictures/Phockup/ /Volumes/3TB/Photos'

alias flush-redis="redis-cli FLUSHALL"

alias btrestart='blueutil -p 0 && sleep 1 && blueutil -p 1'

# Enable aliases to be sudo’ed
alias sudo='sudo '

