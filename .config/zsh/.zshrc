# Profiling
zmodload zsh/zprof

# Homebrew
[ -f "$DOTFILES/shared/brew" ] && source "$DOTFILES/shared/brew"

# Oh-my-zsh
if [[ ${+commands[oh-my-posh]} ]]; then
    eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/tokyonight_storm.omp.json)"
fi

# Shared files
if [ -d "$DOTFILES/shared/config" ]; then
    for file in "$DOTFILES/shared/config/"*; do
        source "$file"
    done
    unset file
fi

# Lib files
if [ -d "$ZDOTDIR/lib" ]; then
    for file in "$ZDOTDIR/lib/"*.zsh; do
        source "$file"
    done
    unset file
fi

# go version manager
if [ -f "$HOME/.g/env" ]; then source "$HOME/.g/env"; fi