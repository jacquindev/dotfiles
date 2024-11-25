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
  DIVIDER=$(gum style --foreground="#6c7086" --align="left" " │ ")
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
    output "g " "g v$(g --version)"
  else
    exist_output "g " "g v$(g --version)"
  fi

  if ! command -v go >/dev/null; then
    gum spin --spinner.foreground="#c6a0f6" --title.foreground="#8aadf4" --title="Installing go latest version..." -- g install latest
    output "go" "$(go version | cut -d ' ' -f3)"
  else
    exist_output "go" "$(go version | cut -d ' ' -f3)"
  fi

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
      output "pyenv " "python v${python_version}"
      cd "$DOTFILES" || exit 1
    else
      exist_output "pyenv " "python v$(python --version | cut -d ' ' -f2-)"
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

setup_nvm() {
  title "NVM (Node Version Manager)"

  export NVM_DIR="$HOME/Code/nvm"
  export PNPM_HOME="$XDG_DATA_HOME/pnpm"

  [ -d "$XDG_DATA_HOME/nvm" ] && rm -rf "$XDG_DATA_HOME/nvm"
  [ -d "$HOME/.nvm" ] && rm -rf "$HOME/.nvm"

  if [ ! -d "$HOME/Code/nvm" ]; then
    mkdir -p "$NVM_DIR"
    curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash >/dev/null

    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    echo ""
    output "nvm " "nvm v$(nvm --version)"

    gum confirm "Use LTS (y) or latest node (n)?" && nvm install --lts >/dev/null 2>&1 || nvm install node >/dev/null 2>&1
    output "nvm " "node $(node --version)"
    gum spin --title "Installing latest npm" -- nvm install-latest-npm
    output "nvm " "npm v$(npm --version)"
    gum spin --title "Installing pnpm" -- npm install -g pnpm
    output "npm " "pnpm v$(pnpm --version)"
  else
    \. "$NVM_DIR/nvm.sh"
    exist_output "nvm " "nvm v$(nvm --version)"
    if command -v npm >/dev/null 2>&1; then exist_output "nvm " "npm v$(npm --version)"; fi
    if command -v pnpm >/dev/null 2>&1; then exist_output "npm " "pnpm v$(pnpm --version)"; fi
  fi

  export PATH="$(npm config get prefix)/bin:$PNPM_HOME:$PATH"

  set -- bun commitizen cz-git git-open git-recent
  for tool in "$@"; do
    if ! pnpm ls -g | grep -q "$tool"; then
      gum spin --title "Instaling $tool..." -- pnpm install -g "$tool"
      output "pnpm" "$tool"
    else
      exist_output "pnpm" "$tool"
    fi
  done
  unset tool

  echo ""
}

setup_rbenv() {
  title "RBENV (Ruby Version Manager)"

  export RBENV_ROOT="$HOME/Code/rbenv"
  export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$RBENV_ROOT/versions/global/bin:$PATH"

  rbenv_plugins() {
    set -- 'rbenv/ruby-build' 'rbenv/rbenv-default-gems' 'jf/rbenv-gemset' 'rkh/rbenv-update' \
      'rkh/rbenv-use' 'rkh/rbenv-whatis' 'yyuu/rbenv-ccache'
    for repo in "$@"; do
      pkg=$(basename $repo)
      if [ ! -d "$RBENV_ROOT/plugins/$pkg" ]; then
        checkout "${GITHUB}$repo.git" "${RBENV_ROOT}/plugins/$pkg" "master"
        output "rbenv-plugin" "$pkg"
      else
        exist_output "rbenv-plugin" "$pkg"
      fi
    done
    unset repo pkg
  }

  ruby_install() {
    if rbenv version | grep -q system; then
      ruby_version=$(rbenv install --list | gum choose --header="Choose a Ruby Version:" --header.foreground="#f9e2af")
      gum spin --title="Instaling ruby $ruby_version..." -- rbenv install "$ruby_version"
      rbenv global "$ruby_version"
      cd "$RBENV_ROOT/versions/" && ln -sf "$ruby_version" global
      rbenv rehash
      cd "$DOTFILES" || return 0
      output "rbenv" "ruby v$(ruby --version | cut -d ' ' -f2)"
    else
      exist_output "rbenv" "ruby v$(ruby --version | cut -d ' ' -f2)"
    fi
  }

  if ! command -v rbenv >/dev/null; then
    set -- autoconf patch build-essential libssl-dev libyaml-dev libreadline6-dev \
      zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev
    for pkg in "$@"; do
      check_apt_package "$pkg"
    done
    unset pkg

    [ -d "$RBENV_ROOT" ] && rm -rf "$RBENV_ROOT"

    checkout "${GITHUB}/rbenv/rbenv.git" "$RBENV_ROOT" "master"
    "$RBENV_ROOT/bin/rbenv" init >&2
    output "rbenv" "rbenv v$(rbenv --version | cut -d ' ' -f2-)"
    rbenv_plugins
    ruby_install

  else
    exist_output "rbenv" "rbenv v$(rbenv --version | cut -d ' ' -f2-)"
    ruby_install
    rbenv_plugins
  fi

  echo ""
}

setup_rust() {
  title "RUSTUP (Rust Programming Language Installer)"

  export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
  export CARGO_HOME="$HOME/Code/cargo"

  cargo_packages() {
    set -- cargo-update cargo-cache cargo-run-bin
    for pkg in "$@"; do
      if ! cargo install --list | grep -q "$pkg"; then
        gum spin --title="Installing $pkg..." -- cargo binstall --no-confirm "$pkg"
        output "cargo " "$pkg"
      else
        exist_output "cargo " "$pkg"
      fi
    done
  }

  if ! command -v rustup >/dev/null || ! command -v cargo >/dev/null || [[ "$(which cargo)" != *"$CARGO_HOME"* ]]; then
    rustup_file="$(pwd)/install.sh"
    wget --quiet -O "$rustup_file" https://sh.rustup.rs
    chmod +x "$rustup_file"
    "$rustup_file" -y --quiet --no-modify-path
    rm -f "$rustup_file"
    \. "$CARGO_HOME/env"
    output "rustup" "$(rustup --version)"
  else
    \. "$CARGO_HOME/env"
    exist_output "rustup" "$(rustup --version)"
  fi

  if ! command -v cargo-binstall >/dev/null 2>&1; then
    wget -O- https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
    output "cargo " "cargo-binstall $(cargo-binstall -V)"
    cargo_packages
  else
    exist_output "cargo " "cargo-binstall v$(cargo-binstall -V)"
    cargo_packages
  fi

  echo ""
}

choose=$(gum choose --header="Choose a dev tool to setup:" --header.foreground="#89b4fa" --selected.foreground="#cba6f7" --cursor.foreground="#cba6f7" "1) NVM" "2) Pyenv" "3) Rbenv" "4) Rustup" "5) Go")

if [ "$choose" = "1) NVM" ]; then
  setup_nvm
elif [ "$choose" = "2) Pyenv" ]; then
  setup_pyenv
elif [ "$choose" = "3) Rbenv" ]; then
  setup_rbenv
elif [ "$choose" = "4) Rustup" ]; then
  setup_rust
elif [ "$choose" = "5) Go" ]; then
  setup_go
else
  return
fi
