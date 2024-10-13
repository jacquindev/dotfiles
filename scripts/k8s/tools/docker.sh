#!/bin/sh

export DOTFILES="$HOME/.dotfiles"
. "$DOTFILES/scripts/helpers.sh"

install_docker() {
    if ! command_exists docker; then
        # Add Docker's official GPG key:
        update
        check_apt_packages apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        # Add the repository to Apt sources:
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
            sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
        update
        check_apt_packages docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin
        # Add Docker as a non-root user
        sudo usermod -aG docker "$USER"
        newgrp docker
    else
        warning "Already installed docker! Try to update/reinstall docker."
    fi
}

docker_enable() {
    if command_exists docker; then
        # Enable services
        info "Start and enable docker service"
        sudo systemctl daemon-reload
        sudo systemctl enable docker.service
        sudo systemctl enable --now docker.socket
        success "Done!"
    fi
}

docker_status() {
    if command_exists docker; then
        echo
        underline "${FMT_BOLD}${FMT_GREEN}Docker Service Status:${FMT_RESET}"
        echo
        systemctl status docker.socket
    else
        error "You must install docker to use this option!"
    fi
}

purge_docker() {
    if command_exists docker; then
        info "Purging Docker Engine..."
        cleanup docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
        [ -d /var/lib/docker ] && sudo rm -rf /var/lib/docker
        [ -d /var/lib/containerd ] && sudo rm -rf /var/lib/containerd
        success "Done!"
    else
        error "Not found docker to purge!"
    fi
}

install_dockerd() {
    if ! command_exists cri-dockerd; then
        info "Installing Cri-Dockerd..."
        update
        check_apt_packages curl git wget

        latest_version=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//g')

        wget --show-progress --timestamping https://github.com/Mirantis/cri-dockerd/releases/download/v${latest_version}/cri-dockerd-${latest_version}.amd64.tgz
        tar xvf cri-dockerd-${latest_version}.amd64.tgz
        sudo mv cri-dockerd/cri-dockerd /usr/local/bin/

        # Configure systemd
        info "Configuring systemd units for cri-dockerd"
        wget --show-progress --timestamping https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
        wget --show-progress --timestamping https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
        sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/
        sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
        rm -rf cri-dockerd cri-dockerd-0.3.15.amd64.tgz

        # Enable services
        info "Start and enable cri-dockerd services"
        sudo systemctl daemon-reload
        sudo systemctl enable cri-docker.service
        sudo systemctl enable --now cri-docker.socket

        success "Done!"
    else
        warning "Already installed cri-dockerd!"
    fi
}

dockerd_enable() {
    if command_exists docker && command_exists cri-dockerd; then
        # Enable services
        info "Start and enable cri-dockerd services"
        sudo systemctl daemon-reload
        sudo systemctl enable cri-docker.service
        sudo systemctl enable --now cri-docker.socket
        success "Done!"
    fi
}

dockerd_status() {
    if command_exists cri-dockerd; then
        echo
        underline "${FMT_BOLD}${FMT_GREEN}Cri-Dockerd Service Status:${FMT_RESET}"
        echo
        systemctl status cri-docker.socket
    else
        error "You must install cri-dockerd to use this option!"
    fi
}

docker_help() {
    echo
    echo "$(tput setaf 2)==> $(tput setaf 220)Parameters:"
    echo
    echo "  $(tput setaf 5)--install$(tput sgr0)        install Docker Engine"
    echo "  $(tput setaf 5)--enable$(tput sgr0)         enable Docker service"
    echo "  $(tput setaf 5)--status$(tput sgr0)         show Docker status"
    echo "  $(tput setaf 5)--purge$(tput sgr0)          uninstall Docker Engine and its packages"
    echo "  $(tput setaf 5)--cri$(tput sgr0)            install cri-dockerd"
    echo "  $(tput setaf 5)--enable-cri$(tput sgr0)     enable cri-dockerd.service"
    echo "  $(tput setaf 5)--status-cri$(tput sgr0)     show cri-dockerd status"
    echo "  $(tput setaf 5)--help$(tput sgr0)           show this message"
    echo
}
