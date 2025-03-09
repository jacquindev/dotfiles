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

# fzf
if type -q fzf
    fzf --fish | source
end

# zoxide
if type -q zoxide
    zoxide init fish --cmd cd | source
end
