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

# NVM
export NVM_COMPLETION=true
export NVM_LAZY_LOAD=true
export NVM_LAZY_LOAD_EXTRA_COMMANDS=('vim' 'nvim')
export NVM_AUTO_USE=true

# Lib files
if [ -d "$ZDOTDIR/lib" ]; then
    for file in "$ZDOTDIR/lib/"*.zsh; do
        source "$file"
    done
    unset file
fi
