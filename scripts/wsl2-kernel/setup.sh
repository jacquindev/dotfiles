#!/bin/sh

export DOTFILES="$HOME/.dotfiles"
. "$DOTFILES/scripts/helpers.sh"

if [[ ! "$(uname -r)" =~ "WSL" ]]; then 
    warning "This script only works on WSL machine! Exiting..."
    return
fi

check_apt_packages bc bison cpio dwarves flex libssl-dev libelf-dev python3 pahole wget

KERNEL_VERSION=$(get_latest_release "microsoft/WSL2-Linux-Kernel")
wget --show-progress --timestamping https://github.com/microsoft/WSL2-Linux-Kernel/archive/refs/tags/${KERNEL_VERSION}.tar.gz
mkdir WSL2-Linux-Kernel && tar -xvzf WSL2-Linux-Kernel-${KERNEL_VERSION}.tar.gz
builtin cd WSL2-Linux-Kernel-${KERNEL_VERSION}

# (Optional)
# make menuconfig KCONFIG_CONFIG=Microsoft/config-wsl

# Build the kernel
echo "Building the kernel. This may took awhile. Please be patient..."
sleep 5
echo

make -j$(nproc) KCONFIG_CONFIG=Microsoft/config-wsl
sudo make modules_install headers_install

printf "Input a Kernel location (eg: /mnt/c/) " && read -r location
cp arch/x86_64/boot/bzImage $location

echo
echo 'Please edit your .wslconfig with your kernel location: $location'
echo 'For example, if your location is /mnt/c/ then your config would be:'
echo '[WSL2]'
echo 'kernel=C:\\\\bzImage'
echo

exit 1