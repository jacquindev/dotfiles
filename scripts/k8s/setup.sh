#!/bin/sh

title() {
  echo ""
  gum style --foreground="#cba6f7" --align="left" "⦁ $1:"
}

output() {
  PROCESS_NAME=$(gum style --foreground="#89b4fa" --align="left" --bold "$1")
  MESSAGE=$(gum style --foreground="#9399b2" --align="left" --italic " already exists. Skipping...")
  gum join --align="left" --horizontal "$PROCESS_NAME" "$MESSAGE"
  unset PROCESS_NAME MESSAGE
}

success() {
  PROCESS_NAME=$(gum style --foreground="#a6e3a1" --align="left" --bold "✓ $1")
  MESSAGE=$(gum style --foreground="#cdd6f4" --align="left" " installed sucesfully!")
  gum join --align="left" --horizontal "$PROCESS_NAME" "$MESSAGE"
  unset PROCESS_NAME MESSAGE
}

failed() {
  PROCESS_NAME=$(gum style --foreground="#f38ba8" --align="left" --bold "✗ $1")
  MESSAGE=$(gum style --foreground="#a6adc8" --align="left" --strikethrough " installed failed!")
  gum join --align="left" --horizontal "$PROCESS_NAME" "$MESSAGE"
  unset PROCESS_NAME MESSAGE
}

GITHUB="https://github.com/"
ARCH=$(dpkg --print-architecture)
DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'// | tr '[:upper:]' '[:lower:]')
PLATFORM=$(uname | tr '[:upper:]' '[:lower:]')

# Docker Engine
setup_docker() {
  title "Docker Engine"
  if ! command -v docker >/dev/null; then
    sudo apt update -qq >/dev/null 2>&1
    sudo apt install -y -qq ca-certificates curl >/dev/null 2>&1
    sudo install -m 0755 -d /etc/apt/keyrings

    DOCKER_URL="https://download.docker.com/$PLATFORM/$DISTRO"
    DOCKER_ASC="/etc/apt/keyrings/docker.asc"

    sudo curl -fsSL "$DOCKER_URL/gpg" -o "$DOCKER_ASC"
    sudo chmod a+r "$DOCKER_ASC"

    echo \
      "deb [arch=$ARCH signed-by=$DOCKER_ASC] $DOCKER_URL \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
      sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    sudo apt -qq update >/dev/null

    set -- docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    for pkg in "$@"; do
      sudo apt install -y -qq "$pkg" >/dev/null 2>&1
    done
    sudo usermod -aG docker "$USER"
    sudo docker run hello-world >/dev/null 2>&1 && success "docker" || failed "docker"
  else
    output "docker"
  fi
}

setup_cri_dockerd() {
  title "CRI-DOCKERD"
  if ! command -v cri-dockerd >/dev/null; then
    CRI="cri-docker"
    CRI_DOCKER_URL="https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/${CRI}."
    VER=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//g')

    sudo apt install -y -qq wget >/dev/null 2>&1
    wget "${GITHUB}Mirantis/cri-dockerd/releases/download/v${VER}/cri-dockerd-${VER}.${ARCH}.tgz"
    tar xvf "cri-dockerd-${VER}.${ARCH}.tgz"
    sudo mv cri-dockerd/cri-dockerd /usr/local/bin/
    rm -rf cri*
    wget "${CRI_DOCKER_URL}service"
    wget "${CRI_DOCKER_URL}socket"
    sudo mv "${CRI}.socket" "${CRI}.service" /etc/systemd/system/
    sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' "/etc/systemd/system/${CRI}.service"
    sudo systemctl daemon-reload
    sudo systemctl enable "${CRI}.service"
    sudo systemctl enable --now "${CRI}.socket"
    unset CRI CRI_DOCKER_URL VER
    if systemctl status docker | grep -q -i "active (running)"; then success "cri-dockerd"; else failed "cri-dockerd"; fi
  else
    output "cri-dockerd"
  fi
}

# Kubectl
setup_kubectl() {
  title "KUBECTL"
  VER=$(curl -L -s https://dl.k8s.io/release/stable.txt)

  if ! command -v kubectl >/dev/null; then
    if command -v brew >/dev/null; then
      brew install kubectl --quiet
    else
      curl -LO "https://dl.k8s.io/release/${VER}/bin/${PLATFORM}/${ARCH}/kubectl"
      curl -LO "https://dl.k8s.io/release/${VER}/bin/${PLATFORM}/${ARCH}/kubectl.sha256"
      SHA_VALID=$(echo "$(cat kubectl.sha256) kubectl" | sha256sum --check | grep -q OK)
      if $SHA_VALID; then
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        success "kubectl"
      else
        echo "sha256sum: FAILED to validate kubectl."
        failed "kubectl"
        return 0
      fi
      rm -f kubectl kubectl.sha256
      unset SHA_VALID
    fi
  else
    output "kubectl"
  fi

  # kubectl-convert plugin
  if ! command -v kubectl-convert >/dev/null; then
    curl -LO "https://dl.k8s.io/release/${VER}/bin/${PLATFORM}/${ARCH}/kubectl-convert"
    curl -LO "https://dl.k8s.io/release/${VER}/bin/${PLATFORM}/${ARCH}/kubectl-convert.sha256"
    SHA_VALID=$(echo "$(cat kubectl-convert.sha256) kubectl-convert" | sha256sum --check | grep -q OK)
    if $SHA_VALID; then
      sudo install -o root -g root -m 0755 kubectl-convert /usr/local/bin/kubectl-convert
      success "kubectl-convert"
    else
      echo "sha256sum: FAILED to validate kubectl-convert."
      failed "kubectl-convert"
      return 0
    fi
    rm -f kubectl-convert kubectl-convert.sha256
    unset SHA_VALID
  else
    output "kubectl-convert"
  fi

  unset VER
}

setup_minikube() {
  title "MINIKUBE"
  if ! command -v minikube >/dev/null; then
    if command -v brew >/dev/null; then
      brew install minikube --quiet
    else
      curl -LO "https://storage.googleapis.com/minikube/releases/latest/minikube-${PLATFORM}-${ARCH}"
      sudo install "minikube-${PLATFORM}-${ARCH}" /usr/local/bin/minikube && rm -f "minikube-${PLATFORM}-${ARCH}"
    fi
    minikube version >/dev/null && success "minikube" || failed "minikube"
  else
    output "minikube"
  fi
}

setup_helm() {
  title "HELM"
  if ! command -v helm >/dev/null; then
    if command -v brew >/dev/null; then
      brew install helm --quiet
    else
      curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
      chmod 700 get_helm.sh
      ./get_helm.sh
      rm -f get_helm.sh
    fi
    helm version >/dev/null && success "helm" || failed "helm"
  else
    output "helm"
  fi
}

setup_docker
setup_cri_dockerd
setup_kubectl
setup_minikube
setup_helm

echo ""
