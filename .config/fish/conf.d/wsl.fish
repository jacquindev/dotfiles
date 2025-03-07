if type -q wslvar
	set -gx --prepend PATH /mnt/c/WINDOWS/System32

	set windows_user_home (wslpath (wslvar USERPROFILE))
	# VS Code
	if not type -q code
		if test -d "$windows_user_home/AppData/Local/Programs/Microsoft VS Code/bin"
			set -gx --prepend PATH "$windows_user_home/AppData/Local/Programs/Microsoft VS Code/bin"
		end
	end

	# virtualbox
	set windows_program_files (wslpath (wslvar ProgramW6432))
	if test -d "$windows_program_files/Oracle/VirtualBox"
		set -gx --prepend PATH "$windows_program_files/Oracle/VirtualBox"
	end

	# vagrant
	if type -q vagrant
		set -gx VAGRANT_WSL_ENABLE_WINDOWS_ACCESS 1
		set -gx VAGRANT_WSL_WINDOWS_ACCESS_USER_HOME_PATH $windows_user_home
	end

	set --erase windows_user_home windows_program_files
end
