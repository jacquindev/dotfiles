#!/bin/zsh

# atuin
if (( ${+commands[atuin]} )); then
  _evalcache atuin init zsh
fi

# pyenv
if (( ${+commands[pyenv]} )); then
	_evalcache pyenv init - --no-rehash zsh
  _evalcache pyenv virtualenv-init - zsh
fi
