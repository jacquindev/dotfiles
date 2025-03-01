#!/bin/sh

# Function to add to path
# References: - https://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there

is_wsl() {
  case "$(uname -r)" in
  *microsoft*) true ;; # WSL 2
  *Microsoft*) true ;; # WSL 1
  *) false ;;
  esac
}

pathappend() {
	if ! echo "$PATH" | /bin/grep -Eq "(^|:)$1($|:)" && [ -d "$1" ]; then
		export PATH="$PATH:$1"
	fi
}

pathprepend() {
	if ! echo "$PATH" | /bin/grep -Eq "(^|:)$1($|:)" && [ -d "$1" ]; then
		export PATH="$1:$PATH"
	fi
}

# Main bin
pathprepend "$HOME/bin"
pathprepend "$HOME/.local/bin"
pathprepend "/usr/local/sbin"
pathprepend "/usr/bin"

# WSL PATHS
# if is_wsl; then
#   if [[ $(source <(grep -v '^\[\|^#' /etc/wsl.conf) && echo "$appendWindowsPath") == "false" ]]; then
#     # If you're using WSL and you have set /etc/wsl.conf [interop] as
#     # appendWindowsPath=false, then you can add the path of the program you want
#     # to use on Windows inside your WSL terminal here:
#     pathprepend "$(wslpath "$(wslvar USERPROFILE)")/AppData/Local/Programs/Microsoft VS Code/bin"
#   fi
# fi
