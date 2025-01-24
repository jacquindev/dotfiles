#!/usr/env/bin zsh

# Extra setup for zsh shell
source "$HOME/dotfiles.sh"

SHARED_DIR="$DOTFILES/shared"
set -o allexport && source "$SHARED_DIR/.env" && set +o allexport
source "$SHARED_DIR/path.sh"
source "$SHARED_DIR/brew.sh"

PLUGIN_FILE="$ZDOTDIR/.zsh_plugins"
ZSHRC="$ZDOTDIR/.zshrc"

# zsh-nvm plugins
if [ -f "$NVM_DIR/nvm.sh" ] && ! grep -q 'lukechilds/zsh-nvm' "$PLUGIN_FILE"; then
	echo 'lukechilds/zsh-nvm' >>"$PLUGIN_FILE"
fi

# zsh-sdkman
if [ -f "$SDKMAN_DIR/bin/sdkman-init.sh" ] && ! grep -q 'ptavares/zsh-sdkman' "$PLUGIN_FILE"; then
	echo 'ptavares/zsh-sdkman' >>"$PLUGIN_FILE"
fi
