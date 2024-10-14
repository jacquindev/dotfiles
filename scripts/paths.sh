#!/bin/sh

# Function to add to path
# References: - https://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there

pathappend() {
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="${PATH:+"$PATH:"}$1"
  fi
}

pathprepend() {
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="$1${PATH:+":$PATH"}"
  fi
}

# Main bin
[ -d "$HOME/bin" ] && pathprepend "$HOME/bin"
[ -d "$HOME/.local/bin" ] && pathprepend "$HOME/.local/bin"
[ -d /usr/local/sbin ] && pathprepend /usr/local/sbin

# If you're using WSL and you have set /etc/wsl.conf [interop] as
# appendWindowsPath=false, then you can add the path of the program you want
# to use on Windows inside your WSL terminal here:
#
# if [[ "$(uname -r)" =~ "WSL" ]]; then
#   USERPROFILE=$(wslpath "$(wslvar USERPROFILE)")
#   pathprepend "$USERPROFILE/AppData/Local/Programs/Microsoft VS Code/bin"
# fi

#DEV TOOLS #############################################################################
# npm
if command -v npm >/dev/null 2>&1; then pathappend "$(npm config get prefix)/bin"; fi
if command -v pnpm >/dev/null 2>&1; then pathappend "$(pnpm config get prefix)"; fi
if command -v yarn >/dev/null 2>&1; then pathappend "$(yarn global bin)"; fi

# python (pyenv/poetry)
[ -d "$PYENV_ROOT/bin" ] && pathprepend "$PYENV_ROOT/bin"
[ -d "$PYENV_ROOT/shims" ] && pathprepend "$PYENV_ROOT/shims"
[ -d "$PYENV_ROOT/versions/global/bin" ] && pathprepend "$PYENV_ROOT/versions/global/bin"
[ -d "$POETRY_HOME/bin" ] && pathprepend "$POETRY_HOME/bin"

# rbenv
[ -d "$RBENV_ROOT/bin" ] && pathprepend "$RBENV_ROOT/bin"
[ -d "$RBENV_ROOT/shims" ] && pathprepend "$RBENV_ROOT/shims"
[ -d "$RBENV_ROOT/versions/global/bin" ] && pathprepend "$RBENV_ROOT/versions/global/bin"

# rust
[ -f "$CARGO_HOME/env" ] && source "$CARGO_HOME/env"

# go path
if [[ -n $(alias g 2>/dev/null) ]]; then unalias g; fi
[ -d "$GOPATH/bin" ] && pathprepend "$GOPATH/bin"

# custom tool: kinst
# a tool that I wrote for installing Kubernetes binaries ( including Docker and Minikube )
# K-kubernetes, INST-installations
# to see in detail: kinst help
[ -d "$DOTFILES/scripts/kube/bin" ] && pathprepend "$DOTFILES/scripts/kube/bin"
[ -d "$KINST_BIN" ] && pathappend "$KINST_BIN"

# kubescape
[ -d "$XDG_DATA_HOME/kubernetes/kubescape/bin" ] && pathappend "$XDG_DATA_HOME/kubernetes/kubescape/bin"
