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

true
