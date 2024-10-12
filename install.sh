#!/bin/sh

# shellcheck source-path=SCRIPTDIR
DOTFILES="$(pwd)"
. "$DOTFILES/scripts/utils.sh"
. "$DOTFILES/scripts/helpers.sh"
. "$DOTFILES/shared/envs"

GITHUB="https://github.com"

[ ! -d "$XDG_DATA_HOME/gnupg" ] && (mkdir -p "$XDG_DATA_HOME/gnupg" && chmod 600 "$XDG_DATA_HOME/gnupg")
[ ! -d "$XDG_CACHE_HOME/wget" ] && mkdir -p "$XDG_CACHE_HOME/wget"
[ ! -d "$XDG_DATA_HOME/bash" ] && mkdir -p "$XDG_DATA_HOME/bash"

# Update system and install prerequisites
system_update() {
    if [[ "$(uname)" == "Darwin" ]]; then
        xcode-select --install
    fi

    if command_exists apt || command_exists apt-get; then
        if command_exists apt; then APT=apt; else APT=apt-get; fi
        sudo "$APT" update && sudo "$APT" upgrade -y
        check_apt_packages atool build-essential bash-completion ccache cmake curl direnv \
            file g++ gcc git make moreutils stow unzip usbutils zip wamerican wget

        if [[ "$(uname -r)" =~ "WSL" ]]; then
            check_apt_packages wslu
            echo
            if checkyes "Build newest Microsoft Linux Kernel?"; then
                git clone --depth 1 "${GITHUB}/microsoft/WSL2-Linux-Kernel.git" WSL2-Linux-Kernel
                check_apt_packages bc bison build-essential dwarves flex libssl-dev libelf-dev python3 pahole
                builtin cd WSL2-Linux-Kernel
                make -j$(nproc) KCONFIG_CONFIG=Microsoft/config-wsl
                sudo make modules_install headers_install
                printf "Where would you like to put your kernel image on your windows machine? (eg: /mnt/c/)"
                read -r location
                cp arch/x86/boot/bzImage $location
                success "Finished building WSL2 Kernel! After running this script, please exit WSL terminal window."
                echo "${FMT_BLUE}Please follow the instruction in Step 2 & 3 of this link:"
                echo "https://learn.microsoft.com/en-us/community/content/wsl-user-msft-kernel-v6"
                echo "${FMT_RESET}"
            fi
        fi
    fi
}

# Apply dotfiles
stow_dotfiles() {
    echo
    BACKUP_DIR="$HOME/.cache/backup"
    [ -d "$BACKUP_DIR" ] || mkdir -p "$BACKUP_DIR"
    for file in "$HOME/.config/nvim" "$HOME/.vim" "$HOME/.vimrc" "$HOME/.bashrc" "$HOME/.profile"; do 
        if [ ! -L "$file" ]; then
            if [ -d "$file" ] || [ -f "$file" ]; then
                filename=$(basename $file)
                cp -rf "$file" "$BACKUP_DIR/$filename-$(date +%Y-%m-%d_%H-%M-%S)"
                echo "${FMT_PINK}Backing up $file to ${FMT_GREEN}${BACKUP_DIR}/$filename-$(date +%Y-%m-%d_%H-%M-%S)${FMT_RESET}..."
            fi
        else
            error "$file does not exist or already a symlink!"
        fi
    done
    builtin cd "$DOTFILES" && stow .
    echo
    info "Installing Oh-My-Bash..."
    git clone ${GITHUB}/ohmybash/oh-my-bash.git "$XDG_DATA_HOME/bash/oh-my-bash"
}

# Homebrew
setup_homebrew() {
    if ! command_exists brew; then
        echo
        info "Installing Homebrew and Homebrew's packages..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        \. "$DOTFILES/shared/brew"
        brew bundle

        if [[ "$(uname)" == "Darwin" ]]; then
            check_brew_packages cmake make moreutils ninja wget
        fi
    else
        echo
        warning "You're already installed Homebrew. Trying to update..."
        brew update && brew upgrade && brew cleanup --prune=all
    fi
}

# Zsh
setup_zsh() {
    if ! command_exists zsh && checkyes "Could not find ZSH. Install ZSH now?"; then
        echo
        if command_exists apt || command_exists apt-get; then
            check_apt_packages zsh
        else
            check_brew_packages zsh
        fi
        if checkyes "Make ZSH your default shell?"; then
            chsh -s "$(which zsh)" "$USER"
            success "ZSH was set as your default shell."
            info "After running this script, please close and reopen your terminal to take effect"
        fi
    else
        echo
        warning "You're already installed ZSH!"
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
        echo; echo "${FMT_ORANGE}Adding 'git-open' & 'git-recent' as two default packages...${FMT_RESET}" 
        echo "git-open" >> "$NVM_DIR/default_packages"
        echo "git-recent" >> "$NVM_DIR/default_packages"
    fi
}

setup_pyenv() {
    if ! command_exists pyenv && checkyes "Could not find Pyenv. Install now?"; then
        echo
        info "Installing Pyenv..."
        if command_exists apt || command_exists apt-get; then
            check_apt_packages libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
                libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
        else
            check_brew_packages openssl readline sqlite3 xz zlib tcl-tk
        fi

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
            if command_exists apt || command_exists apt-get; then
                check_apt_packages autoconf patch build-essential libssl-dev libyaml-dev libreadline6-dev \
                    zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev
            else
                check_brew_packages openssl@3 readline libyaml gmp
                if ! command_exists rustc; then check_brew_packages rust; fi
            fi

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
        warning "You're already installed Rbenv! Trying to update 'rbenv' and its plugins..."
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
    if command_exists apt || command_exists apt-get; then
        if command_exists apt; then APT=apt; else APT=apt-get; fi
        sudo "$APT" autoremove && sudo "$APT" autoclean
    fi
    if [ -d /etc/update-motd.d ]; then
        sudo chmod -x /etc/update-motd.d/*
    fi
    sleep 5
    echo
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
    if [ ! -f "$HOME/.hushlogin" ] || [ ! -L "$HOME/.hushlogin" ]; then touch "$HOME/.hushlogin"; fi
    if [ -f "$HOME/.sudo_as_admin_successful" ]; then rm -f "$HOME/.sudo_as_admin_successful"; fi
    if [ -f "$HOME/.motd_shown" ]; then rm -f "$HOME/.motd_shown"; fi
    echo
    sleep 3
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
