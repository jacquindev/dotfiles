#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

npm_packages_file="$SCRIPT_DIR/npm-packages"
if command -v npm >/dev/null 2>&1; then
	while IFS= read -r line; do
		printf "Installing NPM package %s...\n" "$line"
		npm install -g "$line"
	done < "$npm_packages_file"
fi
unset npm_packages_file

golang_packages_file="$SCRIPT_DIR/go-packages"
if command -v go >/dev/null 2>&1; then
	while IFS= read -r line; do
		printf "Installing GO package %s...\n" "$line"
		go install "$line"
	done < "$golang_packages_file"
fi
unset golang_packages_file

composer_packages_file="$SCRIPT_DIR/composer-packages"
if command -v composer >/dev/null 2>&1; then
	while IFS= read -r line; do
		printf "Installing COMPOSER (PHP) package %s...\n" "$line"
		composer global require "$line"
	done < "$composer_packages_file"
fi
unset composer_packages_file
