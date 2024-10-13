#!/bin/sh

export DOTFILES="$HOME/.dotfiles"
. "$DOTFILES/scripts/helpers.sh"

install_minikube() {
    if ! command_exists minikube; then
        info "Installing minikube..."
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm -f minikube-linux-amd64
    else
        warning "Already installed minikube!"
    fi
}

start_minikube() {
    if command_exists minikube; then
        info "Start minikube..."
        minikube start
        minikube addons enable metrics-server
        minikube addons enable ingress
        minikube addons enable dashboard
    else
        error "Not found minikube on the machine. Please install to activate minikube!"
    fi
}

purge_minikube() {
    if command_exists minikube; then
        info "Purging Minikube..."
        minikube delete
        sudo rm -rf /usr/local/bin/minikube
    else
        error "Not found minikube to purge!"
    fi
}

mini_addons() {
    if command_exists minikube; then
        echo
        underline "${FMT_ORANGE}Enabled Minikube Addons: ${FMT_RESET}"
        minikube addons list | grep STATUS && minikube addons list | grep enabled
    else
        error "Not found minikube! Please install"
    fi
}

mini_status() {
    if command_exists minikube; then
        echo
        underline "${FMT_GREEN}Current Status of Minikube: ${FMT_RESET}"
        minikube status
    else
        error "Not found minikube! Please install"
    fi
}

mini_help() {
    echo
    echo "$(tput setaf 2)==> $(tput setaf 220)Parameters:"
    echo
    echo "  $(tput setaf 5)--install$(tput sgr0)        install Minikube"
    echo "  $(tput setaf 5)--start$(tput sgr0)          start Minikube"
    echo "  $(tput setaf 5)--purge$(tput sgr0)          remove Minikube files and uninstall Minikube"
    echo "  $(tput setaf 5)--addons$(tput sgr0)         show enabled Minikube addons"
    echo "  $(tput setaf 5)--status$(tput sgr0)         show current Minikube status"
    echo "  $(tput setaf 5)--help$(tput sgr0)           show this message"
    echo
}
