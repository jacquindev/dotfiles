set -l brew_paths /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew $HOME/.linuxbrew/bin/brew

for brew_path in $brew_paths
	if test -f $brew_path
		$brew_path shellenv | source
	end
end

set -e brew_paths
