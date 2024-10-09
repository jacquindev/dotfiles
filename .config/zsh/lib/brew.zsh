#!/bin/zsh

# completion
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

    autoload -Uz compinit
    compinit
fi

# forgit
[ -f $HOMEBREW_PREFIX/share/forgit/forgit.plugin.zsh ] &&
    source $HOMEBREW_PREFIX/share/forgit/forgit.plugin.zsh
