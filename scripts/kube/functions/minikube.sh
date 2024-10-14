#!/bin/sh

install_minikube() {
    if ! command_exists kubectl; then
        not_installed_warn "kubectl"
    else
        if ! command_exists minikube; then
            info "Installing minikube..."
            curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
            sudo install minikube-linux-amd64 "$KINST_BIN/minikube"
            rm -f minikube-linux-amd64
            success "Done!"
        else
            installed_warn "minikube"
        fi
    fi
}

uninstall_minikube() {
    if command_exists minikube; then
        info "Uninstalling minikube..."
        minikube delete
        rm -f "$KINST_BIN/minikube"
        success "Done!"
    else
        not_installed_warn "minikube"
    fi
}

mini_addons_list() {
    if command_exists minikube; then
        echo
        underline "${FMT_ORANGE}${FMT_BOLD}Enabled Minikube Addons: ${FMT_RESET}"
        minikube addons list | grep STATUS && minikube addons list | grep enabled
    else
        not_installed_warn "minikube"
    fi
}

mini_status() {
    if command_exists minikube; then
        echo
        underline "${FMT_ORANGE}${FMT_BOLD}Current Status of Minikube: ${FMT_RESET}"
        minikube status
    else
        not_installed_warn "minikube"
    fi
}

mini_help_message() {
    echo
    echo "Usage: kinst minikube [COMMAND]"
    echo
    echo " ${FMT_GREEN}==> ${FMT_YELLOW}Commands:${FMT_RESET}"
    echo " ${FMT_PINK}addons${FMT_RESET}        Show minikube enabled addons"
    echo " ${FMT_PINK}status${FMT_RESET}        Show minikube current status"
    echo
    echo " ${FMT_BLUE}-i, --install${FMT_RESET}        Install minikube"
    echo " ${FMT_BLUE}-u, --uninstall${FMT_RESET}      Uninstall minikube and remove all minikube files"
    echo " ${FMT_BLUE}-h, --help${FMT_RESET}           Show this message"
    echo
}
