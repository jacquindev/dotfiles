if (( ${+commands[mise]} )); then
	if [ -f ~/.local/bin/mise ]; then
		eval "$(~/.local/bin/mise activate zsh)"
	else
		eval "$(mise activate zsh)"
	fi
fi
