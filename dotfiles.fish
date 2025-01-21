#!/usr/bin/env fish

set SCRIPT_DIR (cd (dirname (status --current-filename)); and pwd)

set -Ux DOTFILES $SCRIPT_DIR

# Install oh-my-fish
if not type -q omf
	curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
else
	echo 'oh-my-fish already installed'
end

# Install `fisher` (plugin manager for fish)
if not type -q fisher
	curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
else
	echo 'fisher already installed'
end

# Util plugins
# bass
if not type -q bass
	omf install bass
end
# autopair
if not fisher list | grep -q 'jorgebucaran/autopair.fish'
	fisher install jorgebucaran/autopair.fish
end

# Environment variables & PATHs
set -l env_file $DOTFILES/shared/.env
set -l path_file $DOTFILES/shared/path.sh

if test -e $env_file
  egrep -v '^#|^$' $env_file | while read -l env_setting
		echo $env_setting | read -d = -l env_name env_value
		if not set -q $env_name
			or test "$env_name" != "$env_value"
			bass export $env_setting
		end
  end
end

if test -e $path_file
	bass source $path_file
end

# Development tool plugins
# nvm
if test -e "$NVM_DIR/nvm.sh"
	and not fisher list | grep -q 'FabioAntunes/fish-nvm'
	fisher install FabioAntunes/fish-nvm
end

# sdkman
if test -e $SDKMAN_DIR/bin/sdkman-init.sh
	and not fisher list | grep -q 'reitzig/sdkman-for-fish'
	fisher plugin reitzig/sdkman-for-fish
end
