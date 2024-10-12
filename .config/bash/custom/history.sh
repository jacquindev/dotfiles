#!/bin/bash

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000
HISTIGNORE="ls:history"
HISTTIMEFORMAT="%d.%m.%Y  %H:%M:%S "

# append to the history file, don't overwrite it
shopt -s histappend

# New history file path
[ -d "$HOME/.cache/bash" ] || mkdir -p "$HOME/.cache/bash"
[ -f "$HOME/.bash_history" ] && mv -i "$HOME/.bash_history" "$HOME/.cache/bash/bash_history"

HISTFILE=/home/$USER/.cache/bash/bash_history
