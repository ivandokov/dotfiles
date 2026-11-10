# Usage: tw [path]
# Description: opens the given directory (default: the current one) in Tinkerwell
function tw {
    if [ $# -eq 0 ] || [ $1 = "." ]; then
        TW_PATH=$(pwd)
    else
        TW_PATH=$1
    fi

    TW_PATH=$(echo -n $TW_PATH | base64)

    open "tinkerwell://?cwd=$TW_PATH"
}
