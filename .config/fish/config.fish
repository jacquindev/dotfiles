set fish_greeting

# Homebrew fish integration
if test -f /home/linuxbrew/.linuxbrew/bin/brew
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end

# Homebrew completion
if type -q brew
    if test -d (brew --prefix)"/share/fish/completions"
        set -p fish_complete_path (brew --prefix)/share/fish/completions
    end

    if test -d (brew --prefix)"/share/fish/vendor_completions.d"
        set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
    end
end

# Shared PATH for fish, zsh and bash
if type -q bass
    and test -f $HOME/.config/path_add.sh
    bass ". $HOME/.config/path_add.sh"
end

# wsl machine
if type -q wslvar
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
        set -gx VAGRANT_WSL_WINDOWS_ACCESS_USER_HOME_PATH /mnt/c/vagrant_home/
    end

    set --erase windows_user_home windows_program_files
end

# kubectl aliases
# - https://github.com/ahmetb/kubectl-aliases
test -f ~/.config/fish/.kubectl_aliases.fish && source ~/.config/fish/.kubectl_aliases.fish

# starship
if type -q starship
    starship init fish | source
end

# vfox
if type -q vfox
    vfox activate fish | source
end

# mise
if type -q mise
    if test -f ~/.local/bin/mise
        ~/.local/bin/mise activate fish | source
    else
        mise activate fish | source
    end
end

# fzf
if type -q fzf
    fzf --fish | source
end

# zoxide
if type -q zoxide
    zoxide init fish --cmd cd | source
end
