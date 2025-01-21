#!/bin/sh

if ! command -v dnf >/dev/null 2>&1; then
	sudo yum upgrade -yq
	sudo yum install dnf -yq
else
	sudo dnf upgrade -yq
fi

# Development Tools
if ! dnf group list --installed | grep 'Development Tools' >/dev/null 2>&1; then
	sudo dnf group install 'Development Tools' -yq
fi

# RPM Packages
basic_packages="bison ca-certificates cmake curl epel-release file git wget procps-ng lsb_release unzip zip vim"

echo "$basic_packages" | tr ' ' '\n' | while read -r pkg; do
	if ! dnf list --installed | grep "$pkg" >/dev/null 2>&1; then
		sudo dnf install "$pkg" -yq
	fi
done
unset pkg

# WSL utilities
if uname -r | grep -i -q 'icrosoft'; then
	if ! dnf list --installed | grep wslu >/dev/null 2>&1; then
		sudo dnf install epel-release dnf-plugins-core -yq
		sudo dnf config-manager --set-enabled PowerTools -y
		sudo dnf copr enable wslutilities/wslu -y
		sudo dnf install wslu -y
	fi
fi

# Prepare for clean docker engine installation
cleanup_docker() {
	docker_old_pkgs="docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-selinux docker-engine-selinux docker-engine"
	echo "$docker_old_pkgs" | tr ' ' '\n' | while read -r pkg; do
		if dnf list --installed | grep "$pkg" >/dev/null 2>&1; then
			sudo dnf remove "$pkg" -yq
		fi
	done

	if [ -d /var/lib/docker ]; then sudo rm -rf /var/lib/docker; fi
	if [ -d /var/lib/containerd ]; then sudo rm -rf /var/lib/containerd; fi
}

# Python build dependencies (pyenv)
setup_python_deps() {
	distro_name=$(lsb_release -i | cut -f2 | tr '[:upper:]' '[:lower:]')
	distro_ver=$(lsb_release -r | cut -f2)

	if expr "x$distro_name" : 'x.^fedora*$' >/dev/null && [ "$distro_ver" -ge 22 ]; then
		python_deps="make gcc patch zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel libuuid-devel gdbm-libs libnsl2"
	else
		python_deps="make gcc path zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel"
	fi

	echo "$python_deps" | tr ' ' '\n' | while read -r dep; do
		if ! dnf list --installed | grep "$dep" >/dev/null 2>&1; then
			sudo dnf install "$dep" -yq
		fi
	done
	unset dep
}

# Ruby build dependencies (rbenv)
setup_ruby_deps() {
	ruby_deps="autoconf gcc make patch bzip2 openssl-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel tar libyaml-devel perl-FindBin"

	echo "$ruby_deps" | tr ' ' '\n' | while read -r dep; do
		if ! dnf list --installed | grep "$dep" >/dev/null 2>&1; then
			sudo dnf install "$dep" -yq
		fi
	done
	unset dep
}
