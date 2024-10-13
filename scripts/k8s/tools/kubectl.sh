#!/bin/sh

export DOTFILES="$HOME/.dotfiles"
. "$DOTFILES/scripts/helpers.sh"

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
            echo
            echo "$(cat kubectl-convert.sha256) kubectl-convert" | sha256sum --check
            sudo install -o root -g root -m 0755 kubectl-convert /usr/local/bin/kubectl-convert
            rm -f kubectl-convert kubectl-convert.sha256
        else
            warning "Already installed kubectl-convert plugin!"
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
    else
        warning "Krew already installed!"
    fi
}

kube_help() {
    echo
    echo "$(tput setaf 2)==> $(tput setaf 220)Parameters:"
    echo
    echo "  $(tput setaf 5)--install$(tput sgr0)        install Kubectl"
    echo "  $(tput setaf 5)--convert$(tput sgr0)        install Kubectl-Convert plugin"
    echo "  $(tput setaf 5)--kubectx$(tput sgr0)        install Kubectx and Kubens"
    echo "  $(tput setaf 5)--krew$(tput sgr0)           install Krew (Kubectl Plugin Manager)"
    echo "  $(tput setaf 5)--help$(tput sgr0)           show this message"
    echo
}
