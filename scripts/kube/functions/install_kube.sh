#!/bin/sh

# Kubectl, Kubeadm, Kubelet
install_kubectl() {
    if ! command_exists kubectl; then
        update
        check_apt_packages apt-transport-https ca-certificates curl gpg
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key |
            sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' |
            sudo tee /etc/apt/sources.list.d/kubernetes.list
        update
        check_apt_packages kubelet kubeadm kubectl
        sudo apt-mark hold kubelet kubeadm kubectl
        sudo systemctl enable --now kubelet
        success "Done!"
    else
        installed_warn "kubectl"
    fi
}

# Binaries
# ----------------
# kube-convert
install_kubectl_convert() {
    if command_exists kubectl; then
        if ! command_exists kubectl-convert; then
            info "Installing kubectl-convert plugin..."
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert.sha256"
            echo "Validate the binary"
            echo "$(cat kubectl-convert.sha256) kubectl-convert" | sha256sum --check
            chmod +x kubectl-convert
            mv kubectl "$KINST_BIN/kubectl-convert"
            rm -f kubectl-convert.sha256
            success "Done!"
        else
            installed_warn "kubectl-convert"
        fi
    else
        not_installed_warn "kubectl"
    fi
}

# kube_aggregator
install_kube_aggregator() {
    if command_exists kubectl; then
        if ! command_exists kube-aggregator; then
            info "Installing kube-aggregator"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-aggregator"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-aggregator.sha256"
            echo "Validate the binary"
            echo "$(cat kube-aggregator.sha256) kube-aggregator" | sha256sum --check
            chmod +x kube-aggregator
            mv kube-aggregator "$KINST_BIN/kube-aggregator"
            rm -f kube-aggregator.sha256
            success "Done!"
        else
            installed_warn "kube-aggregator"
        fi
    else
        not_installed_warn "kubectl"
    fi
}

# kube-apiserver
install_kube_apiserver() {
    if command_exists kubectl; then
        if ! command_exists kube-apiserver; then
            info "Installing kube-apiserver"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-apiserver"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-apiserver.sha256"
            echo "Validate the binary"
            echo "$(cat kube-apiserver.sha256) kube-apiserver" | sha256sum --check
            chmod +x kube-apiserver
            mv kube-apiserver "$KINST_BIN/kube-apiserver"
            rm -f kube-apiserver.sha256
            success "Done!"
        else
            installed_warn "kube-apiserver"
        fi
    else
        not_installed_warn "kubectl"
    fi
}

# kube-controller-manager
install_kube_controller_manager() {
    if command_exists kubectl; then
        if ! command_exists kube-controller-manager; then
            info "Installing kube-controller-manager"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-controller-manager"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-controller-manager.sha256"
            echo "Validate the binary"
            echo "$(cat kube-controller-manager.sha256) kube-controller-manager" | sha256sum --check
            chmod +x kube-controller-manager
            mv kube-controller-manager "$KINST_BIN/kube-controller-manager"
            rm -f kube-controller-manager.sha256
            success "Done!"
        else
            installed_warn "kube-controller-manager"
        fi
    else
        not_installed_warn "kubectl"
    fi
}

# kube-log-runner
install_kube_log_runner() {
    if command_exists kubectl; then
        if ! command_exists kube-log-runner; then
            info "Installing kube-log-runner"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-log-runner"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-log-runner.sha256"
            echo "Validate the binary"
            echo "$(cat kube-log-runner.sha256) kube-log-runner" | sha256sum --check
            chmod +x kube-log-runner
            mv kube-log-runner "$KINST_BIN/kube-log-runner"
            rm -f kube-log-runner kube-log-runner.sha256
            success "Done!"
        else
            installed_warn "kube-log-runner"
        fi
    else
        not_installed_warn "kubectl"
    fi
}

# kube-proxy
install_kube_proxy() {
    if command_exists kubectl; then
        if ! command_exists kube-proxy; then
            info "Installing kube-proxy"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-proxy"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-proxy.sha256"
            echo "Validate the binary"
            echo "$(cat kube-proxy.sha256) kube-proxy" | sha256sum --check
            chmod +x kube-proxy
            mv kube-proxy "$KINST_BIN/kube-proxy"
            rm -f kube-proxy.sha256
            success "Done!"
        else
            installed_warn "kube-proxy"
        fi
    else
        not_installed_warn "kubectl"
    fi
}

