#!/bin/sh

# shellcheck source-path=SCRIPTDIR
here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"
. "$here/scripts/utils.sh"
. "$here/scripts/helpers.sh"

export DOTFILES="$HOME/.dotfiles"
. "$DOTFILES/shared/envs"

GITHUB="https://github.com"

# Update system and install prerequisites
system_update() {
    sudo apt update && sudo apt upgrade -y
    check_apt_packages atool build-essential bash-completion ccache cmake curl direnv \
        file g++ gcc git make moreutils stow unzip zip wamerican wget
    
    if [[ $(uname -r) =~ WSL ]]; then check_apt_packages wslu; fi

    [ ! -d "$XDG_DATA_HOME/gnupg" ] && (mkdir -p "$XDG_DATA_HOME/gnupg" && chmod 600 "$XDG_DATA_HOME/gnupg")
}

# Apply dotfiles
stow_dotfiles() {
    [ -d "$HOME/.cache/backup" ] || mkdir -p "$HOME/.cache/backup"
    if [ -f "$HOME/.bashrc" ]; then mv -i "$HOME/.bashrc" "$HOME/.cache/backup/.bashrc-$(date +%Y-%m-%d_%H-%M-%S)"; fi
    if [ -f "$HOME/.profile" ]; then mv -i "$HOME/.profile" "$HOME/.cache/backup/.profile-$(date +%Y-%m-%d_%H-%M-%S)"; fi
    builtin cd "$DOTFILES" && stow .
}

# Homebrew
setup_homebrew() {
    if ! command_exists brew; then
        echo
        info "Installing Homebrew and Homebrew's packages..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    else
        echo
        warning "You're already installed Homebrew. Trying to update..."
        brew update && brew upgrade && brew cleanup prune=all
    fi
    check_brew_packages atuin bat eza fd fzf ripgrep luajit luarocks neovim oh-my-posh \
        jq fx yh lazygit git-delta
}

# Zsh
setup_zsh() {
    if ! command_exists zsh && checkyes "Could not find ZSH. Install ZSH now?"; then
        echo
        check_apt_packages zsh
        if checkyes "Make ZSH your default shell?"; then
            chsh -s "$(which zsh)" "$USER"
            success "ZSH was set as your default shell."
            info "After running this script, please close and reopen your terminal to take effect"
        fi
    fi
}

# Nvm
setup_nvm() {
    _nvm_latest_release_tag=$(builtin cd "$NVM_DIR" && git fetch --quiet --tags origin && git describe --abbrev=0 --tags --match "v[0-9]*" "$(git rev-list --tags --max-count=1)")

    if ! command_exists nvm && checkyes "Could not find NVM. Install now?"; then
        echo
        info "Installing NVM (Node Version Manager)..."
        if [ -d "$NVM_DIR" ]; then rm -rf "$NVM_DIR"; fi
        git clone "${GITHUB}/nvm-sh/nvm.git" "$NVM_DIR"
        builtin cd "$NVM_DIR" && git checkout --quiet "$_nvm_latest_release_tag"
        
        \. "$NVM_DIR/nvm.sh"

        if checkyes "Use LTS (Y) or latest node (n)?"; then
            nvm install --lts
        else 
            nvm install node
        fi
        nvm install-latest-npm
        npm i -g git-open git-recent
        
    elif command_exists nvm; then
        echo
        _nvm_installed_version=$(builtin cd "$NVM_DIR" && git describe --tags)
        warning "NVM version $_nvm_installed_version already installed."
        echo
        echo "${FMT_ORANGE}Checking latest version of NVM...${FMT_RESET}"
        if [[ "$_nvm_installed_version" = "$_nvm_latest_release_tag" ]]; then
            echo "${FMT_GREEN}You're already up to date${FMT_RESET}"
        else
            echo "${FMT_BLUE}Updating to $_nvm_latest_release_tag..."
            builtin cd "$NVM_DIR" && git fetch quiet && git checkout "$_nvm_latest_release_tag"
            \. "$NVM_DIR/nvm.sh"
        fi
    fi

    if [ -d "$NVM_DIR" ] && [ ! -f "$NVM_DIR/default_packages" ]; then
        echo "git-open" >> "$NVM_DIR/default_packages"
        echo "git-recent" >> "$NVM_DIR/default_packages"
    fi
}

setup_pyenv() {
    if ! command_exists pyenv && checkyes "Could not find Pyenv. Install now?"; then
        echo
        info "Installing Pyenv..."
        check_apt_packages libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
            libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

        export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PYENV_ROOT/versions/global/bin:$POETRY_HOME/bin:$PATH"

        if [ -d "$PYENV_ROOT" ]; then rm -rf "$PYENV_ROOT"; fi

        checkout "${GITHUB}/pyenv/pyenv.git"            "${PYENV_ROOT}"                             "${PYENV_GIT_TAG:-master}"
        checkout "${GITHUB}/pyenv/pyenv-doctor.git"     "${PYENV_ROOT}/plugins/pyenv-doctor"        "master"
        checkout "${GITHUB}/pyenv/pyenv-update.git"     "${PYENV_ROOT}/plugins/pyenv-update"        "master"
        checkout "${GITHUB}/pyenv/pyenv-virtualenv.git" "${PYENV_ROOT}/plugins/pyenv-virtualenv"    "master"
        checkout "${GITHUB}/pyenv/pyenv-ccache.git"     "${PYENV_ROOT}/plugins/pyenv-ccache"        "master"

        cd "$PYENV_ROOT" && src/configure && make -C src

        (   
            "${PYENV_ROOT}/bin/pyenv" init
            "${PYENV_ROOT}/bin/pyenv" virtualenv-init
        ) >&2

        pyenv install --list | grep '^  3.'
        printf "${FMT_PINK}Choose a python version to install: ${FMT_RESET}"
        read -r python_version
        pyenv install "$python_version" --verbose
        pyenv global "$python_version"
        builtin cd "$PYENV_ROOT/versions/" && ln -sf "$python_version" global
        pyenv rehash

        if ! command_exists poetry && checkyes "Could not find Poetry. Install?"; then
            info "Installing PyPoetry..."
            curl -sSL https://install.python-poetry.org | python3 -
            success "Successfully installed PyPoetry in $POETRY_HOME!"
        fi
    elif command_exists pyenv; then
        echo
        warning "You're already installed Pyenv. Updating..."
        echo
        pyenv update
        if command_exists poetry; then
            info "Trying to updating PyPoetry..."
            echo
            poetry self update
        fi
    fi
}

