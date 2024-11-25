# xdg
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_BIN_HOME="$HOME/.local/bin"
export XDG_RUNTIME_DIR="$HOME/.xdg"
export XDG_PROJECTS_DIR="$HOME/Projects"

# zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# ripgrep
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"

# wget
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"

# less
export LESSHISTFILE="$XDG_CACHE_HOME/less/lesshsts"

# nvm
export NVM_DIR="$HOME/Code/nvm"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export npm_config_cache="$XDG_CACHE_HOME/npm"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export YARN_CACHE_FOLDER="$XDG_CACHE_HOME/npm"

# python
export PYENV_ROOT="$HOME/Code/pyenv"

# rbenv
export RBENV_ROOT="$HOME/Code/rbenv"

# rust
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$HOME/Code/cargo"

# go
export GOROOT="$HOME/.local/share/go"
export GOPATH="$HOME/Code/go"
