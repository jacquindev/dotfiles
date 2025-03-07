#!/usr/bin/env zsh

if uname -r | grep -q microsoft; then
	export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"

	if command -v wslvar >/dev/null 2>&1; then
		vagrant_windows_path=$(wslpath "$(wslvar USERPROFILE)")
		export VAGRANT_WSL_WINDOWS_ACCESS_USER_HOME_PATH="${vagrant_windows_path}/"
	fi
fi