# kube-scheduler
install_kube_scheduler() {
    if command_exists kubectl; then
        if ! command_exists kube-scheduler; then
            info "Installing kube-scheduler"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-scheduler"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-scheduler.sha256"
            echo "Validate the binary"
            echo "$(cat kube-scheduler.sha256) kube-scheduler" | sha256sum --check
            chmod +x kube-scheduler
            mv kube-scheduler "$KINST_BIN/kube-scheduler"
            rm -f kube-scheduler.sha256
            success "Done!"
        else
            installed_warn "kube-scheduler"
        fi
    else
        not_installed_warn "kubectl"
    fi
}

# Addons
# ----------------
# kubebuilder
install_kubebuilder() {
    if command_exists kubectl; then
        if ! command_exists kubebuilder; then
            info "Installing kubebuilder..."
            curl -L -o kubebuilder "https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)"
            chmod +x kubebuilder
            mv kubebuilder "$KINST_BIN/kubebuilder"
            success "Done!"
        else
            installed_warn "kubebuilder"
        fi
    else
        not_installed_warn "kubectl"
    fi
}

# kubecm
install_kubecm() {
    if command_exists kubectl; then
        if ! command_exists kubecm; then
            info "Installing kubecm"
            latest_version=$(get_latest_release "sunny0826/kubecm")
            curl -LO https://github.com/sunny0826/kubecm/releases/download/${latest_version}/kubecm_${latest_version}_Linux_x86_64.tar.gz
            tar xvf kubecm_${latest_version}_Linux_x86_64.tar.gz
            chmod 755 kubecm
            mv kubecm "$KINST_BIN/kubecm"
            rm -rf LICENSE README.md kubecm_${latest_version}_Linux_x86_64.tar.gz
            success "Done!"
        else
            installed_warn "kubecm"
        fi
    else
        not_installed_warn "kubectl"
    fi
}

# kubeconform
install_kubeconform() {
    if command_exists kubectl; then
        if ! command_exists kubeconform; then
            if command_exists go; then
                info "Installing kubeconform..."
                GOPATH="$KINST_BIN" go install github.com/yannh/kubeconform/cmd/kubeconform@latest
                success "Done!"
            else
                info "Installing kubeconform..."
                latest_version=$(get_latest_release "yannh/kubeconform")
                curl -LO https://github.com/yannh/kubeconform/releases/download/${latest_version}/kubeconform-linux-amd64.tar.gz
                tar -xvzf kubeconform-linux-amd64.tar.gz
                mv kubeconform "$KINST_BIN/kubeconform"
                rm -f kubeconform-linux-amd64.tar.gz LICENSE
                success "Done!"
            fi
        else
            installed_warn "kubeconform"
        fi
    else
        not_installed_warn "kubectl"
    fi
}

# kube-linter
install_kube_linter() {
    if command_exists kubectl; then
        if ! command_exists kube-linter; then
            if command_exists go; then
                info "Installing kube-linter..."
                GOPATH="$KINST_BIN" go install golang.stackrox.io/kube-linter/cmd/kube-linter@latest
                success "Done!"
            else
                info "Installing kube-linter..."
                latest_version=$(get_latest_release "stackrox/kube-linter")
                wget --show-progress --timestamping https://github.com/stackrox/kube-linter/releases/download/${latest_version}/kube-linter-linux.tar.gz
                tar xvf kube-linter-linux.tar.gz
                chmod 755 kube-linter
                mv kube-linter "$KINST_BIN/kube-linter"
                rm -f kube-linter-linux.tar.gz LICENSE README.md
                success "Done!"
            fi
        else
            installed_warn "kube-linter"
        fi
    else
        not_installed_warn "kubectl"
    fi
}

# kubent (kube-no-trouble)
install_kubent() {
    if command_exists kubectl; then
        if ! command_exists kubent; then
            info "Installing kubent (kube-no-trouble)..."
            latest_version=$(get_latest_version "doitintl/kube-no-trouble")
            wget --show-progress --timestamping https://github.com/doitintl/kube-no-trouble/releases/download/${latest_version}/kubent-${latest_version}-linux-amd64.tar.gz
            tar xvf kubent-${latest_version}-linux-amd64.tar.gz
            mv kubent "$KINST_BIN/kubent"
            rm -f kubent-${latest_version}-linux-amd64.tar.gz
            success "Done!"
        else
            installed_warn "kubent (kube-no-trouble)"
        fi
    else
        not_installed_warn "kubectl"
    fi
}

# kubescape
install_kubescape() {
    if command_exists kubectl; then
        if ! command_exists kubescape; then
            info "Installing kubescape..."
            curl -s https://raw.githubusercontent.com/kubescape/kubescape/master/install.sh | /bin/bash
            [ -d "$HOME/.kubescape" ] && mv "$HOME/.kubescape" "$KINST_LOCATION/kubescape"
            ln -s "$KINST_LOCATION/kubescape/bin/kubescape" "$KINST_BIN/kubescape"
            success "Done!"
        else
            installed_warn "kubescape"
        fi
    else
        not_installed_warn "kubectl"
    fi
}

