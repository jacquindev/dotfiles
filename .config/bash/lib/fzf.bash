#!/usr/bin/env bash

# Set up fzf key bindings and fuzzy completion
if command -v fzf >/dev/null 2>&1; then
	eval "$(fzf --bash)"
fi
