export DOTFILES="$HOME/dotfiles"

[ -f "$DOTFILES/scripts/envs.sh" ] && source "$DOTFILES/scripts/envs.sh"
[ -f "$DOTFILES/scripts/paths.sh" ] && source "$DOTFILES/scripts/paths.sh"

export ZSH_DATA_DIR="$XDG_DATA_HOME/zsh"
export ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
export ZSH_EVALCACHE_DIR="$ZSH_CACHE_DIR/evalcache"

mkdir -p "$ZSH_DATA_DIR" "$ZSH_CACHE_DIR" "$ZSH_EVALCACHE_DIR"

skip_global_compinit=1
