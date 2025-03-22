#!/usr/bin/env bash

if command_exists thefuck; then
	eval "$(thefuck --alias --enable-experimental-instant-mode)"
fi
