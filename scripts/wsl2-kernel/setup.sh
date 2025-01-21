#!/bin/sh

if ! uname -r | grep -i -q 'microsoft'; then
  echo "$(tput setaf 220)WARNING: This script is intended to use with WSL Machine only! Exiting...$(tput sgr0)"
  return 0
fi

# For more information, please visit https://github.com/microsoft/WSL2-Linux-Kernel

sudo apt update -qq >/dev/null 2>&1

set -- bison build-essential cpio dwarves flex libelf-dev libssl-dev
for pkg in "$@"; do
  sudo apt install -y -qq "$pkg" >/dev/null 2>&1
done
unset pkg

REPO="WSL2-Linux-Kernel"
GITHUB="https://github.com/"

git clone ${GITHUB}microsoft/${REPO}.git --depth=1
cd ${REPO} || exit

# (Optional)
# make menuconfig KCONFIG_CONFIG=Microsoft/config-wsl

make KCONFIG_CONFIG=Microsoft/config-wsl
sudo make modules_install headers_install

echo ""
printf "Input a Kernel Location on your Windows system (e.g.: /mnt/c/) " && read -r location
cp arch/x86_64/boot/bzImage "$location"

echo ""
printf 'Please edit your .wslconfig with your kernel location.\n'
printf 'For example, if your location is /mnt/c/ then your config would be:\n'
printf '\n'
printf '[WSL2]\n'
printf 'kernel=C:\\\\bzImage\n'
echo ""
