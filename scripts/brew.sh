#!/bin/sh

# Load homebrew
BREW_LOCATION=""
if [ -f /opt/homebrew/bin/brew ]; then
  BREW_LOCATION="/opt/homebrew/bin/brew"
elif [ -f /usr/local/bin/brew ]; then
  BREW_LOCATION="/usr/local/bin/brew"
elif [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
  BREW_LOCATION="/home/linuxbrew/.linuxbrew/bin/brew"
elif [ -f "$HOME/.linuxbrew/bin/brew" ]; then
  BREW_LOCATION="$HOME/.linuxbrew/bin/brew"
else
  return
fi

eval "$("${BREW_LOCATION}" shellenv)"
unset BREW_LOCATION

# Aliases
alias ba='brew autoremove'
alias bc='brew cleanup'
alias bi='brew install'
alias bl='brew list'
alias bo='brew outdated'
alias bu='brew uninstall'
alias bubo='brew update && brew outdated'
alias bubu='bubo && brew upgrade'
alias bupd='brew update'
alias bupg='brew upgrade'

# Function
brews() {
  formulae=$(brew leaves | xargs brew deps --installed --for-each)
  casks=$(brew list --cask 2>/dev/null)

  green="$(tput setaf 2)"
  magenta="$(tput setaf 5)"
  cyan="$(tput setaf 6)"
  bold="$(tput bold)"
  off="$(tput sgr0)"

  printf "%s==>%s %sFormulae%s\n" "$green" "$magenta" "$bold" "$off"
  echo "$formulae" | sed "s/^\(.*\):\(.*\)$/\1${cyan}\2${off}/"
  printf "\n%s==>%s %sCasks%s\n" "$green" "$magenta" "$bold" "$off"
  echo "$casks"
}

brew_exists() {
  brew ls --versions "$@" >/dev/null 2>&1
}
