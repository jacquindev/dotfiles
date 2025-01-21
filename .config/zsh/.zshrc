# Profiling
zmodload zsh/zprof

# Homebrew
source "$DOTFILES/shared/brew.sh"
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
autoload -Uz compinit
compinit

# Custom prompt
if (( ${+commands[oh-my-posh]} )); then
	eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/tokyonight_storm.omp.json)"
  source <(oh-my-posh completion zsh)
elif (( ${+commands[starship]} )); then
	eval "$(starship init zsh)"
fi

# Forgit
if brew ls --versions forgit >/dev/null 2>&1; then
	source "$(brew --prefix)/share/forgit/forgit.plugin.zsh"
fi

# zsh-nvm settings
export NVM_DIR="$XDG_DATA_HOME/nvm"
export NVM_COMPLETION=true
export NVM_LAZY_LOAD=true
export NVM_LAZY_LOAD_EXTRA_COMMANDS=('vim' 'nvim')
export NVM_NO_USE=true

# Lib files
if [ -d "$ZDOTDIR/lib" ]; then
	for file in "$ZDOTDIR/lib/"*.zsh; do
		source "$file"
	done
	unset file
fi
