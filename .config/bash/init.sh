#!/bin/bash

# shellcheck disable=1090,1091

if [ -f "$HOME/.config/path_add.sh" ]; then
	source "$HOME/.config/path_add.sh"
fi

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

for file in "${SCRIPT_DIR}/lib/"*.bash; do
	source "$file"
done

unset SCRIPT_DIR
