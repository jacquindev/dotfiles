#!/bin/sh

#if command -v fish >/dev/null 2>&1; then return; fi

get_distribution() {
	lsb_dist=""
	if [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
	fi
	echo "$lsb_dist"
}

lsb_dist=$(get_distribution)
lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

case "$lsb_dist" in
ubuntu | mint | linuxmint)
	lsb_dist=ubuntu
	if command -v lsb_release >/dev/null 2>&1; then
		dist_version="$(lsb_release --codename | cut -f2)"
	fi

	if [ -z "$dist_version" ] && [ -r /etc/lsb-release ]; then
		dist_version="$(. /etc/lsb-release && echo "$DISTRIB_CODENAME")"
	fi
;;
debian | raspbian | osmc | kali | kalilinux)
	lsb_dist=debian
	dist_version="$(sed 's/\/.*//' /etc/debian_version | sed 's/\..*//')"
	case "$dist_version" in
	12) dist_version="bookworm" ;;
	11) dist_version="bullseye" ;;
	10) dist_version="buster" ;;
	esac
;;
centos | rhel | rocky | redhat | fedora)
	lsb_dist=redhat
	if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
		dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
	fi
;;
*)
	lsb_dist="$lsb_dist"
	if command_exists lsb_release; then
		dist_version="$(lsb_release --release | cut -f2)"
	fi
	if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
		dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
	fi
;;
esac

case "$lsb_dist" in
	redhat) sudo dnf install fish util-linux-user -y ;;
	debian)
		case "$dist_version" in
		bookworm) deb_fish_repo="Debian_12" ;;
		bullseye) deb_fish_repo="Debian_11" ;;
		buster) deb_fish_repo="Debian_10" ;;
		esac

		deb_fish_url="http://download.opensuse.org/repositories/shells:/fish:/release:/3/${deb_fish_repo}/"
		echo "deb $deb_fish_url /" | sudo tee /etc/apt/sources.list.d/shells:fish:release:3.list
		curl -fsSL "${deb_fish_url}Release.key" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg > /dev/null
		sudo apt update
		sudo apt install fish -y -qq
	;;
	ubuntu)
		sudo apt-add-repository ppa:fish-shell/release-3
		sudo apt update
		sudo apt install fish -y -qq
	;;
esac