# kubeseal
install_kubeseal() {
    if command_exists kubectl; then
        if ! command_exists kubeseal; then
            if command_exists go; then
                info "Installing kubeseal..."
                GOPATH="$KINST_BIN" go install github.com/bitnami-labs/sealed-secrets/cmd/kubeseal@main
                success "Done!"
            else
                info "Installing kubeseal..."
                KUBESEAL_VERSION=$(curl -s https://api.github.com/repos/bitnami-labs/sealed-secrets/tags | jq -r '.[0].name' | cut -c 2-)
                curl -OL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION:?}/kubeseal-${KUBESEAL_VERSION:?}-linux-amd64.tar.gz"
                tar -xvzf kubeseal-${KUBESEAL_VERSION:?}-linux-amd64.tar.gz kubeseal
                chmod +x kubeseal
                mv kubeseal "$KINST_BIN/kubeseal"
                rm -f kubeseal kubeseal-${KUBESEAL_VERSION:?}-linux-amd64.tar.gz
                success "Done!"
            fi
        else
            installed_warn "kubeseal"
        fi
    else
        not_installed_warn "kubectl"
    fi
}

# kubeshark
install_kubeshark() {
    if command_exists kubectl; then
        if ! command_exists kubeshark; then
            if command_exists helm && checkyes "Install kubeshark with Helm?"; then
                info "Installing kubeshark..."
                helm repo add kubeshark "https://helm.kubeshark.co"
                ‍helm install kubeshark kubeshark/kubeshark
                success "Done!"
            else
                info "Installing kubeshark..."
                latest_version=$(get_latest_release "kubeshark/kubeshark")
                curl -Lo kubeshark https://github.com/kubeshark/kubeshark/releases/download/${latest_version}/kubeshark_linux_amd64
                chmod 755 kubeshark
                mv kubeshark "$KINST_BIN/kubeshark"
                success "Done!"
            fi
        else
            installed_warn "kubeshark"
        fi
    else
        not_installed_warn "kubectl"
    fi
}

# kubespy
install_kubespy() {
    if command_exists kubectl; then
        if ! command_exists kubespy; then
            info "Installing kubespy"
            if command_exists go; then
                info "Installing kubespy..."
                GOPATH="$KINST_BIN" go install github.com/pulumi/kubespy@latest
                success "Done!"
            else
                latest_version=$(get_latest_release "pulumi/kubespy")
                wget --show-progress --timestamping https://github.com/pulumi/kubespy/releases/download/${latest_version}/kubespy-${latest_version}-linux-amd64.tar.gz
                tar xvf kubespy-${latest_version}-linux-amd64.tar.gz
                chmod +x kubespy
                mv kubespy "$KINST_BIN/kubespy"
                rm -f LICENSE README.md kubespy-${latest_version}-linux-amd64.tar.gz
                success "Done!"
            fi
        else
            installed_warn "kubespy"
        fi
    else
        not_installed_warn "kubectl"
    fi
}

# Extras
# --------------------------------
# kompose
install_kompose() {
    if command_exists kubectl; then
        if ! command_exists kompose; then
            if command_exists go; then
                info "Installing kompose..."
                GOPATH="$KINST_BIN" go install github.com/kubernetes/kompose@latest
                success "Done!"
            else
                info "Installing kompose..."
                latest_version=$(get_latest_release "kubernetes/kompose")
                curl -L https://github.com/kubernetes/kompose/releases/download/${latest_version}/kompose-linux-amd64 -o kompose
                chmod +x kompose
                mv kompose "$KINST_BIN/kompose"
                success "Done!"
            fi
        else
            installed_warn "kompose"
        fi
    else
        not_installed_warn "kubectl"
    fi
}

# kustomize
install_kustomize() {
    if command_exists kubectl; then
        if ! command_exists kustomize; then
            if command_exists go; then
                info "Installing kustomize..."
                builtin cd "$KINST_BIN"
                GOBIN=$(pwd)/ GO111MODULE=on go install sigs.k8s.io/kustomize/kustomize/v5@latest
                success "Done!"
            else
                info "Installing kustomize..."
                builtin cd "$KINST_BIN"
                curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
                success "Done!"
            fi
        else
            installed_warn "kustomize"
        fi
    else
        not_installed_warn "kubectl"
    fi
}

