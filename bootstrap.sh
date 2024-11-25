#!/bin/bash

# shellcheck disable=SC2181
# shellcheck source-path=SCRIPTDIR
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

. "$DOTFILES/scripts/envs.sh"
. "$DOTFILES/scripts/paths.sh"

##################################################################################
###                               HELPER FUNCTIONS                             ###
##################################################################################
createdir() {
  if [ ! -d "$1" ]; then mkdir -p "$1"; fi
}

backup() {
  NAME=$(basename "$1")
  if [ ! -L "$1" ] && [ -f "$1" ] || [ -d "$1" ]; then
    cp -r "$1" "$XDG_CACHE_HOME/backup/$NAME.bak"
    rm -rf "$1"
  fi
}

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

title() {
  echo ""
  gum style --foreground="#cba6f7" --border-foreground="#89b4fa" --border="rounded" --align="center" --padding="1 2" "$@"
}

output() {
  STATUS=""
  PROCESS_NAME=""
  DIVIDER=$(gum style --foreground="#6c7086" --align="left" " │ ")
  ENTRY_NAME=""
  MESSAGE=""

  if [ $? -eq 0 ]; then
    STATUS=$(gum style --foreground="#a6e3a1" --align="left" --bold "✓  ")
    PROCESS_NAME=$(gum style --foreground="#a6e3a1" --align="left" --bold "$1")
    ENTRY_NAME=$(gum style --foreground="#f9e2af" --align="left" "$2 ")
    MESSAGE=$(gum style --foreground="#cdd6f4" --align="left" --italic "installed successfully.")
  else
    STATUS=$(gum style --foreground="#f38ba8" --align="left" --bold "✗  ")
    PROCESS_NAME=$(gum style --foreground="#f38ba8" --align="left" --bold "$1")
    ENTRY_NAME=$(gum style --foreground="#cabc9e" --align="left" "$2 ")
    MESSAGE=$(gum style --foreground="#cdd6f4" --align="left" --italic "failed to install.")
  fi

  gum join --align="left" --horizontal "$STATUS" "$PROCESS_NAME" "$DIVIDER" "$ENTRY_NAME" "$MESSAGE"
}

info() {
  ARROW=$(gum style --foreground="#89b4fa" --align="left" "==> ")
  ENTRY=$(gum style --foreground="#74c7ec" --align="left" "$1")
  DIVIDER=$(gum style --foreground="#6c7086" --align="left" ":")
  TEXT=$(gum style --foreground="#cdd6f4" --align="left" --italic " $2 ")
  INFO=$(gum style --foreground="#cba6f7" --align="left" --bold "$3")
  gum join --align="left" --horizontal "$ARROW" "$ENTRY" "$DIVIDER" "$TEXT" "$INFO"
}

eval_brew() {
  local BREW_LOCATION
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
}

##################################################################################
###                            INSTALLATION FUNCTIONS                          ###
##################################################################################

# Apt package
check_apt_package() {
  PACKAGE="$1"
  STATUS_OK="$(dpkg-query -W --showformat='${db:Status-Status}' "$PACKAGE" 2>&1)"
  local install=false
  if [ ! $? = 0 ] || [ ! "$STATUS_OK" = installed ]; then
    install=true
  fi
  if "$install"; then
    gum spin --title="Installing $PACKAGE..." -- sudo apt install -y "$PACKAGE"
    output "apt" "$PACKAGE"
  fi
}

# GitHub CLI extension
check_gh_extension() {
  EXT_NAME="$1"
  if ! gh extension list | grep -i "$EXT_NAME" >/dev/null; then
    gum spin --title="Installing ${EXT_NAME}..." -- gh extension install "$EXT_NAME"
    output "gh-extension" "$EXT_NAME"
  fi
}

check_code_extension() {
  # VSCode extensions
  if command_exists code; then
    INSTALLED_EXTENSIONS=$(code --list-extensions)
    while read -r extension; do
      if [[ $INSTALLED_EXTENSIONS != *"$extension"* ]]; then
        gum spin --title "Installing $extension..." -- code --install-extension "$extension"
      fi
    done <"$DOTFILES/extensions.txt"
    info "VSCODE" "Extensions installed can be found at" "$DOTFILES/extensions.txt"
  else
    info "VSCODE" "Command not found:" "'code'"
  fi
}

setup_gitconfig() {
  if [ ! -f "$HOME/.gitconfig" ] || ([ -f "$HOME/.gitconfig" ] && ! grep -q \[user\] "$HOME/.gitconfig"); then
    GIT_NAME=$(gum input --prompt="▶  Input Git Name: " --prompt.foreground="#cba6f7" --placeholder="Your Name" --placeholder.foreground="#6c7086")
    GIT_EMAIL=$(gum input --prompt="▶  Input Git Email: " --prompt.foreground="#cba6f7" --placeholder="youremail@domain.com" --placeholder.foreground="#6c7086")
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
  fi
  if grep -i Microsoft /proc/version >/dev/null; then
    git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"
  fi
  if [ -f "$HOME/.gitconfig" ] && ! grep -q delta "$HOME/.gitconfig"; then
    git config --global include.path "$HOME/.config/delta/themes/catppuccin.gitconfig"
    git config --global core.pager "delta"
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate "true"
    git config --global delta.dark "true"
    git config --global delta.side-by-side "true"
    git config --global delta.hyperlinks "true"
    git config --global delta.features "catppuccin-macchiato"
    git config --global merge.conflictstyle "zdiff3"
  fi
  info "GIT" "Detailed information of git configuration is in" "$HOME/.gitconfig"
}

