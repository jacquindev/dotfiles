#!/bin/sh

pathappend() {
	if ! echo "$PATH" | /bin/grep -Eq "(^|:)$1($|:)" && [ -d "$1" ]; then
		export PATH="$PATH:$1"
	fi
}

pathprepend() {
	if ! echo "$PATH" | /bin/grep -Eq "(^|:)$1($|:)" && [ -d "$1" ]; then
		export PATH="$1:$PATH"
	fi
}

# Main bin
pathprepend "$HOME/bin"
pathprepend "$HOME/.local/bin"
pathprepend "/usr/local/sbin"
pathprepend "/usr/bin"
