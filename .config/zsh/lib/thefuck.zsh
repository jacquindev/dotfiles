#!/usr/bin/env zsh

if (( ${+commands[thefuck]} )); then
	eval "$(thefuck --alias --enable-experimental-instant-mode)"
fi
