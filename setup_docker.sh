#!/bin/sh

# shellcheck source-path=SCRIPTDIR
# shellcheck source-path=SCRIPTDIR
here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"
. "$here/scripts/utils.sh"
. "$here/scripts/helpers.sh"

export DOTFILES="$HOME/.dotfiles"
. "$DOTFILES/shared/envs"

install_docker() {
    info "Installing Docker Engine..."
    # Add Docker's official GPG key:
    sudo apt update
    check_apt_packages lsb-release gnupg apt-transport-https ca-certificates curl software-properties-common
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    check_apt_packages docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin

    # Add Docker as a non-root user
    sudo usermod -aG docker "$USER"
    success "Installed Docker Engine. After running this script, please input: 'newgrp docker' to start Docker!"
}

install_cri_dockerd() {
    info "Installing Cri-Dockerd..."
    sudo apt update
    check_apt_packages curl wget git
    cri_version=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest|grep tag_name | cut -d '"' -f 4 | sed 's/v//g')
    wget --show-progress --timestamping https://github.com/Mirantis/cri-dockerd/releases/download/v${cri_version}/cri-dockerd-${cri_version}.amd64.tgz
    tar xvf cri-dockerd-${cri_version}.amd64.tgz
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

    echo
    underline "Cri-Dockerd Service Status:"
    systemctl status cri-docker.socket
}

install_docker
install_cri_dockerd