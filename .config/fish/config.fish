if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Suppress fish's intro message
set fish_greeting

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

# Custom prompt
if type -q oh-my-posh
	oh-my-posh init fish --config (brew --prefix oh-my-posh)"/themes/tokyonight_storm.omp.json" | source
else if type -q starship
	starship init fish | source
end

# Homebrew completions
if test -d (brew --prefix)"/share/fish/completions"
	set -p fish_complete_path (brew --prefix)"/share/fish/completions"
end

if test -d (brew --prefix)"/share/fish/vendor_completions.d"
	set -p fish_complete_path (brew --prefix)"/share/fish/vendor_completions.d"
end

# forgit
if test -e (brew --prefix)"/share/forgit/forgit.plugin.fish"
	source (brew --prefix)"/share/forgit/forgit.plugin.fish"
end

# zoxide
if type -q zoxide
	zoxide init fish | source
end
