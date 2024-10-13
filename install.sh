#!/bin/sh

# shellcheck source-path=SCRIPTDIR
DOTFILES="$(pwd)"
. "$DOTFILES/scripts/helpers.sh"
. "$DOTFILES/scripts/envs.sh"
. "$DOTFILES/scripts/paths.sh"

# Make dirs
[ ! -d "$XDG_DATA_HOME/gnupg" ] && (mkdir -p "$XDG_DATA_HOME/gnupg" && chmod 600 "$XDG_DATA_HOME/gnupg")
[ ! -d "$XDG_CACHE_HOME/wget" ] && mkdir -p "$XDG_CACHE_HOME/wget"

# github
GITHUB="https://github.com"

# apt packages
update_system() {
    info "Updating system..."
    update
    check_apt_packages ack atool bash-completion build-essential ccache cmake curl direnv file \
        g++ gcc git make moreutils stow unzip usbutils zip wamerican wget
    if [[ "$(uname -r)" =~ "WSL" ]]; then check_apt_packages wslu; fi
    success "Done!"
}

# backup
backup_dot() {
    BACKUP_DIR="$XDG_CACHE_HOME/backup"
    [ -d "$BACKUP_DIR" ] || mkdir -p "$BACKUP_DIR"
    for dfile in "$HOME/.config/nvim" "$HOME/.vim" "$HOME/.vimrc" "$HOME/.bashrc" "$HOME/.profile" "$HOME/.bash_profile"; do
        if [ ! -L "$dfile" ]; then
            if [ -d "$dfile" ] || [ -f "$dfile" ]; then
                filename="$(basename $dfile)"
                cp -rf "$dfile" "$BACKUP_DIR/$filename-$(date +%Y-%m-%d_%H-%M-%S)"
                echo "${FMT_PINK}Backing up $file to ${FMT_GREEN}${BACKUP_DIR}/$filename-$(date +%Y-%m-%d_%H-%M-%S)${FMT_RESET}..."
            fi
        else
            error "$file does not exist / already a symlink!"
        fi
    done
}

# homebrew
setup_homebrew() {
    if ! command_exists brew; then
        echo
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        \. "$DOTFILES/shared/brew"
        echo
        info "Installing Homebrew packages..."
        brew bundle
        if command_exists oh-my-posh; then oh-my-posh enable autoupgrade; fi
        success "Done!"
    elif command_exists brew; then
        info "Updating Homebrew..."
        brew update && brew upgrade && brew cleanup
    fi
}

# stow
stow_dot() {
    if ! command_exists stow; then check_apt_packages stow || check_brew_packages stow; fi
    [ -f "$HOME/.bashrc" ] && rm -f "$HOME/.bashrc"
    [ -f "$HOME/.profile" ] && rm -f "$HOME/.profile"
    builtin cd "$DOTFILES" && stow .
}

setup_shell() {
    [ ! -d "$XDG_DATA_HOME/bash" ] && mkdir -p "$XDG_DATA_HOME/bash"
    export OSH="$XDG_DATA_HOME/bash/oh-my-bash"
    if [ ! -d "$OSH" ]; then
        info "Installing Oh-My-Bash..."
        git clone "$GITHUB"/ohmybash/oh-my-bash.git "$OSH"
        echo
    fi
    if ! command_exists zsh; then
        info "Installing Zsh..."
        check_apt_packages zsh || check_brew_packages zsh
        if checkyes "Make zsh your default shell?"; then
            chsh -s "$(which zsh)" "$USER"
        fi
        success "Done!"
    fi
}

