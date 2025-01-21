#!/bin/sh

# Update system
sudo apt update && sudo apt upgrade -y -qq

basic_packages="bison build-essential ccache cmake curl file git lsb-release procps unzip zip wget vim"
echo "$basic_packages" | tr ' ' '\n' | while read -r pkg; do
	if ! dpkg -s "$pkg" >/dev/null 2>&1; then
		sudo apt install "$pkg" -y -qq
	fi
done
unset pkg

# Install wslu
if uname -r | grep -i -q 'icrosoft'; then
	if ! dpkg -s wslu >/dev/null 2>&1; then
		distro=$(lsb_release -i | cut -f2 | tr '[:upper:]' '[:lower:]')
		case $distro in
		ubuntu)
			sudo add-apt-repository ppa:wslutilities/wslu
			sudo apt-get update
			sudo apt-get install wslu -y
			;;
		*)
			sudo apt-get install -y -qq gnupg2 apt-transport-https
			wget -O - https://pkg.wslutiliti.es/public.key | sudo gpg -o /usr/share/keyrings/wslu-archive-keyring.pgp --dearmor

			echo "deb [signed-by=/usr/share/keyrings/wslu-archive-keyring.pgp] https://pkg.wslutiliti.es/debian \
				$(. /etc/os-release && echo "$VERSION_CODENAME") main" | sudo tee /etc/apt/sources.list.d/wslu.list

			sudo apt-get update
			sudo apt-get install wslu -y
			;;
		esac
	fi
fi

# Prepare for clean docker engine installation
cleanup_docker() {
	docker_old_pkgs="docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc"
	echo "$docker_old_pkgs" | tr ' ' '\n' | while read -r pkg; do
		if dpkg -s "$pkg" >/dev/null 2>&1; then
			sudo apt remove "$pkg" -y
		fi
	done

	if [ -d /var/lib/docker ]; then sudo rm -rf /var/lib/docker; fi
	if [ -d /var/lib/containerd ]; then sudo rm -rf /var/lib/containerd; fi
	if [ -f /etc/apt/sources.list.d/docker.list ]; then sudo rm -f /etc/apt/sources.list.d/docker.list; fi
	if [ -f /etc/apt/keyrings/docker.asc ]; then sudo rm -f /etc/apt/keyrings/docker.asc; fi
}

# Python build dependencies (pyenv)
setup_python_deps() {
	python_deps="libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev"
	echo "$python_deps" | tr ' ' '\n' | while read -r dep; do
		if ! dpkg -s "$dep" >/dev/null 2>&1; then
			sudo apt install "$dep" -y -qq
		fi
	done
}

# Ruby build dependencies (rbenv)
setup_ruby_deps() {
	ruby_deps="autoconf patch rustc libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev"
	echo "$ruby_deps" | tr ' ' '\n' | while read -r dep; do
		if ! dpkg -s "$dep" >/dev/null 2>&1; then
			sudo apt install "$dep" -y -qq
		fi
	done
}
