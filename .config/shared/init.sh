#!/usr/bin/env bash

[ -f "${HOME}/.config/shared/env.sh" ] && source "${HOME}/.config/shared/env.sh"
[ -f "${HOME}/.config/shared/paths.sh" ] && source "${HOME}/.config/shared/paths.sh"
[ -f "${HOME}/.config/shared/aliases.sh" ] && source "${HOME}/.config/shared/aliases.sh"

if [ -d "${HOME}/.config/shared/functions" ]; then
	for file in "${HOME}/.config/shared/functions/"*; do
		chmod +x "$file"
	done
	pathappend "${HOME}/.config/shared/functions"
fi