# Extras
# --------------------------------
# krew (Kubectl Plugin Manager)
# Note: This plugin manager requires kubectl to be installed and functional.
# The plugin manager is installed alongside kubectl and is used to manage and install other kubectl plugins.
install_krew() {
    if ! command_exists kubectl; then
        not_installed_warn "kubectl"
    else
        if ! command_exists kubectl-krew; then
            info "Installing Krew (Kubectl Plugin Manager)..."

            export KREW_ROOT="$KINST_LOCATION/krew"

            (
                set -x
                cd "$(mktemp -d)" &&
                    OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
                    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
                    KREW="krew-${OS}_${ARCH}" &&
                    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
                    tar zxvf "${KREW}.tar.gz" &&
                    ./"${KREW}" install krew
            )
            if [ -d "$HOME/.krew" ]; then mv "$HOME/.krew" "$KINST_LOCATION/krew"; fi
            echo
            info "Add shell completion for kubectl-krew..."
            echo '#!/bin/sh\nkubectl krew __complete "$@"' >"$KREW_ROOT/bin/kubectl_complete-krew"
            chmod u+x "$KREW_ROOT/bin/kubectl_complete-krew"

            ln -s "$KREW_ROOT/bin/kubectl-krew" "$KINST_BIN/kubectl-krew"
            ln -s "$KREW_ROOT/bin/kubectl_complete-krew" "$KINST_BIN/kubectl_complete-krew"

            success "Done!"
        else
            install_warn "krew"
        fi
    fi
}

# kubectx and kubens
install_kubectx() {
    if ! command_exists kubectl; then
        not_installed_warn "kubectl"
    else
        if ! command_exists kubectx; then
            info "Installing Kubectx..."
            git clone https://github.com/ahmetb/kubectx "$KINST_LOCATION/kubectx"
            ln -s "$KINST_LOCATION/kubectx/kubectx" "$KINST_BIN/kubectx"
            ln -s "$KINST_LOCATION/kubectx/kubens" "$KINST_BIN/kubens"
            success "Done!"
        else
            installed_warn "kubectx & kubens"
        fi
    fi
}

# Helm message
# --------------------------------
kube_help_message() {
    echo
    echo "Usage: kinst kube [OPTIONS] COMMAND"
    echo
    echo " ${FMT_GREEN}==> ${FMT_YELLOW}Commands:${FMT_RESET}"
    echo " ${FMT_PINK}agg, aggregator${FMT_RESET}      kube-aggregator"
    echo " ${FMT_PINK}api, apiserver${FMT_RESET}       kube-apiserver"
    echo " ${FMT_PINK}control, controller${FMT_RESET}  kube-controller-manager"
    echo " ${FMT_PINK}convert${FMT_RESET}              kubectl-convert"
    echo " ${FMT_PINK}linter${FMT_RESET}               kube-linter"
    echo " ${FMT_PINK}log, log-runner${FMT_RESET}      kube-log-runner"
    echo " ${FMT_PINK}proxy${FMT_RESET}                kube-proxy"
    echo " ${FMT_PINK}scheduler${FMT_RESET}            kube-scheduler"
    echo
    echo " ${FMT_PINK}builder${FMT_RESET}              kubebuilder"
    echo " ${FMT_PINK}cm${FMT_RESET}                   kubecm"
    echo " ${FMT_PINK}conform${FMT_RESET}              kubeconform"
    echo " ${FMT_PINK}kubectl${FMT_RESET}              kubectl, kubeadm, and kubelet"
    echo " ${FMT_PINK}ctx, kubectx${FMT_RESET}         kubectx and kubens"
    echo " ${FMT_PINK}kompose${FMT_RESET}              kompose"
    echo " ${FMT_PINK}ks, kus, kustomize${FMT_RESET}   kustomize"
    echo " ${FMT_PINK}kw, krew${FMT_RESET}             krew (kubectl plugin manager)"
    echo " ${FMT_PINK}nt, kubent${FMT_RESET}           kubent"
    echo " ${FMT_PINK}scape${FMT_RESET}                kubescape"
    echo " ${FMT_PINK}seal${FMT_RESET}                 kubeseal"
    echo " ${FMT_PINK}shark${FMT_RESET}                kubeshark"
    echo " ${FMT_PINK}spy${FMT_RESET}                  kubespy"
    echo
    echo " ${FMT_GREEN}==> ${FMT_YELLOW}Options:${FMT_RESET}"
    echo " ${FMT_BLUE}-i, --install${FMT_RESET}        Install kubernetes / kubernetes tool"
    echo " ${FMT_BLUE}-u, --uninstall${FMT_RESET}      Uninstall kubernetes / kubernetes tool"
    echo " ${FMT_BLUE}-h, --help${FMT_RESET}           Show this message"
    echo
}