##################################################################################
###                                  MAIN SCRIPT                               ###
##################################################################################

# PREREQUISITES
# --------------------------------------------------------------------------------
# TODO: Add proper function to check internet connection
# if : >/dev/tcp/8.8.8.8/53; then
#   echo "$(tput setaf 4)==> $(tput sgr0)Internet connection available. Continue..."
# else
#   echo "$(tput setaf 4) ==> $(tput sgr0)Internet connection unavailable! Exiting..."
#   exit 0
# fi

# Homebrew
eval_brew
if ! command_exists brew; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval_brew
fi

# Gum Installation
if ! brew ls --versions 'gum' >/dev/null 2>&1; then
  brew install gum --quiet
fi

# START
# --------------------------------------------------------------------------------
# Create directories if they don't exist
DIRECTORIES=(
  "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_BIN_HOME" "$XDG_PROJECTS_DIR" "$XDG_RUNTIME_DIR"
  "$HOME/Code" "$XDG_CACHE_HOME/backup" "$XDG_CACHE_HOME/npm" "$XDG_CACHE_HOME/wget" "$XDG_CACHE_HOME/less"
)
for dir in "${DIRECTORIES[@]}"; do createdir "$dir"; done
unset dir

# Apt packages
title "APT PACKAGES"
gum spin --title="Updating system..." -- sudo apt update
gum spin --title="Updating system..." -- sudo apt upgrade -y
APT_PACKAGES=(
  'build-essential' 'ccache' 'cmake' 'curl'
  'file' 'git' 'make' 'wget' 'xdg-utils' 'zsh'
)
for pkg in "${APT_PACKAGES[@]}"; do
  check_apt_package "$pkg"
done
unset pkg
# wslu
if uname -r | grep -q icrosoft; then
  if lsb_release -i | grep -q Ubuntu; then check_apt_package wslu; fi
fi
# list all installed packages in `packages.log`
apt list --manual-installed 2>/dev/null | grep -F \[installed\] | tee packages.log >/dev/null
info "APT" "Packages installed are listed in" "$DOTFILES/packages.log"

# Homebrew packages
title "HOMEBREW PACKAGES"
gum spin --title="Verifying system..." --show-error -- brew doctor
builtin cd "$DOTFILES" && brew bundle install --file="$DOTFILES/Brewfile"
gum spin --title "Cleaning up..." -- brew bundle --force cleanup
info "HOMEBREW" "Packages installed can be found at" "$DOTFILES/Brewfile"

# Stow dotfiles (symlinks)
FILES=("$HOME/.zshrc" "$HOME/.zshenv" "$HOME/.bashrc")
for file in "${FILES[@]}"; do backup "$file"; done
unset file
for folder in "$XDG_CONFIG_HOME/"*; do backup "$folder"; done
unset folder
builtin cd "$DOTFILES" && stow .

# Bat theme
if command_exists bat; then
  gum spin --title="Setting up bat theme..." -- bat cache --clear
  gum spin --title="Setting up bat theme..." -- bat cache --build
fi

# Yazi plugins
if command_exists yazi && command_exists ya; then
  gum spin --title="Setting up yazi..." -- ya pack -i
  gum spin --title="Setting up yazi..." -- ya pack -u
fi

# Neovim plugins
if command_exists nvim; then
  gum spin --title="Updating Neovim plugins..." -- nvim --headless +"Lazy! sync" +qa
fi

# visual studio code extensions
title "VSCODE EXTENSIONS"
\. "$DOTFILES/scripts/paths.sh"
check_code_extension

# Git configuration
title "GIT CONFIGURATION"
setup_gitconfig
if command_exists gh; then
  if [ ! -f "$HOME/.config/gh/hosts.yml" ]; then
    gh auth login
  fi
  GH_EXTENSIONS=('dlvhdr/gh-dash' 'yusukebe/gh-markdown-preview' 'yuler/gh-download')
  for extension in "${GH_EXTENSIONS[@]}"; do
    check_gh_extension "$extension"
  done
  unset extension
  info "GitHub CLI" "List extensions installed with command:" "gh extension list"
fi

# cleanup
if [ -f "$HOME/.wget-hsts" ]; then
  mv -i "$HOME/.wget-hsts" "$XDG_CACHE_HOME/wget/wget-hsts"
fi

# END SCRIPT
# --------------------------------------------------------------------------------
echo ""
