# Profiling
zmodload zsh/zprof

# Custom prompt
if (( ${+commands[oh-my-posh]} )); then
	eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/tokyonight_storm.omp.json)"
elif (( ${+commands[starship]} )); then
	eval "$(starship init zsh)"
fi

# Lib files
if [ -d "$ZDOTDIR/lib" ]; then
	for file in "$ZDOTDIR/lib/"*.zsh; do
		source "$file"
	done
	unset file
fi

# Custom completion files
if [ -d "$HOME/.config/zsh/completions" ]; then
	fpath+=$HOME/.config/zsh/completions
fi

# Set up fzf key bindings and fuzzy completion
if (( ${+commands[fzf]} )); then
	source <(fzf --zsh)
fi

# zoxide
if (( ${+commands[zoxide]} )); then
	eval "$(zoxide init zsh --cmd cd)"
fi
