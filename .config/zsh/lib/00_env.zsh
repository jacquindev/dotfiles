# xdg
export XDG_CONFIG_DIRS="/etc/xdg"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_BIN_HOME="$HOME/.local/bin"
export XDG_RUNTIME_DIR="$HOME/.xdg"
export XDG_PROJECTS_DIR="$HOME/projects"

# zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZSH_DATA_DIR="$XDG_DATA_HOME/zsh"
export ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"

# Homebrew
# Disable homebrew auto-update for faster homebrew loading
export HOMEBREW_NO_AUTO_UPDATE=1

# ripgrep
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"

# less
export LESSHISTFILE="$XDG_CACHE_HOME/.lesshsts"

# wget
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"

# nvm
export NVM_DIR="$XDG_DATA_HOME/nvm"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export npm_config_cache="$XDG_CACHE_HOME/npm"
export YARN_CACHE_FOLDER="$XDG_CACHE_HOME/npm"
