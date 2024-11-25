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
    ENTRY_NAME=$(gum style --foreground="#f9e2af" --align="left" " $2 ")
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
  ENTRY_NAME=$(gum style --foreground="#f9e2af" --align="left" " $2 ")
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

setup_pyenv() {
  title "PYENV (Python Version Manager)"

  # Look for pyenv in $PATH and verify that it's not a part of pyenv-win in WSL
  FOUND_PYENV=0
  if [[ "$(command -v pyenv)" == */pyenv-win/* && "$(uname -r)" == *icrosoft* ]]; then
    FOUND_PYENV=0
  elif ! command -v pyenv >/dev/null 2>&1; then
    FOUND_PYENV=0
  else
    FOUND_PYENV=1
  fi

  python_programs() {
    # Install python & set global python version
    if pyenv version | grep -q system; then
      python_version=$(pyenv install --list | grep '^  3.' | sed 's/[[:space:]]//g' | gum choose --height=20 --header="Choose a Python Version:" --header.foreground="#f9e2af")
      gum spin --spinner.foreground="#c6a0f6" --title.foreground="#8aadf4" --title="Installing python v${python_version}..." -- pyenv install "$python_version"
      pyenv global "$python_version"
      cd "$PYENV_ROOT/versions/" && ln -sf "$python_version" global
      pyenv rehash
      output "pyenv" "python v${python_version}"
      cd "$DOTFILES" || exit 1
    else
      exist_output "pyenv" "python v$(python --version | cut -d ' ' -f2-)"
    fi

    # Pip
    gum spin --spinner.foreground="#c6a0f6" --title.foreground="#8aadf4" --title="Updating pip..." -- python -m ensurepip --upgrade
    gum spin --spinner.foreground="#c6a0f6" --title.foreground="#8aadf4" --title="Updating pip..." -- python -m pip install --upgrade pip --force
    if [ -n "$BASH_VERSION" ]; then \. "$HOME/.bashrc"; else \. "$ZDOTDIR/.zshrc"; fi
    exist_output "python" "pip v$(pip --version | cut -d ' ' -f2)"

    # Pipx
    if ! command -v pipx >/dev/null; then
      gum spin --spinner.foreground="#c6a0f6" --title.foreground="#8aadf4" --title="Installing pipx..." -- python -m pip install --user pipx --force
      gum spin --spinner.foreground="#c6a0f6" --title.foreground="#8aadf4" --title="Installing pipx..." -- python -m pipx ensurepath
      if [ -n "$BASH_VERSION" ]; then \. "$HOME/.bashrc"; else \. "$ZDOTDIR/.zshrc"; fi
      output "python" "pipx v$(pipx --version)"
    else
      exist_output "python" "pipx v$(pipx --version)"
    fi

    # pipenv
    if ! command -v pipenv >/dev/null; then
      gum spin --spinner.foreground="#c6a0f6" --title.foreground="#8aadf4" --title="Installing pipenv..." -- python -m pip install --user pipenv --force
      if [ -n "$BASH_VERSION" ]; then \. "$HOME/.bashrc"; else \. "$ZDOTDIR/.zshrc"; fi
      output "python" "pipenv ($(pipenv --version | cut -d ' ' -f2-))"
    else
      exist_output "python" "pipenv ($(pipenv --version | cut -d ' ' -f2-))"
    fi

    # Poetry
    if ! command -v poetry >/dev/null; then
      gum spin --spinner.foreground="#c6a0f6" --title.foreground="#8aadf4" --title="Installing poetry..." -- pipx install poetry --force
      if [ -n "$BASH_VERSION" ]; then \. "$HOME/.bashrc"; else \. "$ZDOTDIR/.zshrc"; fi
      output "python" "poetry $(poetry --version | cut -d ' ' -f2-)"
    else
      exist_output "python" "poetry $(poetry --version | cut -d ' ' -f2-)"
    fi
  }

  if [[ $FOUND_PYENV -eq 0 ]]; then
    export PYENV_ROOT="$HOME/Code/pyenv"
    export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PYENV_ROOT/versions/global/bin:$PATH"

    # Python Build Dependencies
    set -- libssl-dev libbz2-dev libreadline-dev libsqlite3-dev libxml2-dev xz-utils libncurses5-dev libxmlsec1-dev libffi-dev liblzma-dev tk-dev zlib1g-dev
    for dep in "$@"; do
      check_apt_package "$dep"
    done
    unset dep

    # Pyenv & Pyenv Plugins
    checkout "${GITHUB}pyenv/pyenv.git" "$PYENV_ROOT" "master"
    cd "$PYENV_ROOT" && src/configure && make -C src >/dev/null
    {
      "$PYENV_ROOT/bin/pyenv" init
      "$PYENV_ROOT/bin/pyenv" virtualenv-init
    } >/dev/null 2>&1

    output "pyenv" "pyenv v$(pyenv --version | cut -d ' ' -f2-)"
    set -- pyenv-doctor pyenv-update pyenv-virtualenv pyenv-ccache pyenv-pip-migrate
    for plugin in "$@"; do
      if [ ! -d "$PYENV_ROOT/plugins/$plugin" ]; then
        checkout "${GITHUB}pyenv/$plugin.git" "$PYENV_ROOT/plugins/$plugin" "master"
        output "pyenv-plugin" "$plugin"
      fi
    done
    unset plugin

    python_programs
    cd "$DOTFILES" || return 0

  elif [[ $FOUND_PYENV -eq 1 ]]; then
    exist_output "pyenv" "pyenv v$(pyenv --version | cut -d ' ' -f2-)"
    python_programs
  fi

  unset FOUND_PYENV
  echo ""
}

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
