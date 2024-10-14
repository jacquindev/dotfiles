#!/bin/sh

install_helm() {
    if ! command_exists helm; then
        info "Installing helm..."
        wget --show-progress --timestamping https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz
        tar xvf helm-v3.16.2-linux-amd64.tar.gz
        mv linux-amd64/helm "$KINST_BIN/helm"
        rm -rf linux-amd64 helm-v3.16.2-linux-amd64.tar.gz
        success "Done!"
    else
        installed_warn "helm"
    fi
}

uninstall_helm() {
    if command_exists helm; then
        info "Uninstalling helm..."
        rm -rf "$XDG_CONFIG_HOME/helm" "$XDG_DATA_HOME/helm" "$XDG_CACHE_HOME/helm"
        rm -f "$KINST_BIN/helm"
        success "Done!"
    else
        uninstalled_warn "helm"
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
        not_installed_warn "helm"
    fi
}

install_helmfile() {
    if command_exists helm; then
        if ! command_exists helmfile; then
            info "Installing helmfile..."
            wget --show-progress --timestamping https://github.com/helmfile/helmfile/releases/download/v0.168.0/helmfile_0.168.0_linux_amd64.tar.gz
            tar xzf helmfile_0.168.0_linux_amd64.tar.gz
            mv helmfile "$KINST_BIN/helmfile"
            rm -rf helmfile_0.168.0_linux_amd64.tar.gz LICENSE README*
            success "Done!"
        else
            installed_warn "helmfile"
        fi
    else
        not_installed_warn "helm"
    fi
}

install_helmsman() {
    if command_exists helm; then
        if ! command_exists helmsman; then
            info "Installing helmsman..."
            wget --show-progress --timestamping https://github.com/Praqma/helmsman/releases/download/v3.17.1/helmsman_3.17.1_linux_amd64.tar.gz
            tar xzf helmsman_3.17.1_linux_amd64.tar.gz
            mv helmsman "$KINST_BIN/helmsman"
            rm -f helmsman_3.17.1_linux_amd64.tar.gz LICENSE README.md
            success "Done!"
        else
            warning "Already installed helmsman!"
        fi
    else
        not_installed_warn "helm"
    fi
}

install_helm_docs() {
    if command_exists helm; then
        if ! command_exists helm-docs; then
            if command_exists go; then
                info "Installing helm-docs..."
                GOPATH="$KINST_LOCATION" go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest
                success "Done!"
            else
                info "Installing helm-docs with Homebrew..."
                brew install norwoodj/tap/helm-docs
                success "Done!"
            fi
        fi
    else
        not_installed_warn "helm"
    fi
}

helm_help_message() {
    echo
    echo "Usage: kinst helm [OPTIONS] COMMAND"
    echo
    echo " ${FMT_GREEN}==> ${FMT_YELLOW}Commands:${FMT_RESET}"
    echo " ${FMT_PINK}docs, helm-docs${FMT_RESET}      helm-docs"
    echo " ${FMT_PINK}file, helmfile${FMT_RESET}       helmfile"
    echo " ${FMT_PINK}sman, helmsman${FMT_RESET}       helmsman"
    echo " ${FMT_PINK}plugins${FMT_RESET}              install some basic helm's plugins"
    echo
    echo " ${FMT_GREEN}==> ${FMT_YELLOW}Options:${FMT_RESET}"
    echo " ${FMT_BLUE}-i, --install${FMT_RESET}        Install helm / helm tool"
    echo " ${FMT_BLUE}-u, --uninstall${FMT_RESET}      Uninstall helm / helm tool"
    echo " ${FMT_BLUE}-h, --help${FMT_RESET}           Show this message"
    echo
}
