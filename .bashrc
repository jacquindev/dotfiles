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

# Unalias g
if [[ -n $(alias g 2>/dev/null) ]]; then unalias g; fi

# Added by `rbenv init` on Mon Oct 21 08:59:05 +07 2024
eval "$(rbenv init - --no-rehash bash)"
