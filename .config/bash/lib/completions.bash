#!/bin/bash

BASH_COMPLETION_DIR="$XDG_DATA_HOME/bash_completion.d"
if [ ! -d "$BASH_COMPLETION_DIR" ]; then mkdir -p "$BASH_COMPLETION_DIR"; fi

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

# pip
if command_exists pip; then
  if [ ! -f "$BASH_COMPLETION_DIR/pip" ]; then
    wget -q -P "$BASH_COMPLETION_DIR" https://raw.githubusercontent.com/brunobeltran/pip-bash-completion/refs/heads/master/pip
  fi
fi

# pipx
if command_exists pipx; then
  eval "$(register-python-argcomplete pipx)"
fi

# poetry
if command_exists poetry; then
  if [ ! -f "$BASH_COMPLETION_DIR/poetry" ]; then
    poetry completions bash >"$BASH_COMPLETION_DIR/poetry"
  fi
fi

# kube related
KUBE_COMMANDS=('kompose' 'kubecm' 'kubeshark' 'kubespy' 'kustomize')
for cmd in "${KUBE_COMMANDS[@]}"; do
  if command_exists "$cmd"; then
    if [ ! -f "$BASH_COMPLETION_DIR/$cmd" ]; then
      $cmd completion zsh >"$BASH_COMPLETION_DIR/$cmd"
    fi
  fi
done
unset cmd KUBE_COMMANDS

# source files
for file in "$BASH_COMPLETION_DIR"/*; do \. "$file"; done
unset file
