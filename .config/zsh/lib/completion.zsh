#!/bin/zsh

[ -d "$ZSH_CACHE_DIR/completions" ] || mkdir -p "$ZSH_CACHE_DIR/completions"

# pyenv
if (( ${+commands[pyenv]} )); then
    [[ -f "$PYENV_ROOT/completions/pyenv.zsh" ]] && source "$PYENV_ROOT/completions/pyenv.zsh"
fi

# poetry
if (( ${+commands[poetry]} )); then
    if [[ ! -f "${ZSH_CACHE_DIR}/completions/_poetry" ]]; then
        typeset -g -A _comps
        autoload -Uz _poetry
        _comps[poetry]=_poetry
    fi
    poetry completions zsh >| "${ZSH_CACHE_DIR}/completions/_poetry" &|
fi

# poe
if (( ${+commands[poe]} )); then
    if [[ ! -f "${ZSH_CACHE_DIR}/completions/_poe" ]]; then
        typeset -g -A _comps
        autoload -Uz _poe
        _comps[poe]=_poe
    fi
    poe _zsh_completion >| "${ZSH_CACHE_DIR}/completions/_poe" &|
fi

# rbenv
if (( ${+commands[rbenv]} )); then
    FPATH="$RBENV_ROOT/completions:$FPATH"
fi

# Kubectx and Kubens
if (( ${+commands[kubectx]} )); then
    KUBECTX_FILES=(
        "$KINST_LOCATION/kubectx/completion/_kubectx.zsh"
        "$KINST_LOCATION/kubectx/completion/_kubens.zsh"
    )
    for file in ${KUBECTX_FILES[@]}; do
        if [[ ! -f "$file" ]]; then return; fi
        filename=$(basename $file)
        if [[ ! -L "${ZSH_CACHE_DIR}/completions/${filename}" ]]; then
            ln -s "$file" "${ZSH_CACHE_DIR}/completions/${filename}"
        fi
    done
    unset KUBECTX_FILES file
fi

# List of commands
LOCAL_COMMANDS=(
    docker 
    helm 
    helmfile
    kubectl
    kubeadm
    kompose
    kubebuilder
    kubecm
    kubescape
    kubeshark
    kubespy
    minikube 
)
for command in ${LOCAL_COMMANDS[@]}; do
    if (( ${+commands[$command]} )); then 
        if [[ ! -f "${ZSH_CACHE_DIR}/completions/_${command}" ]]; then
            typeset -g -A _comps
            autoload -Uz _${command}
            _comps[$command]=_${command}
        fi
        "$command" completion zsh >| "${ZSH_CACHE_DIR}/completions/_${command}" &|
    fi
done
unset LOCAL_COMMANDS command