setup_pyenv() {
    if ! command_exists pyenv && checkyes "Install Pyenv?"; then
        echo
        info "Installing pyenv..."

        # python build prep
        if command_exists apt; then
            check_apt_packages libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
                libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
        else
            check_brew_packages openssl readline sqlite3 xz zlib tcl-tk
        fi

        [ -d "$PYENV_ROOT" ] && rm -rf "$PYENV_ROOT"

        export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PYENV_ROOT/versions/global/bin:$PATH"
        
        checkout "${GITHUB}/pyenv/pyenv.git" "${PYENV_ROOT}" "${PYENV_GIT_TAG:-master}"
        checkout "${GITHUB}/pyenv/pyenv-doctor.git" "${PYENV_ROOT}/plugins/pyenv-doctor" "master"
        checkout "${GITHUB}/pyenv/pyenv-update.git" "${PYENV_ROOT}/plugins/pyenv-update" "master"
        checkout "${GITHUB}/pyenv/pyenv-virtualenv.git" "${PYENV_ROOT}/plugins/pyenv-virtualenv" "master"
        checkout "${GITHUB}/pyenv/pyenv-ccache.git" "${PYENV_ROOT}/plugins/pyenv-ccache" "master"

        builtin cd "$PYENV_ROOT" && src/configure && make -C src
        
        {
            "${PYENV_ROOT}/bin/pyenv" init
            "${PYENV_ROOT}/bin/pyenv" virtualenv-init
        } >&2

        echo
        info "Installing python..."
        pyenv install --list | grep '^  3.'
        printf "${FMT_PINK}Input a Python version: ${FMT_RESET}" && read -r python_version
        pyenv install "$python_version" --verbose
        pyenv global "$python_version"
        builtin cd "$PYENV_ROOT/versions/" && ln -sf "$python_version" global
        pyenv rehash

        builtin cd "$DOTFILES"
        success "Done!"
    elif command_exists pyenv; then
        info "Updating Pyenv..."
        pyenv update
    fi

    python3 -m ensurepip --upgrade
    python3 -m pip install --upgrade --user pip --force

    if ! command_exists pipx; then
        info "Installing pipx..."
        python3 -m pip install --user pipx
    fi
}

setup_poetry() {
    if ! command_exists poetry && checkyes "Install PyPoetry?"; then
        echo
        info "Installing PyPoetry..."
        export PATH="$POETRY_HOME/bin:$PATH"
        curl -sSL https://install.python-poetry.org | python3 -
        echo
        info "Installing PyPoetry's plugins..."
        poetry self add "poetry-dotenv-plugin"
        poetry self add "poetry-dynamic-versioning[plugin]"
        poetry self add "poetry-multiproject-plugin"
        success "Done!"
    elif command_exists poetry; then
        info "Updating PyPoetry..."
        poetry self update
    fi
}

setup_rustup() {
    if (! command_exists rustup || ! command_exists cargo) && checkyes "Install RustUp?"; then
        echo
        info "Installing RustUp..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path
        \. "${CARGO_HOME}/env"
        echo
        info "Adding cargo packages..."
        curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
        cargo binstall --no-confirm cargo-cache cargo-update cargo-run-bin \
            bingrep git-graph hyperfine miniserve tealdeer
    elif command_exists rustup; then
        info "Updating rustup..."
        rustup self update
    fi
}

