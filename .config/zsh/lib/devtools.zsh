#!/bin/zsh
# atuin
if [[ ${+commands[atuin]} ]]; then _evalcache atuin init zsh; fi

# direnv
if [[ ${+commands[direnv]} ]]; then _evalcache direnv hook zsh; fi

# pyenv
if [[ ${+commands[pyenv]} ]]; then
    _evalcache pyenv init - --no-rehash zsh
    _evalcache pyenv virtualenv-init - zsh
fi

# rbenv
if [[ ${+commands[rbenv]} ]]; then
    _evalcache rbenv init - --no-rehash zsh
fi