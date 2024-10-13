#!/bin/sh

export DOTFILES="$HOME/.dotfiles"
. "$DOTFILES/scripts/helpers.sh"

export GOPATH="$XDG_DATA_HOME/go"
[ -d "$GOPATH" ] || mkdir -p "$GOPATH"

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
        warning "Already installed Kubectl!"
    fi
}

install_kubectl_convert() {
    if command_exists kubectl; then
        if ! command_exists kubectl-convert; then
            info "Installing kubectl-convert plugin..."
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert.sha256"
            echo "Validate the binary"
            echo "$(cat kubectl-convert.sha256) kubectl-convert" | sha256sum --check
            sudo install -o root -g root -m 0755 kubectl-convert /usr/local/bin/kubectl-convert
            rm -f kubectl-convert kubectl-convert.sha256
            success "Done!"
        else
            warning "Already installed kubectl-convert!"
        fi
    fi
}

install_kube_aggregator() {
    if command_exists kubectl; then
        if ! command_exists kube-aggregator; then
            info "Installing kube-aggregator"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-aggregator"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-aggregator.sha256"
            echo "Validate the binary"
            echo "$(cat kube-aggregator.sha256) kube-aggregator" | sha256sum --check
            sudo install -o root -g root -m 0755 kube-aggregator /usr/local/bin/kube-aggregator
            rm -f kubectl-aggregator kube-aggregator.sha256
            success "Done!"
        else
            warning "Already installed kube-aggregator!"
        fi
    fi
}

install_kube_apiserver() {
    if command_exists kubectl; then
        if ! command_exists kube-apiserver; then
            info "Installing kube-apiserver"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-apiserver"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-apiserver.sha256"
            echo "Validate the binary"
            echo "$(cat kube-apiserver.sha256) kube-apiserver" | sha256sum --check
            sudo install -o root -g root -m 0755 kube-apiserver /usr/local/bin/kube-apiserver
            rm -f kube-apiserver kube-apiserver.sha256
            success "Done!"
        else
            warning "Already installed kube-apiserver!"
        fi
    fi
}

install_kube_proxy() {
    if command_exists kubectl; then
        if ! command_exists kube-proxy; then
            info "Installing kube-proxy"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-proxy"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-proxy.sha256"
            echo "Validate the binary"
            echo "$(cat kube-proxy.sha256) kube-proxy" | sha256sum --check
            sudo install -o root -g root -m 0755 kube-proxy /usr/local/bin/kube-proxy
            rm -f kube-proxy kube-proxy.sha256
            success "Done!"
        else
            warning "Already installed kube-proxy!"
        fi
    fi
}

install_kube_scheduler() {
    if command_exists kubectl; then
        if ! command_exists kube-scheduler; then
            info "Installing kube-scheduler"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-scheduler"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-scheduler.sha256"
            echo "Validate the binary"
            echo "$(cat kube-scheduler.sha256) kube-scheduler" | sha256sum --check
            sudo install -o root -g root -m 0755 kube-scheduler /usr/local/bin/kube-scheduler
            rm -f kube-scheduler kube-scheduler.sha256
            success "Done!"
        else
            warning "Already installed kube-scheduler!"
        fi
    fi
}

install_kube_controller() {
    if command_exists kubectl; then
        if ! command_exists kube-controller-manager; then
            info "Installing kube-controller-manager"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-controller-manager"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-controller-manager.sha256"
            echo "Validate the binary"
            echo "$(cat kube-controller-manager.sha256) kube-controller-manager" | sha256sum --check
            sudo install -o root -g root -m 0755 kube-controller-manager /usr/local/bin/kube-controller-manager
            rm -f kube-controller-manager kube-controller-manager.sha256
            success "Done!"
        else
            warning "Already installed kube-controller-manager!"
        fi
    fi
}

install_kube_logrunner() {
    if command_exists kubectl; then
        if ! command_exists kube-log-runner; then
            info "Installing kube-log-runner"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-log-runner"
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kube-log-runner.sha256"
            echo "Validate the binary"
            echo "$(cat kube-log-runner.sha256) kube-log-runner" | sha256sum --check
            sudo install -o root -g root -m 0755 kube-log-runner /usr/local/bin/kube-log-runner
            rm -f kube-log-runner kube-log-runner.sha256
            success "Done!"
        else
            warning "Already installed kube-log-runner!"
        fi
    fi
}

install_kubectx() {
    if ! command_exists kubectx; then
        info "Installing Kubectx..."
        [ ! -d "$XDG_DATA_HOME/kubernetes" ] && mkdir -p "$XDG_DATA_HOME/kubernetes"
        git clone https://github.com/ahmetb/kubectx "$XDG_DATA_HOME/kubernetes/kubectx"
        sudo ln -s "$XDG_DATA_HOME/kubernetes/kubectx/kubectx" /usr/local/bin/kubectx
        sudo ln -s "$XDG_DATA_HOME/kubernetes/kubectx/kubens" /usr/local/bin/kubens
        success "Done!"
    else
        warning "Already installed Kubectx!"
    fi
}

