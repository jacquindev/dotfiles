# Profiling
zmodload zsh/zprof

# shared folder
[ -f "${HOME}/.config/shared/init.sh" ] && source "${HOME}/.config/shared/init.sh"

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

[ -d "${ZDOTDIR}/functions" ] && fpath+=${ZDOTDIR}/functions
[ -d "${ZDOTDIR}/completions" ] && fpath+=${ZDOTDIR}/completions
autoload -Uz compinit && compinit

# kubectl aliases
# - https://github.com/ahmetb/kubectl-aliases
if [ -f "${XDG_CONFIG_HOME}/shared/.kubectl_aliases" ]; then
	source "${XDG_CONFIG_HOME}/shared/.kubectl_aliases"
fi

# zoxide
if (( ${+commands[zoxide]} )); then
	eval "$(zoxide init zsh --cmd cd)"
fi
