#!/usr/bin/env bash

# Set up fzf key bindings and fuzzy completion
if command_exists fzf; then
	eval "$(fzf --bash)"
fi
