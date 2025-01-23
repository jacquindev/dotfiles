#!/bin/sh

# shellcheck disable=SC1091,SC2059,SC3010

# shellcheck source-path=SCRIPTDIR
CURRENT_LOCATION=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
SHARED_DIR="$CURRENT_LOCATION/shared"
SCRIPTS_DIR="$CURRENT_LOCATION/scripts"

# Colors output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

GITHUB="https://github.com"

print_title() {
	title="$1"
	echo; i=0; while [ "$i" -lt ${#title} ]; do printf "${BLUE}#${NC}"; i=$((i+1)); done; echo
	printf "${BLUE}$title${NC}"
	echo; i=0; while [ "$i" -lt ${#title} ]; do printf "${BLUE}#${NC}"; i=$((i+1)); done; echo
}

load_envs() {
	set -o allexport && \. "$SHARED_DIR/.env" && set +o allexport
	\. "$SHARED_DIR/path.sh"
	\. "$SHARED_DIR/brew.sh"
}

main() {
	# Specify ditribution name of the machine
	if type lsb_release >/dev/null 2>&1; then
		DISTRO="$(lsb_release -i | cut -f2 | tr '[:lower:]' '[:upper:]')"
	else
		DISTRO="$(awk -F'=' '/^ID=/ {print toupper($2)}' /etc/*-release | tr -d '"')"
	fi

	print_title "Start Setup for $DISTRO Machine"
	load_envs

	# Define package manager
	PACKAGER=""
	for pm in apt dnf yum pacman; do
		if command -v $pm >/dev/null 2>&1; then
			PACKAGER="$pm"
		fi
	done
	unset pm

	if [ -z "$PACKAGER" ]; then
		printf "${RED}Your machine is currently not supported. Exiting...${NC}\n"
		exit 1
	fi

	case "$PACKAGER" in
	dnf | yum) \. "$SCRIPTS_DIR/fedora.sh" ;;
	apt) \. "$SCRIPTS_DIR/debian.sh" ;;
	pacman) \. "$SCRIPTS_DIR/arch.sh" ;;
	esac
}

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

checkout() {
	[ -d "$2" ] || git -c advice.detachedHead=0 clone --branch "$3" --depth 1 "$1" "$2" >/dev/null 2>&1
}

create_dirs() {
	# Create XDG directories
	print_title 'Create XDG Directories'
	LOCATIONS="$XDG_CONFIG_HOME $XDG_CACHE_HOME $XDG_DATA_HOME $XDG_STATE_HOME $XDG_BIN_HOME $XDG_RUNTIME_DIR $XDG_PROJECTS_DIR $XDG_CACHE_HOME/backup"
	echo "$LOCATIONS" | tr ' ' '\n' | while read -r loc; do
		sleep 0.05
		if [ ! -d "$loc" ]; then
			mkdir -p "$loc"
			if [ $? -eq 0 ]; then printf "${GREEN}$loc${NC} created successfully.\n"; fi
		else
			printf "${YELLOW}$loc${NC} already exists.\n"
		fi
	done
	unset loc
}

setup_docker() {
	print_title 'Setup Docker & Docker Rootless Mode'
	load_envs
	cleanup_docker

	# shellcheck disable=SC3010
	if [[ "$(uname -r)" != *"icrosoft"* ]]; then
		if ! command_exists docker; then
			printf "${PURPLE}Start installing Docker...${NC}\n"
			sudo sh "$SCRIPTS_DIR/docker_engine.sh"
			sudo systemctl enable --now docker containerd
			sudo usermod -aG docker "$USER"
		else
			printf "${YELLOW}Docker Engine${NC} already exists. Skipping...\n"
		fi

		if [ ! -f "$HOME/.config/systemd/user/docker.service" ]; then
			printf "${PURPLE}Setup Docker Rootless Mode? (y/N)${NC} " && read -r yn
			case $yn in
			[yY]*) sh "$SCRIPTS_DIR/docker_rootless.sh" ;;
			[nN]* | [qQ]*) echo "Skipped setting up Docker Rootless Mode..." ;;
			*)
				echo "Invalid choice. Exiting..."
				exit 0
				;;
			esac
		else
			printf "${GREEN}Docker Rootless Mode${NC} already setup. Exiting...\n"
		fi
	else
		if ! command_exists docker; then
			printf "${RED}Docker Desktop not found. Please install Docker Desktop for your Windows machine!${NC}\n"
		else
			printf "${GREEN}Docker already installed.${NC}\n"
		fi
	fi
}

