# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# bashrc
if [ -f "$HOME/.config/bash/bashrc" ]; then
    source "$HOME/.config/bash/bashrc"
fi

# g (Go version manager)
[ -s "${HOME}/.g/env" ] && \. "${HOME}/.g/env" # g shell setup
