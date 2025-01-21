#!/bin/sh

# Update system
sudo pacman --noconfirm --noprogressbar -Syu

basic_packages="base-devel bison ccache cmake curl file git lsb-release procps-ng wget unzip zip vim"
echo "$basic_packages" | tr ' ' '\n' | while read -r pkg; do
	if ! pacman -Qs "$pkg" >/dev/null 2>&1; then
		sudo pacman --noconfirm -S "$pkg"
	fi
done
unset pkg

# WSL utilities
if uname -r | grep -i -q 'icrosoft'; then
	if ! pacman -Qs wslu >/dev/null 2>&1; then
		sudo pacman-key --init
		wget https://pkg.wslutiliti.es/public.key
		sudo pacman-key --add public.key
		sudo tee -a /etc/pacman.conf <<EOF

[wslutilities]
Server = https://pkg.wslutiliti.es/arch/
EOF
		sudo pacman --noconfirm -Sy && sudo pacman --noconfirm -S wslu
	fi
fi

# Prepare for clean docker engine installation
cleanup_docker() {
	docker_old_pkgs="docker docker-compose"
	echo "$docker_old_pkgs" | tr ' ' '\n' | while read -r pkg; do
		if pacman -Qs "$pkg" >/dev/null 2>&1; then
			sudo pacman --noconfirm -Rs "$pkg"
		fi
	done

	if [ -d /var/lib/docker ]; then sudo rm -rf /var/lib/docker; fi
	if [ -d /var/lib/containerd ]; then sudo rm -rf /var/lib/containerd; fi
}

# Python build dependencies (pyenv)
setup_python_deps() {
	python_deps="openssl zlib xz tk"
	echo "$python_deps" | tr ' ' '\n' | while read -r dep; do
		if ! pacman -Qs "$dep" >/dev/null 2>&1; then
			sudo pacman --noconfirm --needed -S "$dep"
		fi
	done
}

# Ruby build dependencies (rbenv)
setup_ruby_deps() {
	ruby_deps="rust libffi libyaml openssl zlib"
	echo "$ruby_deps" | tr ' ' '\n' | while read -r dep; do
		if ! pacman -Qs "$dep" >/dev/null 2>&1; then
			sudo pacman --noconfirm --needed -S "$dep"
		fi
	done
}