setup_homebrew() {
	print_title "Setup Homebrew"
	load_envs

	# Setup Homebrew
	if ! command_exists brew; then
		NON_INTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		brew doctor
		echo
	fi
	brew bundle install --file="$CURRENT_LOCATION/Brewfile" --quiet
}

setup_gitconfig() {
	print_title "Setup Git"
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
}

# shellcheck disable=SC2016
stow_dotfiles() {
	print_title "Stow Dotfiles"
	if ! command_exists stow; then brew install stow --quiet; fi
	if ! grep -q '$HOME/dotfiles.sh' "$HOME/.bashrc"; then
		{
			echo ''
			echo '# Get dotfiles directory'
			echo 'if [ -f "$HOME/dotfiles.sh" ]; then'
			echo '	source "$HOME/dotfiles.sh"'
			echo 'fi'
		} >>"$HOME/.bashrc"
	fi
	if ! grep -q '$HOME/.config/bash/bashrc' "$HOME/.bashrc"; then
		{
			echo ''
			echo '# Source custom bashrc'
			echo 'if [ -f "$HOME/.config/bash/bashrc" ]; then'
			echo '	source "$HOME/.config/bash/bashrc"'
			echo 'fi'
		} >>"$HOME/.bashrc"
	fi

	if [ -f "$HOME/.zshenv" ]; then mv "$HOME/.zshenv" "$HOME/.cache/backup/.zshenv.bak"; fi
	stow .
	sleep 5
}

