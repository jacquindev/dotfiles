#!/bin/sh

# shellcheck disable=SC1091,SC3010

# shellcheck source-path=SCRIPTDIR
DOTFILES="$HOME/dotfiles"
GITHUB="https://github.com/"

checkout() {
  [ -d "$2" ] || git -c advice.detachedHead=0 clone --branch "$3" --depth 1 "$1" "$2" >/dev/null 2>&1
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

exist_output() {
  STATUS=$(gum style --foreground="#cba6f7" --align="left" --bold "⦁  ")
  PROCESS_NAME=$(gum style --foreground="#89b4fa" --align="left" --bold "$1")
  ENTRY_NAME=$(gum style --foreground="#f9e2af" --align="left" "$2 ")
  MESSAGE=$(gum style --foreground="#9399b2" --align="left" --italic "already installed. Skipping...")

  gum join --align="left" --horizontal "$STATUS" "$PROCESS_NAME" "$DIVIDER" "$ENTRY_NAME" "$MESSAGE"
}

check_apt_package() {
  PACKAGE="$1"
  STATUS_OK="$(dpkg-query -W --showformat='${db:Status-Status}' "$PACKAGE" 2>&1)"
  install=false
  if [ ! $? = 0 ] || [ ! "$STATUS_OK" = installed ]; then
    install=true
  fi
  if "$install"; then
    gum spin --spinner.foreground="#c6a0f6" --title.foreground="#8aadf4" --title="Installing $PACKAGE..." -- sudo apt install -y "$PACKAGE"
    output "apt" "$PACKAGE"
  else
    exist_output "apt" "$PACKAGE"
  fi
}

setup_nvm() {
  title "NVM (Node Version Manager)"
  if ! command -v nvm >/dev/null || [ ! -d "$NVM_DIR" ]; then
    gum spin --spinner.foreground="#c6a0f6" --title.foreground="#8aadf4" --title="Installing nvm..." -- git clone "${GITHUB}nvm-sh/nvm.git" "$NVM_DIR"
    _nvm_latest_release_tag=$(cd "$NVM_DIR" && git describe --abbrev=0 --tags --match "v[0-9]*" "$(git rev-list --tags --max-count=1)")
    cd "$NVM_DIR" && git checkout --quiet "$_nvm_latest_release_tag"
    \. "$NVM_DIR/nvm.sh"
    output "nvm" "nvm v$(nvm --version)"
  else
    exist_output "nvm" "nvm v$(nvm --version)"
  fi

  cd "$DOTFILES" && \. "$NVM_DIR/nvm.sh" || exit

  node_lts() {
    nvm install --lts
    nvm install-latest-npm
  }

  node_latest() {
    nvm install node
    nvm install-latest-npm
  }

  if ! command -v npm >/dev/null; then
    gum confirm "Install LTS (y) or latest Node (n)?" && node_lts || node_latest
  fi

  if ! command -v cz >/dev/null; then
    npm install -g --quiet commitizen cz-git
    output "npm" "commitizen"
    output "npm" "cz-git"
  else
    exist_output "npm" "commitizen"
    exist_output "npm" "cz-git"
  fi
  if ! command -v git-open >/dev/null; then
    npm install -g --quiet git-open
    output "npm" "git-open"
  else
    exist_output "npm" "git-open"
  fi
  if ! command -v git-recent >/dev/null; then
    npm install -g --quiet git-recent
    output "npm" "git-recent"
  else
    exist_output "npm" "git-recent"
  fi

  echo ""
}

setup_pyenv() {
  title "PYENV (Python Version Manager)"

  export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims/$PYENV_ROOT/versions/global/bin:$PATH"

  pyenv_plugins() {
    set -- pyenv-doctor pyenv-update pyenv-virtualenv pyenv-ccache
    for plugin in "$@"; do
      if [ ! -d "$PYENV_ROOT/plugins/$plugin" ]; then
        checkout "${GITHUB}pyenv/$plugin.git" "$PYENV_ROOT/plugins/$plugin" "master"
        output "pyenv-plugin" "$plugin"
      else
        exist_output "pyenv-plugin" "$plugin"
      fi
    done
  }

  if ! command -v pyenv >/dev/null || [ ! -d "$PYENV_ROOT" ] && [[ "$(uname -r)" == *icrosoft* ]]; then
    checkout "${GITHUB}pyenv/pyenv.git" "${PYENV_ROOT}" "master"
    pyenv_plugins

    # Python Build Dependencies
    set -- libssl-dev libbz2-dev libreadline-dev libsqlite3-dev libxml2-dev xz-utils libncurses5-dev libxmlsec1-dev libffi-dev liblzma-dev tk-dev zlib1g-dev
    for dep in "$@"; do
      check_apt_package "$dep"
    done
    unset dep

    cd "$PYENV_ROOT" && src/configure && make -C src >/dev/null

    {
      "$PYENV_ROOT/bin/pyenv" init
      "$PYENV_ROOT/bin/pyenv" virtualenv-init
    } >/dev/null 2>&1

    cd "$DOTFILES" && output "pyenv" "pyenv v$(pyenv --version | cut -d ' ' -f2-)" || exit
  else
    exist_output "pyenv" "pyenv v$(pyenv --version | cut -d ' ' -f2-) "
  fi

  # Install python version
  if pyenv version | grep -q system; then
    python_version=$(pyenv install --list | grep '^  3.' | sed 's/[[:space:]]//g' | gum choose --height=20 --header="Choose a Python Version:" --header.foreground="#f9e2af")
    gum spin --spinner.foreground="#c6a0f6" --title.foreground="#8aadf4" --title="Installing python v${python_version}..." -- pyenv install "$python_version"
    pyenv global "$python_version"
    cd "$PYENV_ROOT/versions/" && ln -sf "$python_version" global
    output "pyenv" "python v${python_version}"
    cd "$DOTFILES" || exit

    gum spin --spinner.foreground="#c6a0f6" --title.foreground="#8aadf4" --title="Updating pip..." -- python -m ensurepip --upgrade
    gum spin --spinner.foreground="#c6a0f6" --title.foreground="#8aadf4" --title="Updating pip..." -- python -m pip install --upgrade pip --force
    output "pyenv" "pip v$(pip --version | cut -d ' ' -f2)"
  else
    exist_output "pyenv" "python v${python_version}"
    exist_output "pyenv" "pip v$(pip --version | cut -d ' ' -f2)"
  fi

  echo ""
}

setup_go() {
  title "G (Go Version Manager)"

  export PATH="$GOPATH/bin:$PATH"

  if alias g >/dev/null 2>&1; then unalias g; fi
  if ! command -v g >/dev/null; then
    wget --quiet -P "$GOPATH/bin" https://raw.githubusercontent.com/stefanmaric/g/refs/heads/next/bin/g
    chmod +x "$GOPATH/bin/g"
    if [ -n "$BASH_VERSION" ]; then
      . "$HOME/.bashrc"
    else
      . "$ZDOTDIR/.zshrc"
    fi
    output "g" "g v$(g --version)"
  else
    exist_output "g" "g v$(g --version)"
  fi

  gum spin --spinner.foreground="#c6a0f6" --title.foreground="#8aadf4" --title="Installing go latest version..." -- g install latest
  output "g" "$(go version | cut -d ' ' -f3)"

  echo ""
}

eval_brew
if ! command_exists brew; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval_brew
fi

# Gum Installation
if ! brew ls --versions 'gum' >/dev/null 2>&1; then
  brew install gum --quiet
fi

title "DEV TOOLS"

choose=$(gum choose --header="Choose a dev tool to setup:" --header.foreground="#89b4fa" --selected.foreground="#cba6f7" --cursor.foreground="#cba6f7" "1) NVM" "2) Pyenv" "3) G")

if [ "$choose" = "1) NVM" ]; then
  setup_nvm
elif [ "$choose" = "2) Pyenv" ]; then
  setup_pyenv
elif [ "$choose" = "3) G" ]; then
  setup_go
else
  echo "Invalid option. Exiting..."
  exit 1
fi
