#!/bin/bash

get_distribution() {
	lsb_dist=""
	if [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
	fi
	echo "$lsb_dist"
}

sudo systemctl disable --now docker.service docker.socket
if [ -f /var/run/docker.sock ]; then rm -f /var/run/docker.sock; fi

lsb_dist=$(get_distribution)
lsb_dist=$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')

case "$lsb_dist" in
centos | rhel | rocky | fedora)
	sudo dnf install -y shadow-utils fuse-overlayfs iptables dbus-daemon
	;;
ubuntu)
	sudo apt-get install -y dbus-user-session uidmap iptables
	;;
debian | raspbian | osmc)
	sudo apt-get install -y dbus-user-session uidmap iptables fuse-overlayfs slirp4netns iptables
	;;
arch)
	sudo pacman --noconfirm -S fuse-overlayfs
	;;
esac

sudo sh -eux <<EOF
# Load ip_tables module
modprobe ip_tables
EOF

if [ -f '/usr/bin/dockerd-rootless-setuptool.sh' ]; then
	/usr/bin/dockerd-rootless-setuptool.sh install
else
	curl -fsSL https://get.docker.com/rootless | sh

	filename=$(echo "$HOME/bin/rootlesskit" | sed -e s@^/@@ -e s@/@.@g)
	cat <<EOF >"$HOME/${filename}"
abi <abi/4.0>,
include <tunables/global>

"$HOME/bin/rootlesskit" flags=(unconfined) {
  userns,

  include if exists <local/${filename}>
}
EOF
	sudo mv "$HOME/${filename}" "/etc/apparmor.d/${filename}"
	systemctl restart apparmor.service
fi

set -a && source "$HOME/.config/shared/.env" && set +a

sudo systemctl daemon-reload

systemctl --user enable --now docker

if [ -f /proc/sys/kernel/unprivileged_userns_clone ] && [ "$(cat /proc/sys/kernel/unprivileged_userns_clone)" == "0" ]; then
	echo "kernel.unprivileged_userns_clone=1" | sudo tee -a /etc/sysctl.conf
	sudo sysctl --system
	systemctl --user restart docker
fi

sudo loginctl enable-linger "$(whoami)"
