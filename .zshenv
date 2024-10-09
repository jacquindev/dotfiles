export DOTFILES="$HOME/.dotfiles"

[ -f "$DOTFILES/shared/envs" ] && source "$DOTFILES/shared/envs"
[ -f "$DOTFILES/shared/paths" ] && source "$DOTFILES/shared/paths"

export ZSH_DATA_DIR="$XDG_DATA_HOME/zsh"
export ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
export ZSH_EVALCACHE_DIR="$ZSH_CACHE_DIR/evalcache"
mkdir -p "$ZSH_DATA_DIR" "$ZSH_CACHE_DIR" "$ZSH_EVALCACHE_DIR"

skip_global_compinit=1
