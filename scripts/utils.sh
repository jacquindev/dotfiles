#!/bin/sh

FMT_RED=$(printf '\033[38;5;196m')
FMT_GREEN=$(printf '\033[38;5;082m')
FMT_YELLOW=$(printf '\033[38;5;226m')
FMT_BLUE=$(printf '\033[38;5;021m')
FMT_ORANGE=$(printf '\033[38;5;202m')
FMT_PINK=$(printf '\033[38;5;163m')
FMT_BOLD=$(printf '\033[1m')
FMT_RESET=$(printf '\033[0m')

underline() {
    printf '\033[4m%s\033[24m\n' "$*" || printf '%s\n' "$*"
}

error() {
    printf '%s❌ Error: %s%s\n' "${FMT_BOLD}${FMT_RED}" "$*" "$FMT_RESET" >&2
}

success() {
    printf '%s🎉 Success: %s%s\n' "${FMT_BOLD}${FMT_GREEN}" "$*" "$FMT_RESET" >&2
}

warning() {
    printf '%s👀 Warning: %s%s\n' "${FMT_YELLOW}" "$*" "$FMT_RESET" >&2
}

info() {
    printf '%s👉 Info: %s%s\n' "${FMT_BLUE}" "$*" "$FMT_RESET" >&2
}

err_exit() {
    error "$@"
    exit 1
}

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

checkyes() {
    local result=1
    printf '%s🔆 %s [Y/n] %s' "${FMT_ORANGE}" "$*" "${FMT_RESET}" >&2
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

true
