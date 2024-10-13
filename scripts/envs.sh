#!/bin/sh
#xdg
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_BIN_HOME="$HOME/.local/bin"
export XDG_RUNTIME_DIR="$HOME/.xdg"
export XDG_PROJECTS_DIR="$HOME/Projects"

# zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# editor
export EDITOR='nvim'
export GIT_EDITOR='nvim'

# gnupg
export GNUPGHOME="$XDG_DATA_HOME/gnupg"

# wget
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"

# less
export LESSKEY="$XDG_CONFIG_HOME/less/lesskey"
export LESSHISTFILE="$XDG_CACHE_HOME/less/lesshsts"

# ripgrep
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"

# nvm
export NVM_DIR="$XDG_DATA_HOME/nvm"
export NODE_REPL_HISTORY="$XDG_CACHE_HOME/node_repl_history"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export npm_config_cache="$XDG_CACHE_HOME/npm"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"

export NVM_NO_USE=true
export NVM_AUTO_USE=true
export NVM_COMPLETION=true
export NVM_LAZY_LOAD=true
export NVM_LAZY_LOAD_EXTRA_COMMANDS=('vim' 'nvim' 'git-open' 'git-recent')

# python
export PYENV_ROOT="$XDG_DATA_HOME/pyenv"
export POETRY_HOME="$XDG_DATA_HOME/pypoetry"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc.py"

# rust
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"

# ruby
export RBENV_ROOT="$XDG_DATA_HOME/rbenv"
export GEM_HOME="$XDG_DATA_HOME/gem"
export GEM_SPEC_CACHE="$XDG_CACHE_HOME/gem"
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME/bundle"
export BUNDLE_USER_CACHE="$XDG_CACHE_HOME/bundle"
export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME/bundle"

# g (go version manager)
export GOPATH="$XDG_DATA_HOME/go"

# krew
export KREW_ROOT="$XDG_DATA_HOME/kubernetes/krew"