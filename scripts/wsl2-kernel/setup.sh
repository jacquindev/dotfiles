#!/bin/sh

export DOTFILES="$HOME/.dotfiles"
. "$DOTFILES/scripts/helpers.sh"

if [[ ! "$(uname -r)" =~ "WSL" ]]; then return; fi

check_apt_packages bc bison cpio dwarves flex libssl-dev libelf-dev python3 pahole

git clone https://github.com/microsoft/WSL2-Linux-Kernel.git --depth 1 -b linux-msft-wsl-6.6.y
builtin cd WSL2-Linux-Kernel

# (Optional)
make menuconfig KCONFIG_CONFIG=Microsoft/config-wsl

# Build the kernel
make KCONFIG_CONFIG=Microsoft/config-wsl

sudo make modules_install headers_install

printf "Input a Kernel location (eg: /mnt/c/) " && read -r location
cp arch/x86/boot/bzImage $location
exit
