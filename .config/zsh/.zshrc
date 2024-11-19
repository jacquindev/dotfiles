# Profiling
zmodload zsh/zprof

# Homebrew
[ -f "$DOTFILES/scripts/brew.sh" ] && source "$DOTFILES/scripts/brew.sh"

# Oh-my-posh
if [[ ${+commands[oh-my-posh]} ]]; then
  eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/tokyonight_storm.omp.json)"
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
