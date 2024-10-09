#!/bin/bash

# completion
if type brew &>/dev/null; then
    HOMEBREW_PREFIX="$(brew --prefix)"
    if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
        source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
    else
        for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
            [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
        done
    fi
    unset COMPLETION
fi

# forgit
[ -f "$HOMEBREW_PREFIX/share/forgit/forgit.plugin.sh" ] &&
    source "$HOMEBREW_PREFIX/share/forgit/forgit.plugin.sh"
