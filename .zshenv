#!/usr/bin/env zsh

# Get dotfiles directory
[ -f "$HOME/dotfiles.sh" ]; then source "$HOME/dotfiles.sh"; fi

# Environment variables & Paths
set -o allexport && source "$DOTFILES/shared/.env" && set +o allexport
source "$DOTFILES/shared/path.sh"

skip_global_compinit=1
