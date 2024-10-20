#!/bin/sh

install_cri_dockerd() {
    if ! command_exists cri-dockerd; then
        info "Installing cri-dockerd..."
        update
        check_apt_packages curl git wget

        latest_version=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//g')
        wget --show-progress --timestamping https://github.com/Mirantis/cri-dockerd/releases/download/v${latest_version}/cri-dockerd-${latest_version}.amd64.tgz
        tar xvf cri-dockerd-${latest_version}.amd64.tgz
        sudo mv cri-dockerd/cri-dockerd /usr/local/bin/
        rm -rf cri-dockerd cri-dockerd-0.3.15.amd64.tgz
        success "Done!"
    else
        installed_warn "cri-dockerd"
    fi
}

configure_cri_dockerd() {
    info "Configuring cri-dockerd..."
    wget --show-progress --timestamping https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
    wget --show-progress --timestamping https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
    sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/
    sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
}

start_cri_dockerd() {
    info "Starting cri-dockerd..."
    sudo systemctl daemon-reload
    sudo systemctl enable cri-docker.service
    sudo systemctl enable --now cri-docker.socket
    systemctl status --no-pager cri-docker.service || {
        err_exit "Failed to start cri-docker"
    }
    crictl --runtime-endpoint "unix:///var/run/cri-dockerd.sock" ps
}

uninstall_cri_dockerd() {
    info "Uninstalling cri-dockerd"
    sudo systemctl disable cri-docker.service
    sudo systemctl disable cri-docker.socket
    sudo systemctl stop cri-docker.service
    sudo systemctl stop cri-docker.socket
    sudo rm -f /etc/systemd/system/cri-docker.service /etc/systemd/system/cri-docker.socket /usr/local/bin/cri-dockerd
    success "Done!"
}

cri_dockerd_help_message() {
    echo
    echo "Usage: kinst cri [OPTIONS] COMMAND"
    echo
    echo "${FMT_GREEN}==> ${FMT_YELLOW}Options:${FMT_RESET}"
    echo " ${FMT_BLUE}-i, --install${FMT_RESET}        Install cri-dockerd"
    echo " ${FMT_BLUE}-s, --start${FMT_RESET}          Start cri-docker.service"
    echo " ${FMT_BLUE}-u, --uninstall${FMT_RESET}      Uninstall cri-dockerd"
    echo " ${FMT_BLUE}-h, --help${FMT_RESET}           Show this message"
    echo
}
