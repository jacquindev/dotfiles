if status is-interactive
    # Commands to run in interactive sessions can go here
	
	# Install oh-my-fish
	if not type -q omf
		curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
	end

	# Install fisher
	if not type -q fisher
		curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
	end

	# Install bass
	if not type -q bass
		omf install bass
	end

	# Environment variables & PATHs
	if test -e $HOME/dotfiles
		set DOTFILES $HOME/dotfiles
	else if test -e $HOME/.dotfiles
		set DOTFILES $HOME/.dotfiles
	end

	set -l env_file $DOTFILES/shared/.env
	set -l path_file $DOTFILES/shared/path.sh

	if test -e $env_file
		and type -q bass
  		egrep -v '^#|^$' $env_file | while read -l env_setting
			echo $env_setting | read -d = -l env_name env_value
			if not set -q $env_name
				or test "$env_name" != "$env_value"
				bass export $env_setting
			end
  		end
	end

	if test -e $path_file
		and type -q bass
		bass source $path_file
	end

	# Development tool plugins
	# nvm
	if test -e $NVM_DIR/nvm.sh
		and not fisher list | grep -q 'FabioAntunes/fish-nvm'
		fisher install FabioAntunes/fish-nvm
	end

	# sdkman
	if test -e $SDKMAN_DIR
		and not fisher list | grep -q 'reitzig/sdkman-for-fish'
		fisher install reitzig/sdkman-for-fish
	end
end

# Suppress fish's intro message
set fish_greeting

# Homebrew completions
if test -d (brew --prefix)"/share/fish/completions"
	set -p fish_complete_path (brew --prefix)"/share/fish/completions"
end

if test -d (brew --prefix)"/share/fish/vendor_completions.d"
	set -p fish_complete_path (brew --prefix)"/share/fish/vendor_completions.d"
end

# Custom prompt
if type -q oh-my-posh
	oh-my-posh init fish --config (brew --prefix oh-my-posh)"/themes/tokyonight_storm.omp.json" | source
else if type -q starship
	starship init fish | source
end

# forgit
if test -e (brew --prefix)"/share/forgit/forgit.plugin.fish"
	source (brew --prefix)"/share/forgit/forgit.plugin.fish"
end

# atuin
if type -q atuin
	atuin init fish | source
end

# rye
if test -e $RYE_HOME/env
	and type -q bass
	bass source $RYE_HOME/env
end

# zoxide
if type -q zoxide
	zoxide init fish | source
end
