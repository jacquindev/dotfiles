# Profiling
zmodload zsh/zprof

# Custom prompt
if (( ${+commands[oh-my-posh]} )); then
	eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/tokyonight_storm.omp.json)"
  source <(oh-my-posh completion zsh)
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
