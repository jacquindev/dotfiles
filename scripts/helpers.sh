#!/bin/sh

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

check_apt_packages() {
    if [ ! $? = 0 ] || [ ! "$(dpkg-query -W --show-format='${db:Status-Status}' "$@" 2>&1)" = installed ]; then
        if command_exists apt; then sudo apt install "$@" -y; else sudo apt-get install "$@" -y; fi
    fi
}

cleanup() {
    if [ "$(dpkg-query -W --show-format='${db:Status-Status}' "$@" 2>&1)" = installed ]; then
        if command_exists apt; then sudo apt purge "$@" 2>/dev/null; else sudo apt-get purge "$@" 2>/dev/null; fi
    fi
}

update() {
    if command_exists apt; then sudo apt update; else sudo apt-get update; fi
}

check_brew_packages() {
    if ! brew ls --versions "$@" >/dev/null 2>&1; then
        brew install "$@"
    fi
}

setup_color() {
    FMT_RED="$(tput setaf 1)"
    FMT_GREEN="$(tput setaf 2)"
    FMT_YELLOW="$(tput setaf 220)"
    FMT_BLUE="$(tput setaf 4)"
    FMT_ORANGE="$(tput setaf 208)"
    FMT_PINK="$(tput setaf 5)"
    FMT_BOLD="$(tput bold)"
    FMT_RESET="$(tput sgr0)"
}

underline() {
    printf '\033[4m%s\033[24m\n' "$*" || printf '%s\n' "$*"
}

error() {
    printf '%s❌  Error: %s%s\n' "${FMT_BOLD}${FMT_RED}" "$*" "$FMT_RESET" >&2
}

success() {
    printf '%s🎉  Success: %s%s\n' "${FMT_BOLD}${FMT_GREEN}" "$*" "$FMT_RESET" >&2
}

warning() {
    printf '%s👀  Warning: %s%s\n' "${FMT_YELLOW}" "$*" "$FMT_RESET" >&2
}

info() {
    printf '%s👉  Info: %s%s\n' "${FMT_BLUE}" "$*" "$FMT_RESET" >&2
}

err_exit() {
    error "$@"
    exit 1
}

checkyes() {
    local result=1
    printf '%s🔆  %s [Y/n] %s' "${FMT_ORANGE}" "$*" "${FMT_RESET}" >&2
    read -r opt
    case $opt in
    y* | Y*) local result=0 ;;
    n* | N*) local result=1 ;;
    *)
        echo "Invalid choice. Skipped change."
        exit 0
        ;;
    esac
    return $result
}

checkout() {
    [ -d "$2" ] || git -c advice.detachedHead=0 clone --branch "$3" --depth 1 "$1" "$2"
}

get_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" |\
        grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

true
