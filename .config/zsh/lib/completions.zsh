#!/bin/zsh

[ -d "$ZSH_CACHE_DIR/completions" ] || mkdir -p "$ZSH_CACHE_DIR/completions"

# pipx
if (( ${+commands[pipx]} )); then
  _evalcache register-python-argcomplete pipx
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

if (( ${+commands[pipenv]} )); then
  if [[ ! -f "${ZSH_CACHE_DIR}/completions/_pipenv" ]]; then
    typeset -g -A _comps
    autoload -Uz _pipenv
    _comps[pipenv]=_pipenv
  fi
  _PIPENV_COMPLETE=zsh_source pipenv >| "${ZSH_CACHE_DIR}/completions/_poetry" &|
fi

# docker
if (( ${+commands[docker]} )); then
  if [[ ! -f "${ZSH_CACHE_DIR}/completions/_docker" ]]; then
    typeset -g -A _comps
    autoload -Uz _docker
    _comps[docker]=_docker
  fi
  docker completion zsh >| "${ZSH_CACHE_DIR}/completions/_docker" &|
fi

KUBE_COMMANDS=('kompose' 'kubecm' 'kubeshark' 'kubespy' 'kustomize')
for cmd in "${KUBE_COMMANDS[@]}"; do
  if (( ${+commands[$cmd]} )); then
    if [[ ! -f "${ZSH_CACHE_DIR}/completions/_${cmd}" ]]; then
      typeset -g -A _comps
      autoload -Uz _$cmd
      _comps[$cmd]=_$cmd
    fi
  $cmd completion zsh >| "${ZSH_CACHE_DIR}/completions/_$cmd" &|
  fi
done
unset cmd KUBE_COMMANDS