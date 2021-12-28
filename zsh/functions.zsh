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
    if [ -f vendor/bin/pest ]; then
        vendor/bin/pest "$@"
    elif [ -f vendor/bin/phpunit ]; then
        vendor/bin/phpunit "$@"
    else
        echo "Missing pest and phpunit!"
    fi
}

function pf() {
    if [ -f vendor/bin/pest ]; then
        vendor/bin/pest --filter "$@"
    elif [ -f vendor/bin/phpunit ]; then
        vendor/bin/phpunit --filter "$@"
    else
        echo "Missing pest and phpunit!"
    fi
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
