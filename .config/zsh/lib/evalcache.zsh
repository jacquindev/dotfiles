#!/bin/zsh

# atuin
if (( ${+commands[atuin]} )); then
  _evalcache atuin init zsh
fi

# pyenv
if (( ${+commands[pyenv]} )) && [[ "${commands[pyenv]}" != */pyenv-win/* && "$(uname -r)" != *icrosoft* ]]; then
	_evalcache pyenv init - --no-rehash zsh
  _evalcache pyenv virtualenv-init - zsh
fi
