#!/bin/zsh
# atuin
if [[ ${+commands[atuin]} ]]; then _evalcache atuin init zsh; fi

# direnv
if [[ ${+commands[direnv]} ]]; then _evalcache direnv hook zsh; fi

# pyenv
if [[ ${+commands[pyenv]} ]]; then
    _evalcache pyenv init - --no-rehash zsh
    _evalcache pyenv virtualenv-init - zsh

    FPATH="$PYENV_ROOT/completions:$FPATH"
    autoload -Uz compinit
    compinit
fi

# rbenv
if [[ ${+commands[rbenv]} ]]; then
    _evalcache rbenv init - --no-rehash zsh

    FPATH="$RBENV_ROOT/completions:$FPATH"
    autoload -Uz compinit
    compinit
fi

# Kubectl
if [[ ${commands[kubectl]} ]]; then source <(kubectl completion zsh); fi

# Minikube
if [[ ${commands[minikube]} ]]; then source <(minikube completion zsh); fi