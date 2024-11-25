#!/bin/sh

# Currently this script only works with Ubuntu/Debian machines.
# Any further modifications are welcomed!!

# Return if kubectl command not found
if ! command -v kubectl >/dev/null 2>&1; then
  echo "$(tput setaf 1)ERROR: Command not found: kubectl. Exiting...$(tput sgr0)"
  return
fi

PREFIX="$HOME/Code/kube"
KUBEBIN="$PREFIX/bin"
GITHUB="https://github.com/"
ARCH=$(dpkg --print-architecture)
MACHINE=$(uname -m)
#DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'// | tr '[:upper:]' '[:lower:]')
PLATFORM=$(uname | tr '[:upper:]' '[:lower:]')

[ ! -d "$PREFIX" ] && mkdir -p "$PREFIX"
[ ! -d "$KUBEBIN" ] && mkdir -p "$KUBEBIN"

if ! command -v gum >/dev/null || ! brew ls --versions gum >/dev/null 2>&1; then
  brew install gum --quiet
fi

command_exists() {
  command -v "$@" >/dev/null
}

git_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")'
}

title() {
  APP_NAME=$(gum style --foreground="#c6a0f6" --align="left" --bold "$1")
  DIVIDER=$(gum style --foreground="#494d64" " │ ")
  DESC=$(gum style --foreground="#74c7ec" --align="left" --italic "$2")
  PLUS=$(gum join --horizontal "$APP_NAME" "$DIVIDER" "$DESC")
  gum style --border-foreground="#89b4fa" --border="rounded" --align="center" --padding="1 2" "$PLUS"
  unset APP_NAME DIVIDER DESC PLUS
}

success() {
  APP_NAME=$(gum style --foreground="#a6e3a1" --align="left" --bold "$1 ")
  DESC=$(gum style --foreground="#cdd6f4" --align="left" "installed successfully.")
  gum join --horizontal "$APP_NAME" "$DESC"
  unset APP_NAME DESC
  echo ""
}

exists() {
  APP_NAME=$(gum style --foreground="#89b4fa" --align="left" "$1 ")
  DESC=$(gum style --foreground="#a6adc8" --align="left" --italic "already installed. Skipping...")
  gum join --horizontal "$APP_NAME" "$DESC"
  unset APP_NAME DESC
  echo ""
}

export PATH="$KUBEBIN:$PATH"

# kompose
kompose_install() {
  title "kompose" "Convert Compose to Kubernetes"
  if ! command_exists kompose; then
    VERSION=$(git_latest_release "kubernetes/kompose")
    curl --silent -L "${GITHUB}kubernetes/kompose/releases/download/${VERSION}/kompose-${PLATFORM}-${ARCH}" -o kompose
    chmod +x kompose
    mv ./kompose "$KUBEBIN/kompose"
    unset VERSION
    success "kompose v$(kompose version | cut -d ' ' -f1)"
  else
    exists "kompose v$(kompose version | cut -d ' ' -f1)"
  fi
}

# kubebox: Terminal and Web console for Kubernetes
kubebox_install() {
  title "kubebox" "Terminal and Web console for Kubernetes"
  if ! command_exists kubebox; then
    VERSION=$(git_latest_release "astefanutti/kubebox")
    if [ "$MACHINE" = "x86_64" ]; then
      curl --silent -Lo kubebox "${GITHUB}astefanutti/kubebox/releases/download/${VERSION}/kubebox-${PLATFORM}"
      chmod +x kubebox
      mv ./kubebox "$KUBEBIN/kubebox"
      unset VERSION
      success "kubebox"
    fi
  else
    exists "kubebox"
  fi
}

# kubecm: KubeConfig Manager
kubecm_install() {
  title "kubecm" "KubeConfig Manager"
  if ! command_exists kubecm; then
    VERSION=$(git_latest_release "sunny0826/kubecm")
    PLATFORM=$(uname)
    curl -sL "${GITHUB}sunny0826/kubecm/releases/download/${VERSION}/kubecm_${VERSION}_${PLATFORM}_${MACHINE}.tar.gz" | tar xz
    rm -f LICENSE README.md
    chmod +x kubecm
    mv ./kubecm "$KUBEBIN/kubecm"
    unset VERSION PLATFORM
    success "kubecm v$(kubecm version | head -n1 | cut -d ' ' -f2)"
  else
    exists "kubecm v$(kubecm version | head -n1 | cut -d ' ' -f2)"
  fi
}

# kubeconform: Kubernetes manifests validator
kubeconform_install() {
  title "kubeconform" "Kubernetes Manifests Validator"
  if ! command_exists kubeconform; then
    VERSION=$(git_latest_release "yannh/kubeconform")
    curl -sL "${GITHUB}yannh/kubeconform/releases/download/${VERSION}/kubeconform-${PLATFORM}-${ARCH}.tar.gz" | tar xz
    rm -f LICENSE
    chmod +x kubeconform
    mv ./kubeconform "$KUBEBIN/kubeconform"
    unset VERSION
    success "kubeconform $(kubeconform -v)"
  else
    exists "kubeconform $(kubeconform -v)"
  fi
}

