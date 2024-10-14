#!/bin/sh

install_docker() {
    if ! command_exists docker; then
        info "Installing docker..."
        # Add Docker's official GPG key:
        update
        check_apt_packages apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        # Add the repository to Apt sources:
        # Add the repository to Apt sources:
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
            sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
        update
        check_apt_packages docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin
        # Add Docker as a non-root user
        sudo usermod -aG docker "$USER"
        success "Done!"
        newgrp docker
    else
        installed_warn "docker"
    fi
}

uninstall_docker() {
    if command_exists docker; then
        for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
        unset pkg

        cleanup docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

        if [ -d /var/lib/docker ]; then sudo rm -rf /var/lib/docker; fi
        if [ -d /var/lib/containerd ]; then sudo rm -rf /var/lib/containerd; fi

        success "Docker has been removed."
    fi
}

docker_help_message() {
    echo
    echo "Usage: kinst docker [options] [command]"
    echo
    echo "${FMT_GREEN}==> ${FMT_YELLOW}Options:${FMT_RESET}"
    echo " ${FMT_BLUE}-i, --install${FMT_RESET}     Install Docker on the system"
    echo " ${FMT_BLUE}-u, --uninstall${FMT_RESET}   Uninstall Docker from the system"
    echo " ${FMT_BLUE}-h, --help${FMT_RESET}        Display this help message"
    echo
}
