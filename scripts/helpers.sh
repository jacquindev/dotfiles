#!/bin/sh

check_apt_packages() {
    if [ ! $? = 0 ] || [ ! "$(dpkg-query -W --show-format='${db:Status-Status}' "$@" 2>&1)" = installed ]; then
        sudo apt install "$@" -y
    fi
}

check_brew_packages() {
    if ! brew ls --versions "$@" >/dev/null 2>&1; then
        brew install "$@"
    fi
}

backup() {
    BACKUP_DIR="$HOME/.cache/backup"
    [ -d "$BACKUP_DIR" ] || mkdir -p "$BACKUP_DIR"

    for file in "$HOME/.config/nvim" "$HOME/.vim" "$HOME/.vimrc" "$HOME/.bashrc" "$HOME/.profile"; do 
        if [ ! -L "$file" ]; then
            echo "Backing up $file..."
            mv -i "$file" "$BACKUP_DIR/$file-$(date +%Y-%m-%d_%H-%M-%S)"
        else
            warning "$file does not exist at this location or is a symlink!"
        fi
    done;
}

true
