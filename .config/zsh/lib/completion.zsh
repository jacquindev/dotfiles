#!/bin/zsh

[ -d "$ZSH_CACHE_DIR/completions" ] || mkdir -p "$ZSH_CACHE_DIR/completions"

# pipx
if (( ${+commands[pip]} )); then
  if [[ ! -f "${ZSH_CACHE_DIR}/completions/_pip" ]]; then
    typeset -g -A _comps
    autoload -Uz _pip
    _comps[pip]=_pip
  fi
  pip completion --zsh >| "${ZSH_CACHE_DIR}/completions/_pip" &|
 fi

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

# docker
if (( ${+commands[docker]} )); then
  if [[ ! -f "${ZSH_CACHE_DIR}/completions/_docker" ]]; then
    typeset -g -A _comps
    autoload -Uz _docker
    _comps[docker]=_docker
  fi
  docker completion zsh >| "${ZSH_CACHE_DIR}/completions/_docker" &|
fi