#!/usr/bin/env zsh

if uname -r | grep -q microsoft; then
	export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
	export VAGRANT_WSL_WINDOWS_ACCESS_USER_HOME_PATH="/mnt/c/vagrant_home/"
fi
