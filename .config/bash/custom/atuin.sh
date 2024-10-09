# Load bash-preexec
[[ -f "$XDG_CONFIG_HOME/bash/bash-preexec.sh" ]] &&
    source "$XDG_CONFIG_HOME/bash/bash-preexec.sh"

# Source atuin
if command -v atuin &>/dev/null; then
    eval "$(atuin init bash)"
fi
