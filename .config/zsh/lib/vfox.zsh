#!/usr/bin/env zsh

if (($ + commands[vfox])); then
	eval "$(vfox activate zsh)"
fi
