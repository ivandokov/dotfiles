cpv() {
    rsync -WavP --human-readable --progress $1 $2
}

git-delete-merged() {
    git branch -d `git branch --merged | grep -v '^*' | grep -v 'master' | tr -d '\n'`
}

ip() {
    local ip=$(curl -s ipecho.net/plain)
    echo $ip | pbcopy
    echo $ip
}

digall() {
	dig +nocmd "$1" any +multiline +noall +answer
}

tinker() {
    while true; do
        php artisan tinker
    done
}

function p() {
    php artisan test --compact
}

function pf() {
    php artisan test --compact --filter "$@"
}

function tw {
    if [ $# -eq 0 ] || [ $1 = "." ]; then
        TW_PATH=$(pwd)
    else
        TW_PATH=$1
    fi

    TW_PATH=$(echo -n $TW_PATH | base64)

    open "tinkerwell://?cwd=$TW_PATH"
}

laralog() {
  tail -f -n 450 storage/logs/laravel*.log | \
  grep -i -E "^\[\d{4}\-\d{2}\-\d{2} \d{2}:\d{2}:\d{2}\]|Next [\w\W]+?\:" --color
}

db() {
    if [ "$1" = "refresh" ]; then
        mysql -uroot -e "drop database $2; create database $2"
    elif [ "$1" = "create" ]; then
        mysql -uroot -e "create database $2"
    elif [ "$1" = "drop" ]; then
        mysql -uroot -e "drop database $2"
    fi
}

opendb() {
   [ ! -f .env ] && { echo "No .env file found."; exit 1; }

   DB_CONNECTION=$(grep DB_CONNECTION .env | grep -v -e '^\s*#' | cut -d '=' -f 2-)
   DB_HOST=$(grep DB_HOST .env | grep -v -e '^\s*#' | cut -d '=' -f 2-)
   DB_PORT=$(grep DB_PORT .env | grep -v -e '^\s*#' | cut -d '=' -f 2-)
   DB_DATABASE=$(grep DB_DATABASE .env | grep -v -e '^\s*#' | cut -d '=' -f 2-)
   DB_USERNAME=$(grep DB_USERNAME .env | grep -v -e '^\s*#' | cut -d '=' -f 2-)
   DB_PASSWORD=$(grep DB_PASSWORD .env | grep -v -e '^\s*#' | cut -d '=' -f 2-)

   DB_URL="${DB_CONNECTION}://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_DATABASE}"

   open $DB_URL
}

repo() {
    open `git config --get remote.origin.url | sed 's/:/\//' | sed 's/.git$//' | sed 's/git\@/https\:\/\//'`
}

pstorm() {
    phpstorm "$@"
}

# credit: http://nparikh.org/notes/zshrc.txt
# Usage: extract <file>
# Description: extracts archived files / mounts disk images
extract () {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)  tar -jxvf $1                        ;;
            *.tar.gz)   tar -zxvf $1                        ;;
            *.bz2)      bunzip2 $1                          ;;
            *.gz)       gunzip $1                           ;;
            *.tar)      tar -xvf $1                         ;;
            *.tbz2)     tar -jxvf $1                        ;;
            *.tgz)      tar -zxvf $1                        ;;
            *.zip)      unzip $1                            ;;
            *.ZIP)      unzip $1                            ;;
            *.pax)      cat $1 | pax -r                     ;;
            *.pax.Z)    uncompress $1 --stdout | pax -r     ;;
            *.Z)        uncompress $1                       ;;
            *.7z)       7z x $1                             ;;
            *)          echo "'$1' cannot be extracted"     ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
