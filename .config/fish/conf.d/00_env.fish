# xdg
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_STATE_HOME $HOME/.local/state
set -gx XDG_BIN_HOME $HOME/.local/bin
set -gx XDG_RUNTIME_DIR $HOME/.xdg
set -gx XDG_PROJECTS_DIR $HOME/projects

# Disable homebrew auto-update for faster homebrew loading
set -gx HOMEBREW_NO_AUTO_UPDATE 1

# ripgrep
set -gx RIPGREP_CONFIG_PATH $XDG_CONFIG_HOME/ripgrep/config

# less
set -gx LESSHISTFILE $XDG_CACHE_HOME/.lesshsts

# wgetee
set -gx WGETRC $XDG_CONFIG_HOME/wget/wgetrc
