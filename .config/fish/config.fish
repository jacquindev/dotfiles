set fish_greeting

# Homebrew completion
if type -q brew
    if test -d (brew --prefix)"/share/fish/completions"
        set -p fish_complete_path (brew --prefix)/share/fish/completions
    end

    if test -d (brew --prefix)"/share/fish/vendor_completions.d"
        set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
    end
end

# starship
if type -q starship
    starship init fish | source
end

# FZF
if type -q fzf
    fzf --fish | source
end

# Zoxide
if type -q zoxide
    zoxide init fish --cmd cd | source
end