install_krew() {
    if ! command_exists kubectl-krew; then
        info "Installing Krew (Kubectl Plugin Manager)..."
        [ ! -d "$XDG_DATA_HOME/kubernetes" ] && mkdir -p "$XDG_DATA_HOME/kubernetes"
        export KREW_ROOT="$XDG_DATA_HOME/kubernetes/krew"
        export PATH="$KREW_ROOT/bin:$PATH"
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
        if [ -d "$HOME/.krew" ]; then mv "$HOME/.krew" "$XDG_DATA_HOME/kubernetes/krew"; fi

        echo
        info "Add shell completion for kubectl-krew..."
        echo '#!/bin/sh\nkubectl krew __complete "$@"' >"$KREW_ROOT/bin/kubectl_complete-krew"
        chmod u+x "$KREW_ROOT/bin/kubectl_complete-krew"
        success "Done!"
    else
        warning "Krew already installed!"
    fi
}

install_kubescape() {
    if command_exists kubectl; then
        if ! command_exists kubescape; then
            info "Installing kubescape..."
            curl -s https://raw.githubusercontent.com/kubescape/kubescape/master/install.sh | /bin/bash
            success "Done!"
        else
            warning "Already installed kubescape!"
        fi
    fi
}

install_kubespy() {
    if command_exists kubectl; then
        if ! command_exists kubespy; then
            info "Installing kubespy"
            if command_exists go; then
                go install github.com/pulumi/kubespy@latest
                success "Done!"
            else
                latest_version=$(get_latest_release "pulumi/kubespy")
                wget --show-progree --timestamping https://github.com/pulumi/kubespy/releases/download/${latest_version}/kubespy-${latest_version}-linux-amd64.tar.gz
                tar xvf kubespy-${latest_version}-linux-amd64.tar.gz
                chmod +x kubespy
                sudo mv kubespy /usr/local/bin/kubespy
                rm -rf LICENSE README.md kubespy-${latest_version}-linux-amd64.tar.gz
                success "Done!"
            fi
        else
            warning "Already installed kubespy!"
        fi
    fi
}

install_kubent() {
    if command_exists kubectl; then
        if ! command_exists kubent; then
            info "Installing kubent..."
            sh -c "$(curl -sSL https://git.io/install-kubent)"
            success "Done!"
        else
            warning "Already installed kubent!"
        fi
    fi
}

install_kube_seal() {
    if command_exists kubectl; then
        if ! command_exists kubeseal; then
            if command_exists helm && checkyes "Install kubeseal with Helm?"; then
                helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
                success "Done!"
            elif command_exists go && checkyes "Install kubeseal with Go?"; then
                go install github.com/bitnami-labs/sealed-secrets/cmd/kubeseal@main
                success "Done!"
            else
                KUBESEAL_VERSION=$(curl -s https://api.github.com/repos/bitnami-labs/sealed-secrets/tags | jq -r '.[0].name' | cut -c 2-)
                curl -OL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION:?}/kubeseal-${KUBESEAL_VERSION:?}-linux-amd64.tar.gz"
                tar -xvzf kubeseal-${KUBESEAL_VERSION:?}-linux-amd64.tar.gz kubeseal
                sudo install -m 755 kubeseal /usr/local/bin/kubeseal
                success "Done!"
            fi
        fi
    fi
}

install_kustomize() {
    if command_exists kubectl; then
        if ! command_exists kustomize; then
            if command_exists go && checkyes "Install Kustomize with Go?"; then
                GOBIN=$(pwd)/ GO111MODULE=on go install sigs.k8s.io/kustomize/kustomize/v5@latest
                mv kustomize "$GOPATH"/bin/kustomize
                success "Done!"
            else
                curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
                sudo mv kustomize /usr/local/bin/kustomize
                success "Done!"
            fi
        fi
    fi
}

kube_help() {
    echo
    echo "$(tput setaf 2)==> $(tput setaf 220)Parameters:"
    echo
    echo "  $(tput setaf 5)--install$(tput sgr0)        install Kubectl"
    echo "  $(tput setaf 5)--agg$(tput sgr0)            install Kube-Aggregator plugin"
    echo "  $(tput setaf 5)--api$(tput sgr0)            install Kube-Apiserver plugin"
    echo "  $(tput setaf 5)--control$(tput sgr0)        install Kube-Controller-Manager plugin"
    echo "  $(tput setaf 5)--convert$(tput sgr0)        install Kubectl-Convert plugin"
    echo "  $(tput setaf 5)--kubectx$(tput sgr0)        install Kubectx and Kubens"
    echo "  $(tput setaf 5)--kubent$(tput sgr0)         install Kubent (Kube No Trouble)"
    echo "  $(tput setaf 5)--krew$(tput sgr0)           install Krew (Kubectl Plugin Manager)"
    echo "  $(tput setaf 5)--kus$(tput sgr0)            install Kustomize"
    echo "  $(tput setaf 5)--log$(tput sgr0)            install Kube-Log-Runner plugin"
    echo "  $(tput setaf 5)--proxy$(tput sgr0)          install Kube-Proxy plugin"
    echo "  $(tput setaf 5)--scape$(tput sgr0)          install Kubescape command"
    echo "  $(tput setaf 5)--schedule$(tput sgr0)       install Kube-Scheduler plugin"
    echo "  $(tput setaf 5)--seal$(tput sgr0)           install Kubeseal command"
    echo "  $(tput setaf 5)--spy$(tput sgr0)            install Kubespy command"
    echo "  $(tput setaf 5)--help$(tput sgr0)           show this message"
    echo
}
