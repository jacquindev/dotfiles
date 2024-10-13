#!/bin/sh

export DOTFILES="$HOME/.dotfiles"
. "$DOTFILES/scripts/helpers.sh"

install_helm() {
    if ! command_exists helm; then
        info "Installing Helm..."
        wget --show-progress --timestamping https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz
        tar xvf helm-v3.16.2-linux-amd64.tar.gz
        sudo mv linux-amd64/helm /usr/local/bin/
        rm -rf linux-amd64 helm-v3.16.2-linux-amd64.tar.gz
        success "Done!"
    else
        warning "Already installed Helm!"
    fi
}

install_helm_plugins() {
    if command_exists helm; then
        info "Installing Helm plugins..."
        helm plugin install https://github.com/adamreese/helm-env
        helm plugin install https://github.com/aslafy-z/helm-git --version 1.3.0
        helm plugin install https://github.com/databus23/helm-diff
        helm plugin install https://github.com/hayorov/helm-gcs
        helm plugin install https://github.com/hypnoglow/helm-s3
        helm plugin install https://github.com/jkroepke/helm-secrets --version v4.6.1
        success "Done!"
    else
        error "You must install helm in order to add Helm's plugins!"
    fi
}

install_helmfile() {
    if command_exists helm; then
        if ! command_exists helmfile; then
            info "Installing helmfile..."
            wget --show-progress --timestamping https://github.com/helmfile/helmfile/releases/download/v0.168.0/helmfile_0.168.0_linux_amd64.tar.gz
            tar xzf helmfile_0.168.0_linux_amd64.tar.gz
            sudo mv helmfile /usr/local/bin/helmfile
            rm -rf helmfile_* LICENSE README*
            success "Done!"
        else
            warning "Already installed helmfile!"
        fi
    else
        error "You must install Helm in order to use helmfile!"
    fi
}

install_helmsman() {
    if command_exists helm; then
        if ! command_exists helmsman; then
            info "Installing helmsman..."
            wget --show-progress --timestamping https://github.com/Praqma/helmsman/releases/download/v3.17.1/helmsman_3.17.1_linux_amd64.tar.gz
            tar xzf helmsman_3.17.1_linux_amd64.tar.gz
            sudo mv helmsman /usr/local/bin/helmsman
            rm -rf helmsman_* LICENSE README.md
            success "Done!"
        else
            warning "Already installed helmsman!"
        fi
    else
        error "You must install Helm in order to use helmsman!"
    fi
}

install_helm_docs() {
    if command_exists helm; then
        if ! command_exists helm-docs; then
            if command_exists go && checkyes "Install helm-docs with Go?"; then
                info "Installing helm-docs with Go..."
                go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest
                success "Done!"
            else
                info "Installing helm-docs with Homebrew..."
                brew install norwoodj/tap/helm-docs
                success "Done!"
            fi
        fi
    else
        error "You must install Helm in order to use helm-docs!"
    fi
}

helm_help() {
    echo
    echo "$(tput setaf 2)==> $(tput setaf 220)Parameters:"
    echo
    echo "  $(tput setaf 5)--install$(tput sgr0)        install Helm"
    echo "  $(tput setaf 5)--docs$(tput sgr0)           install helm-docs command"
    echo "  $(tput setaf 5)--plugin$(tput sgr0)         install Helm plugins"
    echo "  $(tput setaf 5)--helmfile$(tput sgr0)       install Helmfile command"
    echo "  $(tput setaf 5)--helmsman$(tput sgr0)       install Helmsman command"
    echo "  $(tput setaf 5)--help$(tput sgr0)           show this message"
    echo
}
