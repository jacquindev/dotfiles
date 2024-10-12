[ -d "$ZSH_CACHE_DIR/completions" ] || mkdir -p "$ZSH_CACHE_DIR/completions"

# List of commands
LOCAL_COMMANDS=(
    docker 
    helm 
    helmfile 
    kubectl 
    minikube 
)
for command in ${LOCAL_COMMANDS[@]}; do
    if [[ ${+commands[$command]} ]] && ! brew ls --versions "$command" >/dev/null 2>&1; then
        if [[ ! -f "${ZSH_CACHE_DIR}/completions/_${command}" ]]; then
            typeset -g -A _comps
            autoload -Uz _${command}
            _comps[$command]=_${command}
        fi
        "$command" completion zsh >| "${ZSH_CACHE_DIR}/completions/_${command}" &|
    fi
    unset command
done

# kubectx & kubens
KUBECTX_FILES=(
    "$XDG_DATA_HOME/kubernetes/kubectx/completion/_kubectx.zsh"
    "$XDG_DATA_HOME/kubernetes/kubectx/completion/_kubens.zsh"
)
for file in ${KUBECTX_FILES[@]}; do
    filename=$(basename $file)
    if [[ ! -L "${ZSH_CACHE_DIR}/completions/${filename}" ]]; then
        ln -s "$file" "${ZSH_CACHE_DIR}/completions/${filename}"
    fi
    unset file
done

# poetry
if [[ ${+commands[poetry]} ]] && ! brew ls --versions poetry &>/dev/null; then
    if [[ ! -f "${ZSH_CACHE_DIR}/completions/_poetry" ]]; then
        typeset -g -A _comps
        autoload -Uz _poetry
        _comps[poetry]=_poetry
    fi
    poetry completions zsh >| "${ZSH_CACHE_DIR}/completions/_poetry" &|
fi

# pyenv
if [[ ${+commands[pyenv]} ]] && ! brew ls --versions pyenv &>/dev/null; then
    if [[ -f "$PYENV_ROOT/completions/pyenv.zsh" ]]; then
        source "$PYENV_ROOT/completions/pyenv.zsh"
    fi
fi 

# rbenv
if [[ ${+commands[rbenv]} ]] && ! brew ls --versions rbenv &>/dev/null; then
    FPATH="$RBENV_ROOT/completions:$FPATH"
fi