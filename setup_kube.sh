#!/bin/sh

# shellcheck source-path=SCRIPTDIR
# shellcheck source-path=SCRIPTDIR
here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"
. "$here/scripts/utils.sh"
. "$here/scripts/helpers.sh"

export DOTFILES="$HOME/.dotfiles"
. "$DOTFILES/shared/envs"

install_kubectl() {
    if ! command_exists kubectl; then
        sudo apt update
        check_apt_packages apt-transport-https ca-certificates curl gpg
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key |\
            sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' |\
            sudo tee /etc/apt/sources.list.d/kubernetes.list
        sudo apt update
        check_apt_packages kubelet kubeadm kubectl
        sudo apt-mark hold kubelet kubeadm kubectl
        sudo systemctl enable --now kubelet
    fi

    if ! command_exists kubectx; then
        git clone https://github.com/ahmetb/kubectx "$XDG_DATA_HOME/kubectx"
        sudo ln -s "$XDG_DATA_HOME/kubectx/kubectx" /usr/local/bin/kubectx
        sudo ln -s "$XDG_DATA_HOME/kubectx/kubens" /usr/local/bin/kubens
    fi
}

install_helm() {
    if ! command_exists helm; then
        wget --show-progress --timestamping https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz
        tar xvf helm-v3.16.2-linux-amd64.tar.gz
        sudo mv linux-amd64/helm /usr/local/bin/
        rm -rf linux-amd64 helm-v3.16.2-linux-amd64.tar.gz

        helm plugin install https://github.com/jkroepke/helm-secrets --version v4.6.1
        helm plugin install https://github.com/databus23/helm-diff
    fi 

    if ! command_exists helmfile; then
        wget --show-progress --timestamping https://github.com/helmfile/helmfile/releases/download/v0.168.0/helmfile_0.168.0_linux_amd64.tar.gz
        tar xzf helmfile_0.168.0_linux_amd64.tar.gz
        sudo mv helmfile /usr/local/bin/helmfile
        rm -rf helmfile_* LICENSE README*
    fi

    if ! command_exists helmsman; then
        wget --show-progress --timestamping https://github.com/Praqma/helmsman/releases/download/v3.17.1/helmsman_3.17.1_linux_amd64.tar.gz
        tar xzf helmsman_3.17.1_linux_amd64.tar.gz
        sudo mv helmsman /usr/local/bin/helmsman
        rm -rf helmsman_* LICENSE README.md
    fi

    # info "Add kubernetes-dashboard repository"
    # helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
    # info "Deploy a Helm Release"
    # helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
}

install_krew() {
    if ! command_exists krew; then
        export KREW_ROOT="$XDG_DATA_HOME/krew"
        export PATH="$KREW_ROOT/bin:$PATH"
        (
            set -x; cd "$(mktemp -d)" &&
            OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
            ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
            KREW="krew-${OS}_${ARCH}" &&
            curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
            tar zxvf "${KREW}.tar.gz" &&
            ./"${KREW}" install krew
        )
        if [ -d "$HOME/.krew" ]; then mv "$HOME/.krew" "$XDG_DATA_HOME/krew"; fi
    fi
}

setup_minikube() {
    install_minikube() {
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm -f minikube-linux-amd64
        warning "Starting Minikube..."
        minikube start && (
            minikube addons enable metrics-server 
            minikube addons enable ingress
            minikube addons enable dashboard
        )
        underline "${FMT_ORANGE}Enabled Minikube Addons: ${FMT_RESET}"
        minikube addons list | grep STATUS && minikube addons list | grep enabled

        echo; underline "${FMT_GREEN}Current Status of Minikube: ${FMT_RESET}"
        minikube status
    }

    if ! command_exists minikube; then
        install_minikube
    elif checkyes "Upgrade Minikube?"; then
        info "Delete old Minikube files and reinstall Minikube..."
        minikube delete
        sudo rm -rf /usr/local/bin/minikube
        install_minikube
    fi
}

install_kubectl
install_helm
install_krew
setup_minikube