setup_rust() {
    if ! command_exists rustup && checkyes "Install Rustup?"; then
        echo
        info "Installing Rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path
        \. "$CARGO_HOME/env"
        echo
        echo "${FMT_PINK}Installing cargo-binstall and packages...${FMT_RESET}"
        curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
        cargo binstall --no-confirm cargo-cache cargo-run-bin cargo-update \
            bingrep git-graph hyperfine miniserve tealdeer
    elif command_exists rustup; then
        echo
        warning "You're already install Rustup. Trying to update..."
        rustup self update
    fi
}

setup_rbenv() {
    if ! command_exists rbenv; then
        echo
        if checkyes "Could not find rbenv. Install?"; then
            info "Installing Rbenv..."
            check_apt_packages autoconf patch build-essential libssl-dev libyaml-dev libreadline6-dev \
                zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev

            export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$RBENV_ROOT/versions/global/bin:$PATH"

            if [ -d "$RBENV_ROOT" ]; then rm -rf "$RBENV_ROOT"; fi

            checkout "${GITHUB}/rbenv/rbenv.git"            "${RBENV_ROOT}"                             "${RBENV_GIT_TAG:-master}"
            checkout "${GITHUB}/rbenv/ruby-build.git"       "${RBENV_ROOT}/plugins/ruby-build"          "master"
            checkout "${GITHUB}/rbenv/rbenv-default-gems"   "${RBENV_ROOT}/plugins/rbenv-default-gems"  "master"
            checkout "${GITHUB}/jf/rbenv-gemset.git"        "${RBENV_ROOT}/plugins/rbenv-gemset"        "master"
            checkout "${GITHUB}/rkh/rbenv-update.git"       "${RBENV_ROOT}/plugins/rbenv-update"        "master"
            checkout "${GITHUB}/rkh/rbenv-use.git"          "${RBENV_ROOT}/plugins/rbenv-use"           "master"
            checkout "${GITHUB}/rkh/rbenv-whatis.git"       "${RBENV_ROOT}/plugins/rbenv-whatis"        "master"
            checkout "${GITHUB}/yyuu/rbenv-ccache.git"      "${RBENV_ROOT}/plugins/rbenv-ccache"        "master"

            "$RBENV_ROOT/bin/rbenv" init >&2

            rbenv install --list 
            printf "${FMT_PINK}Choose a Ruby version to install: ${FMT_RESET}"
            read -r ruby_version
            rbenv install "$ruby_version" --verbose
            rbenv global "$ruby_version"
            builtin cd "$RBENV_ROOT/versions/" && ln -sf "$ruby_version" global
            rbenv rehash

            echo "${FMT_ORANGE}Verifying rbenv installation...${FMT_RESET}"
            curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-doctor | bash
        fi
    else
        echo
        warning "You're already installed Rbenv! Trying to update..."
        echo
        rbenv update
    fi
}

setup_go() {
    if ! command_exists go || ! command_exists g; then
        echo
        if checkyes "Install g (Go Version Manager)?"; then
            info "Install g (Go Version Manager)..." 
            curl -sSL https://raw.githubusercontent.com/voidint/g/master/install.sh | bash
            \. "$HOME/.g/env"
            g ls-remote stable
            echo
            printf "Input Go version to install: " && read -r go_version
            g install "$go_version"
            g use "$go_version" && g clean
        fi
    elif command_exists g; then
        echo
        warning "You're already installed g (Go version manager)! Trying to update..."
        echo
        g self update
    fi
}

cleanup_home() {
    echo
    info "Cleaning up home..."
    sleep 5
    echo "${FMT_ORANGE}To disable dynamic motd and news:"
    echo "Edit the file ${FMT_YELLOW}/etc/default/motd-news${FMT_ORANGE}"
    echo "FROM: ${FMT_YELLOW}ENABLED=1${FMT_ORANGE} TO: ${FMT_YELLOW}ENABLED=0${FMT_ORANGE}"
    sleep 2
    echo
    echo "${FMT_ORANGE}To disable ~/.sudo_as_admin_successful file, please run this command:"
    echo "${FMT_YELLOW}sudo visudo"
    echo "${FMT_ORANGE}Then add the following line:"
    echo "${FMT_YELLOW}Defaults !admin_flag${FMT_RESET}"
    sleep 3
    if [ ! -f "$HOME/.hushlogin" ]; then touch "$HOME/.hushlogin"; fi
    if [ -f "$HOME/.sudo_as_admin_successful" ]; then rm -f "$HOME/.sudo_as_admin_successful"; fi
    if [ -f "$HOME/.motd_shown" ]; then rm -f "$HOME/.motd_shown"; fi
    sudo apt autoremove && sudo apt clean
    sudo chmod -x /etc/update-motd.d/*
    success "All done!"
}

main() {
    system_update
    stow_dotfiles
    setup_homebrew
    setup_zsh
    setup_nvm
    setup_pyenv
    setup_rust
    setup_rbenv
    setup_go
    cleanup_home
}
main