setup_devtools() {
	print_title "Setup Development Tools"

	# gum settings
	export ALIGN="center"
	export BORDER_FOREGROUND="#89b4fa"
	export BORDER="rounded"
	export FOREGROUND="#cba6f7"
	export GUM_CHOOSE_HEADER_FOREGROUND="#f9e2af"
	export GUM_SPIN_SPINNER_FOREGROUND="#fab387"
	export GUM_SPIN_TITLE_FOREGROUND="#94e2d5"
	export PADDING="1 2"

	# Dev tools
	devtools_choose=$(gum choose --no-limit --header="Choose Dev Tools to setup your local machine:" '1) NVM (Node Version Manager)' '2) GOENV (Go Version Manager)' '3) PYENV (Python Version Manager)' '4) RBENV (Ruby Version Manager)' '5) RUSTUP (Rust Installer Tool)' '6) SDKMAN (Software Development Kit Manager)')
	devtools=$(echo "$devtools_choose" | cut -f2 -d ' ' | tr '[:upper:]' '[:lower:]')

	# Setup NVM
	setup_nvm() {
		echo
		gum style "Setup NVM (Node Version Manager)"

		load_envs

		if ! command_exists nvm || ! command_exists node || ! command_exists npm; then
			export NVM_DIR="$HOME/.local/share/nvm"
			if [ -d "$NVM_DIR" ]; then rm -rf "$NVM_DIR"; fi
			mkdir -p "$NVM_DIR"
			curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
			gum confirm "Use LTS (Y) or latest (n) node?" && nvm install --lts || nvm install node
			nvm install-latest-npm
			npm install --global pnpm@latest
		fi

		export NVM_DIR="$HOME/.local/share/nvm"
		[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
		[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

		PATH="$(npm config get prefix)/bin:$PNPM_HOME:$PATH"
		export PATH

		if command_exists pnpm; then
			npm_c='pnpm add -g'
			npm_l='pnpm ls -g'
		else
			npm_c='npm install -g'
			npm_l='npm ls -g'
		fi

		for pkg in bun commitizen cz-git; do
			if ! $npm_l | grep -q "$pkg"; then
				$npm_c $pkg
			fi
		done
		unset npm_c npm_l
		sleep 5
	}

	# Setup GOENV
	setup_goenv() {
		echo
		gum style "Setup GOENV (Go Version Manager)"

		load_envs

		if ! command_exists goenv; then
			export GOENV_ROOT="$HOME/.local/share/goenv"
			if [ -d "$GOENV_ROOT" ]; then rm -rf "$GOENV_ROOT"; fi
			git clone --quiet "$GITHUB/go-nv/goenv.git" "$GOENV_ROOT"
			load_envs
			# Initialize goenv
			eval "$(goenv init -)"
		fi

		if command_exists goenv && ! command_exists go; then
			go_version=$(goenv install --list | grep '^  1.' | sed 's/[[:space:]]//g' | gum choose --height=15 --header="Choose a Go version to install:")
			goenv install "$go_version"
			goenv global "$go_version"
			ln -sf "$GOENV_ROOT/versions/$go_version" "$GOENV_ROOT/versions/global"
			goenv rehash
		fi
		sleep 5
	}

	# Setup PYENV
	setup_pyenv() {
		echo
		gum style "Setup PYENV (Python Version Manager)"

		load_envs
		setup_python_deps

		if [[ "$(command -v pyenv)" == */pyenv-win/* && "$(uname -r)" == *icrosoft* ]]; then
			PYENV_AVAIL=0
		elif ! command_exists pyenv >/dev/null 2>&1; then
			PYENV_AVAIL=0
		else
			PYENV_AVAIL=1
		fi

		if [[ $PYENV_AVAIL -eq 0 ]]; then
			export PYENV_ROOT="$HOME/.local/share/pyenv"
			if [ -d "$PYENV_ROOT" ]; then rm -rf "$PYENV_ROOT"; fi

			checkout "${GITHUB}/pyenv/pyenv.git" "$PYENV_ROOT" "master"

			pyenv_plugins="pyenv-doctor pyenv-update pyenv-virtualenv pyenv-ccache pyenv-pip-migrate"
			echo "$pyenv_plugins" | tr ' ' '\n' | while read -r plugin; do
				if [ ! -d "$PYENV_ROOT/plugins/$plugin" ]; then
					checkout "${GITHUB}/pyenv/$plugin.git" "$PYENV_ROOT/plugins/$plugin" "master"
				fi
			done

			cd "$PYENV_ROOT" && src/configure && make -C src >/dev/null
			cd "$CURRENT_LOCATION" || exit 1

			{
				"$PYENV_ROOT/bin/pyenv" init
				"$PYENV_ROOT/bin/pyenv" virtualenv-init
			} >&2

			load_envs

			[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
			eval "$(pyenv init -)"
			eval "$(pyenv virtualenv-init -)"

			python_version=$(pyenv install --list | grep '^  3.' | sed 's/[[:space:]]//g' | gum choose --height=15 --header="Choose a Python Version to install:")
			pyenv install "$python_version"
			pyenv global "$python_version"
			ln -sf "$PYENV_ROOT/versions/$python_version" "$PYENV_ROOT/versions/global"
			pyenv rehash
			sleep 5
		fi

		gum confirm "Install Python Tools for your machine? (pipx|pipenv|pdm|poetry|rye|uv)" && \. "$SCRIPTS_DIR/python_tools.sh" || echo "Skip installing python tools."
		sleep 5
	}

	# setup RBENV
	setup_rbenv() {
		echo
		gum style "Setup RBENV (Ruby Version Manager)"

		load_envs
		setup_ruby_deps

		if ! command_exists rbenv; then
			export RBENV_ROOT="$HOME/.local/share/rbenv"

			if [ -d "$RBENV_ROOT" ]; then rm -rf "$RBENV_ROOT"; fi
			checkout "${GITHUB}/rbenv/rbenv.git" "$RBENV_ROOT" "master"

			rbenv_plugin="rbenv/ruby-build rbenv/rbenv-default-gems jf/rbenv-gemset rkh/rbenv-update rkh/rbenv-use rkh/rbenv-whatis yyuu/rbenv-ccache"
			echo "$rbenv_plugin" | tr ' ' '\n' | while read -r plugin; do
				dir=$(basename "$plugin")
				if [ ! -d "$RBENV_ROOT/plugins/$dir" ]; then
					checkout "${GITHUB}/$plugin.git" "${RBENV_ROOT}/plugins/$dir" "master"
				fi
			done

			"$RBENV_ROOT/bin/rbenv" init
		fi

		eval "$("$RBENV_ROOT/bin/rbenv" init -)"

		if command_exists rbenv && rbenv version | grep -q 'system'; then
			ruby_version=$(rbenv install --list | gum choose --header="Choose A Ruby Version to install:")
			rbenv install "$ruby_version"
			rbenv global "$ruby_version"
			ln -sf "$RBENV_ROOT/versions/$ruby_version" "$RBENV_ROOT/versions/global"
			rbenv rehash
		fi
		sleep 5
	}

	# setup RUSTUP
	setup_rustup() {
		echo
		gum style "Setup RUSTUP (Rust Installer Tool)"

		load_envs

		if [ -f "$CARGO_HOME/env" ]; then
			\. "$CARGO_HOME/env"
		elif ! command_exists rustup || ! command_exists cargo || [[ "$(which cargo)" != *"$CARGO_HOME"* ]]; then
			export RUSTUP_HOME="$HOME/.local/share/rustup"
			export CARGO_HOME="$HOME/.local/share/cargo"

			if [ -d "$RUSTUP_HOME" ]; then rm -rf "$RUSTUP_HOME"; fi
			if [ -d "$CARGO_HOME" ]; then rm -rf "$CARGO_HOME"; fi

			curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --quiet --no-modify-path
			\. "$CARGO_HOME/env"
		fi

		if command_exists cargo && ! command_exists cargo-binstall; then
			curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
		fi

		if command_exists cargo && command_exists cargo-binstall; then
			for pkg in cargo-update cargo-cache cargo-run-bin; do
				if ! cargo install --list | grep -q "$pkg"; then
					cargo binstall --no-confirm "$pkg"
				fi
			done
		fi
		sleep 5
	}

	setup_sdkman() {
		echo
		gum style "Setup SDKMAN! (Software Development Kit Manager)"

		load_envs

		export SDKMAN_DIR="$HOME/.local/share/sdkman"
		if [ ! -f "$SDKMAN_DIR/bin/sdkman-init.sh" ] || ! command_exists sdk; then
			curl -s "https://get.sdkman.io?rcupdate=false" | bash
			\. "$SDKMAN_DIR/bin/sdkman-init.sh"
		elif [ -f "$SDKMAN_DIR/bin/sdkman-init.sh" ] && ! command_exists sdk; then
			\. "$SDKMAN_DIR/bin/sdkman-init.sh"
		fi

		if command_exists sdk && ! command_exists java; then sdk install java; fi
		sleep 5
	}

	if [[ " ${devtools[*]} " =~ [[:space:]]nvm[[:space:]] ]]; then setup_nvm; fi
	if [[ " ${devtools[*]} " =~ [[:space:]]goenv[[:space:]] ]]; then setup_goenv; fi
	if [[ " ${devtools[*]} " =~ [[:space:]]pyenv[[:space:]] ]]; then setup_pyenv; fi
	if [[ " ${devtools[*]} " =~ [[:space:]]rbenv[[:space:]] ]]; then setup_rbenv; fi
	if [[ " ${devtools[*]} " =~ [[:space:]]rustup[[:space:]] ]]; then setup_rustup; fi
	if [[ " ${devtools[*]} " =~ [[:space:]]sdkman[[:space:]] ]]; then setup_sdkman; fi
}

setup_bat() {
	# Bat theme
	if command_exists bat; then
		gum spin --title="Setting up bat theme..." -- bat cache --clear
		gum spin --title="Setting up bat theme..." -- bat cache --build
	fi
}

setup_yazi() {
	# Yazi plugins
	if command_exists yazi && command_exists ya; then
		gum spin --title="Setting up yazi..." -- ya pack -i
		gum spin --title="Setting up yazi..." -- ya pack -u
	fi
}

cleanup() {
	[ -f "$HOME/.wget-hsts" ] && mv -i "$HOME/.wget-hsts" "$XDG_CACHE_HOME/wget/wget-hsts"
	[ -f "$HOME/.sudo_as_admin_successful" ] && rm -f "$HOME/.sudo_as_admin_successful"
	[ -f "$HOME/.motd_shown" ] && rm -f "$HOME/.motd_shown"
}

create_dirs
main
setup_docker
setup_homebrew
setup_gitconfig
stow_dotfiles
setup_devtools
setup_bat
setup_yazi
cleanup

echo; echo
echo "$(tput bold)$(tput setaf 3)NOTES:$(tput sgr0)"
echo "To suppress new file creation of $HOME/.sudo_as_admin_successful"
echo "In your terminal, type 'sudo visudo' and add the following to the file:"
echo
echo "Defaults        !admin_flag"
echo

# END SCRIPT
# --------------------------------------------------------------------------------
echo
echo "$(tput setaf 8)--------------------------------------------------------------------------$(tput sgr0)"
echo "$(tput setaf 7)For more information, please visit: $(tput setaf 4)https://github.com/jacquindev/dotfiles"
echo "$(tput setaf 7)- Submit an issue via: $(tput setaf 4)https://github.com/jacquindev/dotfiles/issues/new"
echo "$(tput setaf 7)- Contact me via email: $(tput setaf 4)jacquindev@outlook.com"
echo; echo
