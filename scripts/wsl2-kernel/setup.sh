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
mkdir WSL2-Linux-Kernel
tar -xvzf WSL2-Linux-Kernel-${KERNEL_VERSION}.tar.gz -C WSL2-Linux-Kernel
rm -f WSL2-Linux-Kernel-${KERNEL_VERSION}.tar.gz
builtin cd WSL2-Linux-Kernel && make -j$(nproc) KCONFIG_CONFIG=Microsoft/config-wsl

# (Optional)
# make menuconfig KCONFIG_CONFIG=Microsoft/config-wsl

# Build the kernel
make -j$(nproc) KCONFIG_CONFIG=Microsoft/config-wsl

sudo make modules_install headers_install

printf "Input a Kernel location (eg: /mnt/c/) " && read -r location
cp arch/x86/boot/bzImage $location
cd .. && rm -rf WSL2-Linux-Kernel

echo
echo 'Please edit your .wslconfig with your kernel location: $location'
echo 'For example, if your location is /mnt/c/ then your config would be:'
echo '[WSL2]'
echo 'kernel=C:\\\\bzImage'
echo

exit 1