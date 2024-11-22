# Profiling
zmodload zsh/zprof

# Homebrew
[ -f "$DOTFILES/scripts/brew.sh" ] && source "$DOTFILES/scripts/brew.sh"

# fpath
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
autoload -Uz compinit
compinit

# oh-my-posh
if command -v oh-my-posh >/dev/null 2>&1; then
  eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/tokyonight_storm.omp.json)"
  source <(oh-my-posh completion zsh)
fi

# forgit
if brew ls --versions forgit >/dev/null 2>&1; then
  source "$(brew --prefix)/share/forgit/forgit.plugin.zsh"
fi

# Shared files
if [ -d "$DOTFILES/scripts/shared" ]; then
  for file in "$DOTFILES/scripts/shared/"*; do source "$file"; done
  unset file
fi

# Lib files
if [ -d "$ZDOTDIR/lib" ]; then
  for file in "$ZDOTDIR/lib/"*.zsh; do source "$file"; done
  unset file
fi
