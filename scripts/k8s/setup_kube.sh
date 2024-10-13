#!/bin/sh

export DOTFILES="$HOME/.dotfiles"
. "$DOTFILES/scripts/envs.sh"
. "$DOTFILES/scripts/paths.sh"
. "$DOTFILES/scripts/helpers.sh"

[ ! -d "$XDG_DATA_HOME/kubernetes" ] && mkdir -p "$XDG_DATA_HOME/kubernetes"

# Kubectl, Kubelet, Kubeadm
setup_kubectl() {
    if ! command_exists kubectl; then
        sudo apt update
        check_apt_packages apt-transport-https ca-certificates curl gpg
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key |
            sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' |
            sudo tee /etc/apt/sources.list.d/kubernetes.list
        sudo apt update
        check_apt_packages kubelet kubeadm kubectl
        sudo apt-mark hold kubelet kubeadm kubectl
        sudo systemctl enable --now kubelet
    fi

    if ! command_exists kubectx; then
        git clone https://github.com/ahmetb/kubectx "$XDG_DATA_HOME/kubernetes/kubectx"
        sudo ln -s "$XDG_DATA_HOME/kubernetes/kubectx/kubectx" /usr/local/bin/kubectx
        sudo ln -s "$XDG_DATA_HOME/kubernetes/kubectx/kubens" /usr/local/bin/kubens
    fi
}

# Krew (Kubectl Plugin Manager)
setup_krew() {
    if ! command_exists kubectl-krew; then
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
        echo "Adding completion for kubectl krew..."
        echo '#!/bin/sh\nkubectl krew __complete "$@"' >"$KREW_ROOT/bin/kubectl_complete-krew"
        chmod u+x "$KREW_ROOT/bin/kubectl_complete-krew"
    else
        info "Upgrading Krew and Kubectl's plugins (if they exist)..."
        kubectl krew upgrade
        echo
        underline "${FMT_GREEN}Krew Information: ${FMT_RESET}"
        kubectl krew version
        echo
    fi
}

# Minikube
setup_minikube() {
    install_minikube() {
        info "Installing Minikube..."
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm -f minikube-linux-amd64
        echo
        warning "Starting Minikube..."
        minikube start
        minikube addons enable metrics-server
        minikube addons enable ingress
        minikube addons enable dashboard
        echo
        underline "${FMT_ORANGE}Enabled Minikube Addons: ${FMT_RESET}"
        minikube addons list | grep STATUS && minikube addons list | grep enabled

        echo
        underline "${FMT_GREEN}Current Status of Minikube: ${FMT_RESET}"
        minikube status
    }

    if ! command_exists minikube; then
        install_minikube
    elif command_exists minikube && checkyes "Upgrade Minikube?"; then
        info "Delete old Minikube files and reinstall Minikube..."
        minikube delete
        sudo rm -rf /usr/local/bin/minikube
        sleep 3
        install_minikube
    fi
}

# install_sops() {
#     if ! command_exists sops; then
#         info "Installing SOPS (Secrets OPerationS)..."
#         curl -LO https://github.com/getsops/sops/releases/download/v3.9.1/sops-v3.9.1.linux.amd64
#         sudo mv sops-v3.9.1.linux.amd64 /usr/local/bin/sops
#         chmod +x /usr/local/bin/sops
#     fi
# }

# Helm
setup_helm() {
    if ! command_exists helm; then
        info "Installing Helm..."
        wget --show-progress --timestamping https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz
        tar xvf helm-v3.16.2-linux-amd64.tar.gz
        sudo mv linux-amd64/helm /usr/local/bin/
        rm -rf linux-amd64 helm-v3.16.2-linux-amd64.tar.gz

        info "Adding Helm plugin:"
        helm plugin install https://github.com/adamreese/helm-env
        helm plugin install https://github.com/aslafy-z/helm-git --version 1.3.0
        helm plugin install https://github.com/databus23/helm-diff
        helm plugin install https://github.com/hayorov/helm-gcs
        helm plugin install https://github.com/hypnoglow/helm-s3
        helm plugin install https://github.com/jkroepke/helm-secrets --version v4.6.1
        echo
    fi

    if ! command_exists helmfile; then
        info "Installing Helmfile..."
        wget --show-progress --timestamping https://github.com/helmfile/helmfile/releases/download/v0.168.0/helmfile_0.168.0_linux_amd64.tar.gz
        tar xzf helmfile_0.168.0_linux_amd64.tar.gz
        sudo mv helmfile /usr/local/bin/helmfile
        rm -rf helmfile_* LICENSE README*
        echo
    fi

    if ! command_exists helmsman; then
        info "Installing Helmsman..."
        wget --show-progress --timestamping https://github.com/Praqma/helmsman/releases/download/v3.17.1/helmsman_3.17.1_linux_amd64.tar.gz
        tar xzf helmsman_3.17.1_linux_amd64.tar.gz
        sudo mv helmsman /usr/local/bin/helmsman
        rm -rf helmsman_* LICENSE README.md
        echo
    fi

    # info "Add kubernetes-dashboard repository"
    # helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
    # info "Deploy a Helm Release"
    # helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
}

setup_kubectl
setup_krew
setup_minikube
# install_sops
setup_helm