setup_rbenv() {
    if ! command_exists rbenv && checkyes "Install Rbenv?"; then
        echo
        info "Installing Rbenv..."
        export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$RBENV_ROOT/versions/global/bin:$PATH"

        if command_exists apt || command_exists apt-get; then
            check_apt_packages autoconf patch build-essential libssl-dev libyaml-dev libreadline6-dev \
                zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev
            if ! command_exists rustc; then check_apt_packages rustc; fi
        else
            check_brew_packages openssl@3 readline libyaml gmp
            if ! command_exists rustc; then check_brew_packages rust; fi
        fi

        [ -d "$RBENV_ROOT" ] && rm -rf "$RBENV_ROOT"

        checkout "${GITHUB}/rbenv/rbenv.git" "${RBENV_ROOT}" "${RBENV_GIT_TAG:-master}"
        checkout "${GITHUB}/rbenv/ruby-build.git" "${RBENV_ROOT}/plugins/ruby-build" "master"
        checkout "${GITHUB}/rbenv/rbenv-default-gems" "${RBENV_ROOT}/plugins/rbenv-default-gems" "master"
        checkout "${GITHUB}/jf/rbenv-gemset.git" "${RBENV_ROOT}/plugins/rbenv-gemset" "master"
        checkout "${GITHUB}/rkh/rbenv-update.git" "${RBENV_ROOT}/plugins/rbenv-update" "master"
        checkout "${GITHUB}/rkh/rbenv-use.git" "${RBENV_ROOT}/plugins/rbenv-use" "master"
        checkout "${GITHUB}/rkh/rbenv-whatis.git" "${RBENV_ROOT}/plugins/rbenv-whatis" "master"
        checkout "${GITHUB}/yyuu/rbenv-ccache.git" "${RBENV_ROOT}/plugins/rbenv-ccache" "master"

        "$RBENV_ROOT/bin/rbenv" init >&2

        info
        echo "Installing ruby..."
        rbenv install --list
        printf "${FMT_PINK}Input a Ruby version: ${FMT_RESET}" && read -r ruby_version
        rbenv install "$ruby_version" --verbose
        rbenv global "$ruby_version"
        builtin cd "$RBENV_ROOT/versions/" && ln -sf "$ruby_version" global
        rbenv rehash
        # rbenv doctor
        curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-doctor | bash

        builtin cd "$DOTFILES"
        success "Done!"
    elif command_exists rbenv; then
        info "Updating rbenv..."
        rbenv update
    fi
}

setup_golang() {
    if ! command_exists go; then
        if [[ -n $(alias g 2>/dev/null) ]]; then unalias g; fi
        if ! command_exists g && checkyes "Install g (go version manager)?"; then
            echo
            info "Installing g..."
            curl -sSL https://raw.githubusercontent.com/voidint/g/master/install.sh | bash
            \. "$HOME/.g/env"
            g ls-remote stable
            echo
            info "Installing go..."
            printf "${FMT_PINK}Input a Go version: ${FMT_RESET}" && read -r go_version
            g install "$go_version"
            g use "$go_version" && g clean
            success "Done!"
        elif command_exists g; then
            info "Updating g..."
            g self update
        fi
    fi
}

clean_home() {
    echo
    info "Cleaning up home..."
    if command_exists apt; then sudo apt autoremove && sudo apt autoclean; else sudo apt-get autoremove && sudo apt-get autoclean; fi
    if [ -d /etc/update-motd.d ]; then sudo chmod -x /etc/update-motd.d/*; fi
    # sleep 5
    # echo
    # echo "${FMT_ORANGE}To disable dynamic motd and news:"
    # echo "Edit the file ${FMT_YELLOW}/etc/default/motd-news${FMT_ORANGE}"
    # echo "FROM: ${FMT_YELLOW}ENABLED=1${FMT_ORANGE} TO: ${FMT_YELLOW}ENABLED=0${FMT_ORANGE}"
    # sleep 2
    # echo
    # echo "${FMT_ORANGE}To disable ~/.sudo_as_admin_successful file, please run this command:"
    # echo "${FMT_YELLOW}sudo visudo"
    # echo "${FMT_ORANGE}Then add the following line:"
    # echo "${FMT_YELLOW}Defaults !admin_flag${FMT_RESET}"
    # sleep 3
    if [ ! -f "$HOME/.hushlogin" ] || [ ! -L "$HOME/.hushlogin" ]; then touch "$HOME/.hushlogin"; fi
    if [ -f "$HOME/.sudo_as_admin_successful" ]; then rm -f "$HOME/.sudo_as_admin_successful"; fi
    if [ -f "$HOME/.motd_shown" ]; then rm -f "$HOME/.motd_shown"; fi
    success "Done!"
}

run() {
    setup_color
    update_system
    backup_dot
    setup_homebrew
    stow_dot
    setup_shell
    setup_pyenv
    setup_poetry
    setup_rustup
    setup_rbenv
    setup_golang
    clean_home
}
run
