# Helpers shared by install.darwin and install.linux.
# Sourced, not executed.

# dotfiles_link <source> <target>
#
# Symlinks target at source. An existing symlink that already points at source
# is left alone. Anything else in the way is moved aside with a timestamp
# suffix rather than deleted, so a wrong guess is always recoverable.
dotfiles_link() {
    local src=$1 dst=$2

    if [ ! -e "$src" ]; then
        echo "  skip $dst (no $src)"
        return
    fi

    if [ -L "$dst" ]; then
        if [ "$(readlink "$dst")" = "$src" ]; then
            echo "  ok   $dst"
            return
        fi
        rm -f "$dst"
    elif [ -e "$dst" ]; then
        local backup="$dst.bak-$(date +%Y%m%d%H%M%S)"
        mv "$dst" "$backup"
        echo "  kept $(basename "$backup")"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "  link $dst -> $src"
}

# dotfiles_oh_my_zsh
#
# Installs oh-my-zsh unattended, which skips both the chsh prompt and the exec
# into a new shell that would otherwise end the installer.
dotfiles_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "  ok   oh-my-zsh"
        return
    fi
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}