# kubectx: Switch between kubectl contexts easily and create aliases
kubectx_install() {
  title "kubectx" "Switch between kubectl contexts easily and create aliases"
  if ! command_exists kubectx && ! command_exists kubens; then
    VERSION=$(git_latest_release "ahmetb/kubectx")
    wget -q -P "$KUBEBIN" "${GITHUB}ahmetb/kubectx/releases/download/${VERSION}/kubectx"
    wget -q -P "$KUBEBIN" "${GITHUB}ahmetb/kubectx/releases/download/${VERSION}/kubens"
    chmod +x "$KUBEBIN/kubectx" "$KUBEBIN/kubens"
    unset VERSION
    success "kubectx"
  else
    exists "kubectx"
  fi

  # Completions for zsh shell
  set -- _kubectx _kubens
  for file in "$@"; do
    if [ -n "$ZSH_VERSION" ]; then
      if [ ! -f "$XDG_CACHE_HOME/zsh/completions/$file" ]; then
        wget -O "$XDG_CACHE_HOME/zsh/completions/$file" "https://raw.githubusercontent.com/ahmetb/kubectx/refs/heads/master/completion/$file.zsh"
      fi
    fi
  done
  unset file
}

# kubent: (kube-no-trouble) Check your clusters for use of deprecated APIs
kubent_install() {
  title "kubent" "(kube-no-trouble) Check your clusters for use of deprecated APIs"
  if ! command_exists kubent; then
    VERSION=$(git_latest_release "doitintl/kube-no-trouble")
    curl -sL "${GITHUB}doitintl/kube-no-trouble/releases/download/${VERSION}/kubent-${VERSION}-${PLATFORM}-${ARCH}.tar.gz" | tar xz
    chmod +x kubent
    mv ./kubent "$KUBEBIN/kubent"
    unset VERSION
    success "kubent"
  else
    exists "kubent"
  fi
}

# kubeseal: Encrypt your Secret into a SealedSecret
kubeseal_install() {
  title "kubeseal" "Encrypt your Secret into a SealedSecret"
  if ! command_exists kubeseal; then
    VERSION=$(git_latest_release "bitnami-labs/sealed-secrets" | cut -d 'v' -f2-)
    curl -sL "${GITHUB}bitnami-labs/sealed-secrets/releases/download/v${VERSION}/kubeseal-${VERSION}-${PLATFORM}-${ARCH}.tar.gz" | tar xz
    rm -f LICENSE README.md
    chmod +x kubeseal
    mv ./kubeseal "$KUBEBIN/kubeseal"
    unset VERSION
    success "kubeseal v$(kubeseal --version | cut -d ' ' -f3)"
  else
    exists "kubeseal v$(kubeseal --version | cut -d ' ' -f3)"
  fi
}

# kubeshark: API Traffic Analyzer - providing real-time visibility into Kubernetes network
kubeshark_install() {
  title "kubeshark" "API Traffic Analyzer - providing real-time visibility into Kubernetes network"
  if ! command_exists kubeshark; then
    VERSION=$(git_latest_release "kubeshark/kubeshark")
    curl --silent -Lo kubeshark "${GITHUB}kubeshark/kubeshark/releases/download/${VERSION}/kubeshark_${PLATFORM}_${ARCH}"
    chmod +x kubeshark
    mv ./kubeshark "$KUBEBIN/kubeshark"
    unset VERSION
    success "kubeshark $(kubeshark version)"
  else
    exists "kubeshark $(kubeshark version)"
  fi
}

# kubespy: Tools for observing Kubernetes resources in realtime
kubespy_install() {
  title "kubespy" "Tools for observing Kubernetes resources in realtime"
  if ! command_exists kubespy; then
    VERSION=$(git_latest_release "pulumi/kubespy")
    curl -sL "https://github.com/pulumi/kubespy/releases/download/${VERSION}/kubespy-${VERSION}-${PLATFORM}-${ARCH}.tar.gz" | tar xz
    rm -f LICENSE README.md
    chmod +x kubespy
    mv ./kubespy "$KUBEBIN/kubespy"
    unset VERSION
    success "kubespy $(kubespy version)"
  else
    exists "kubespy $(kubespy version)"
  fi
}

# kustomize: Raw, template-free customizations of YAML manifests
kustomize_install() {
  title "kustomize" "Raw, template-free customizations of YAML manifests"
  if ! command_exists kustomize; then
    VERSION=$(git_latest_release "kubernetes-sigs/kustomize" | cut -d '/' -f2-)
    curl -sL "${GITHUB}kubernetes-sigs/kustomize/releases/download/kustomize%2F${VERSION}/kustomize_${VERSION}_${PLATFORM}_${ARCH}.tar.gz" | tar xz
    chmod +x kustomize
    mv ./kustomize "$KUBEBIN/kustomize"
    unset VERSION
    success "kustomize $(kustomize version)"
  else
    exists "kustomize $(kustomize version)"
  fi
}

echo ""
choose=$(gum choose --header="Choose a Kube Addon to install:" "kompose" "kubebox" "kubecm" "kubeconform" "kubectx" "kubent" "kubeseal" "kubeshark" "kubespy" "kustomize")

case "${choose}" in
kompose) kompose_install ;;
kubebox) kubebox_install ;;
kubecm) kubecm_install ;;
kubeconform) kubeconform_install ;;
kubectx) kubectx_install ;;
kubent) kubent_install ;;
kubeseal) kubeseal_install ;;
kubeshark) kubeshark_install ;;
kubespy) kubespy_install ;;
kustomize) kustomize_install ;;
*) return ;;
esac
