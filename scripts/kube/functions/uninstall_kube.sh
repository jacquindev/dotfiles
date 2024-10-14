#!/bin/sh

# Kubectl, kubeadm, kubelet
uninstall_kubectl() {
    if command_exists kubectl; then
        info "Uninstalling kubectl..."
        cleanup kubectl
        success "Done!"
    else
        uninstalled_warn "kubectl"
    fi

    if command_exists kubelet; then
        info "Uninstalling kubelet..."
        sudo systemctl disable --now kubelet
        cleanup kubelet
        success "Done!"
    else
        uninstalled_warn "kubelet"
    fi

    if command_exists kubeadm; then
        info "Uninstalling kubeadm..."
        cleanup kubeadm
        success "Done!"
    else
        uninstalled_warn "kubeadm"
    fi

    if [ -f /etc/apt/sources.list.d/kubernetes.list ]; then
        sudo rm -f /etc/apt/sources.list.d/kubernetes.list
    fi
}
