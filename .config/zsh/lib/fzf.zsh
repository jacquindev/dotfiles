#!/usr/bin/env zsh

if (( ${+commands[fzf]} )); then
	source <(fzf --zsh)
fi
