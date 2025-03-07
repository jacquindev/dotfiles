#!/usr/bin/env zsh

export ASDF_DATA_DIR="$HOME/.asdf"
export ASDF_CONFIG_FILE="${ASDF_DATA_DIR}/asdfrc"

if [ -d "${ASDF_DATA_DIR}/shims" ]; then
	pathprepend "${ASDF_DATA_DIR}/shims"
fi

ASDF_PLUGINS_DIR="${ASDF_DATA_DIR}/plugins"

# asdf-java
if [ -f "${ASDF_PLUGINS_DIR}/java/set-java-home.zsh" ]; then
	source "${ASDF_PLUGINS_DIR}/java/set-java-home.zsh"
fi

# asdf-golang
export ASDF_GOLANG_DEFAULT_PACKAGES_FILE="${ASDF_DATA_DIR}/go-packages"

if [ -f "${ASDF_PLUGINS_DIR}/golang/set-env.zsh" ]; then
	source "${ASDF_PLUGINS_DIR}/golang/set-env.zsh"
fi

# asdf-nodejs
export ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY=latest_available
export ASDF_NPM_DEFAULT_PACKAGES_FILE="${ASDF_DATA_DIR}/npm-packages"

unset ASDF_PLUGINS_DIR
