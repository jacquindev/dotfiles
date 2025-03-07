#!/bin/bash

if command -v code >/dev/null 2>&1; then return; fi

if uname -r | grep -q microsoft; then
	if command -v wslvar >/dev/null 2>&1; then
		windows_user_home="$(wslpath "$(wslvar USERPROFILE)")"

		if [ -d "$windows_user_home/AppData/Local/Programs/Microsoft VS Code/bin" ]; then
			pathprepend "$windows_user_home/AppData/Local/Programs/Microsoft VS Code/bin"
		fi

		unset windows_user_home
	fi
fi
