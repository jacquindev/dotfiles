#!/bin/bash
# Load bash-preexec
[[ -f "$XDG_CONFIG_HOME/bash/bash-preexec.sh" ]] &&
    source "$XDG_CONFIG_HOME/bash/bash-preexec.sh"

# Source atuin
if command -v atuin >/dev/null 2>&1; then eval "$(atuin init bash)"; fi

# Direnv
if command -v direnv >/dev/null 2>&1; then eval "$(direnv hook bash)"; fi

# Pyenv
if command -v pyenv >/dev/null 2>&1; then
    eval -- "$(pyenv init --path)"
    eval -- "$(pyenv init -)"
    eval -- "$(pyenv virtualenv-init - bash)"
fi

# Rbenv
if command -v rbenv >/dev/null 2>&1; then 
    eval "$(rbenv init - bash)";
    eval "$(rbenv init - --no-rehash bash)"
fi