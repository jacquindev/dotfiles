#!/usr/bin/env bash

if command -v mise >/dev/null 2>&1; then
	if [ -f ~/.local/bin/mise ]; then
		eval "$(~/.local/bin/mise activate bash)"
	else
		eval "$(mise activate bash)"
	fi
fi
