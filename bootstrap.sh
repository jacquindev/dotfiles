#!/bin/bash

# shellcheck disable=SC2181
# shellcheck source-path=SCRIPTDIR
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

. "$DOTFILES/scripts/envs.sh"
. "$DOTFILES/scripts/paths.sh"

make_dir() {
  if [ ! -d "$1" ]; then mkdir -p "$1"; fi
}

DIRECTORIES=("$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_BIN_HOME"
  "$XDG_PROJECTS_DIR" "$XDG_RUNTIME_DIR" "$HOME/Code" "$XDG_CACHE_HOME/backup" "$XDG_CACHE_HOME/npm")
for dir in "${DIRECTORIES[@]}"; do make_dir "$dir"; done
unset dir

GITHUB="https://github.com/"

##################################################################################
###                               HELPER FUNCTIONS                             ###
##################################################################################
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

checkout() {
  [ -d "$2" ] || git -c advice.detachedHead=0 clone --branch "$3" --depth 1 "$1" "$2" >/dev/null 2>&1
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

check_pyenv_plugins() {
  # Based on:
  # - https://github.com/pyenv/pyenv/wiki#suggested-build-environment
  # - https://github.com/pyenv/pyenv/wiki/Common-build-problems#prerequisites
  PYENV_BUILD_PKGS=(
    'libssl-dev' 'libbz2-dev' 'libreadline-dev' 'libsqlite3-dev' 'libxml2-dev' 'xz-utils'
    'libncurses5-dev' 'libxmlsec1-dev' 'libffi-dev' 'liblzma-dev' 'tk-dev' 'zlib1g-dev'
  )
  for pkg in "${PYENV_BUILD_PKGS[@]}"; do
    check_apt_package "$pkg"
  done
  unset pkg

  PYENV_PLUGINS=('pyenv-doctor' 'pyenv-update' 'pyenv-virtualenv' 'pyenv-ccache')
  for plugin in "${PYENV_PLUGINS[@]}"; do
    if [ ! -d "$PYENV_ROOT/plugins/$plugin" ]; then
      checkout "${GITHUB}pyenv/$plugin.git" "${PYENV_ROOT}/plugins/$plugin" "master"
      output "pyenv plugin" "$plugin"
    fi
  done
}

##################################################################################
###                                  MAIN SCRIPT                               ###
##################################################################################

# PREREQUISITES
# --------------------------------------------------------------------------------
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
  brew install gum
fi

# START
# --------------------------------------------------------------------------------

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
apt list --manual-installed 2>/dev/null | grep -F \[installed\] | tee packages.log >/dev/null
info "APT" "Packages installed are listed in" "$DOTFILES/packages.log"

# Homebrew packages
title "HOMEBREW PACKAGES"
gum spin --title="Verifying system..." --show-error -- brew doctor
builtin cd "$DOTFILES" && gum spin --title="Installing Homebrew packages..." -- brew bundle
gum spin --title "Cleaning up..." -- brew cleanup
info "HOMEBREW" "Packages installed can be found at" "$DOTFILES/Brewfile"

# Stow dotfiles (symlinks)
FILES=("$HOME/.zshrc" "$HOME/.zshenv" "$HOME/.bashrc")
for file in "${FILES[@]}"; do backup "$file"; done
unset file
for folder in "$XDG_CONFIG_HOME/"*; do backup "$folder"; done
unset folder
builtin cd "$DOTFILES" && stow .

if command_exists bat; then
  gum spin --title="Setting up bat theme..." -- bat cache --clear
  gum spin --title="Setting up bat theme..." -- bat cache --build
fi

if command_exists yazi && command_exists ya; then
  gum spin --title="Setting up yazi..." -- ya pack -i
  gum spin --title="Setting up yazi..." -- ya pack -u
fi

# visual studio code extensions
title "VSCODE EXTENSIONS"
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

# DEV TOOLS
# --------------------------------------------------------------------------------
title "DEV TOOLS"

# Pyenv
gum style --foreground="#fab387" --bold "1) PYENV (Python Version Manager):"
if ! command_exists pyenv || [ ! -d "$PYENV_ROOT" ] && [[ "$(uname -r)" = *icrosoft* ]]; then
  checkout "${GITHUB}pyenv/pyenv.git" "${PYENV_ROOT}" "master"
  check_pyenv_plugins

  builtin cd "$PYENV_ROOT" && src/configure && make -C src >/dev/null 2>&1

  {
    "${PYENV_ROOT}/bin/pyenv" init
    "${PYENV_ROOT}/bin/pyenv" virtualenv-init
  } >/dev/null 2>&1

  info "pyenv v$(pyenv --version | cut -d ' ' -f2-)" "was installed at" "$PYENV_ROOT"
else
  gum spin --title="Updating pyenv..." -- pyenv update
  info "pyenv v$(pyenv --version | cut -d ' ' -f2-)" "Dev Tool is already installed at" "$PYENV_ROOT"
fi

current_version=$(pyenv versions | cut -d '(' -f1 | sed 's/*//g;s/[[:space:]]//g')
python_version=$(pyenv install --list | grep '^  3.' | sed 's/[[:space:]]//g' | gum choose --height=20 --header="Choose a Python Version:" --header.foreground="#f9e2af")
if [[ "$current_version" == "system" ]] || [[ "$current_version" != *"$python_version"* ]]; then
  gum spin --title="Installing python v${python_version}..." -- pyenv install "$python_version"
  pyenv global "$python_version"
  cd "$PYENV_ROOT/versions/" && ln -sf "$python_version" global
  output "pyenv" "python v${python_version}"
  builtin cd "$DOTFILES" || exit
  gum spin --title="Ensuring pip..." -- python -m ensurepip --upgrade
  gum spin --title="Ensuring pip..." -- python -m pip install --upgrade --user pip --force
  output "pyenv" "pip v$(pip --version | cut -d ' ' -f2)"
else
  output "pyenv" "python v${python_version}"
  output "pyenv" "pip v$(pip --version | cut -d ' ' -f2)"
fi

if ! command_exists pipx; then
  gum spin --title="Installing pipx..." -- python -m pip install --user pipx
  gum spin --title="Installing pipx..." -- python -m pipx ensurepath
  source "$HOME/.bashrc"
  output "pyenv" "pipx v$(pipx --version)"
else
  gum spin --title="Updating pipx..." -- python -m pip install --user -U pipx
  output "pyenv" "pipx v$(pipx --version)"
fi

echo ""

# nvm
gum style --foreground="#fab387" --bold "2) NVM (NodeJS Version Manager):"
if ! command_exists nvm || [ ! -d "$NVM_DIR" ]; then
  gum spin --title="Installing NVM..." -- git clone "${GITHUB}nvm-sh/nvm.git" "$NVM_DIR"
  _nvm_latest_release_tag=$(builtin cd "$NVM_DIR" && git fetch --quiet --tags origin && git describe --abbrev=0 --tags --match "v[0-9]*" "$(git rev-list --tags --max-count=1)")
  builtin cd "$NVM_DIR" && git checkout --quiet "$_nvm_latest_release_tag"

  source "$NVM_DIR/nvm.sh"
  info "nvm v$(nvm --version)" "was installed at" "$NVM_DIR"

  builtin cd "$DOTFILES" || exit
else
  info "nvm v$(nvm --version)" "Dev Tool is already installed at" "$NVM_DIR"
fi

if ! command_exists npm; then
  current_nodes=$(nvm ls --no-alias | cut -d ' ' -f2- | sed 's/[[:space:]]//g')
  node_version=$(nvm ls-remote | cut -d '(' -f1 | sed 's/[[:space:]]//g' | grep '^v2' | gum choose --height=20 --header="Choose a NodeJS Version:" --header.foreground="#f9e2af")
  if [[ $current_nodes == "N/A" ]] || [[ "$current_nodes" != *"$node_version"* ]]; then
    nvm install "$node_version" >/dev/null 2>&1
    nvm use "$node_version" >/dev/null
    output "nvm" "node $(node --version)"
    gum spin --show-error --title="Installing latest npm..." -- nvm install latest-npm
    output "nvm" "npm v$(npm --version)"
  fi
fi

# Default packages for NodeJS
if command_exists npm; then
  if [ ! -f "$NVM_DIR/default-packages" ]; then
    touch "$NVM_DIR/default-packages"
  fi
  NPM_PACKAGES=('commitizen' 'cz-git' 'git-open' 'git-recent')
  for pkg in "${NPM_PACKAGES[@]}"; do
    gum spin --title="Instaling $pkg..." -- npm install --global --silent "$pkg"
    echo "$pkg" >>"$NVM_DIR/default-packages"
  done
  unset pkg
fi

echo ""

gum style --foreground="#fab387" --bold "3) G (Go Version Manager):"
if alias g >/dev/null 2>&1; then unalias g; fi
if ! command_exists g || ! command_exists go; then
  export GOROOT="$HOME/.local/share/go"
  export GOPATH="$HOME/Code/go"
  wget --quiet -P "$GOPATH/bin" "https://raw.githubusercontent.com/stefanmaric/g/refs/heads/next/bin/g"
  chmod +x "$GOPATH/bin/g"
  source "$HOME/.bashrc"
  info "g v$(g --version)" "was installed at" "$(command -v g)"
elif command_exists g; then
  info "g v$(g --version)" "Dev Tool is already installed at" "$(command -v g)"
fi

go_version=$(g list-all | sed 's/[[:space:]]//g' | gum choose --height=20 --header="Choose a NodeJS Version:" --header.foreground="#f9e2af")
go_current_versions=$(g list | cut -d '>' -f2 | sed 's/[[:space:]]//g' | grep '^1.')
if [[ "$go_current_versions" != *"$go_version"* ]]; then
  gum spin --title="Install Go v${go_version}..." -- g install "$go_version"
  output "g" "go v${go_version}"
else
  g set "${go_version}"
  output "g" "go v${go_version}"
fi

echo ""

# END SCRIPT
# --------------------------------------------------------------------------------
if command_exists zsh; then
  setup_default_zsh() {
    chsh -s "$(which zsh)" "$USER"
  }
  gum confirm --prompt.foreground="#89b4fa" --selected.foreground="#181825" --selected.background="#cba6f7" "Make ZSH your default shell?" && setup_default_zsh || gum style --foreground="#45475a" --italic "Skipping..."
fi

echo ""
