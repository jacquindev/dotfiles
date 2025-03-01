# Setup antidote
export ZSH_CUSTOM="$ZDOTDIR"
export ANTIDOTE_HOME="$XDG_DATA_HOME/zsh/antidote"

[[ -d "$ANTIDOTE_HOME" ]] || git clone --depth 1 --quiet https://github.com/mattmc3/antidote "$ANTIDOTE_HOME"

# Lazy-load antidote from its functions directory.
fpath=($ANTIDOTE_HOME/functions $fpath)
autoload -Uz antidote

# Generate .zsh_plugins file
zsh_plugins="$ZDOTDIR/.zsh_plugins"
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins} ]] || [[ ! -e "$ANTIDOTE_HOME/.lastupdated" ]]; then
	antidote bundle <${zsh_plugins} >|${zsh_plugins}.zsh
	date +%Y-%m-%dT%H:%M:%S%z >|$ANTIDOTE_HOME/.lastupdated
fi

# Source static file
source ${zsh_plugins}.zsh
