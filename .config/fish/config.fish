if status is-interactive
    # Commands to run in interactive sessions can go here
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

# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims $HOME/.asdf/shims
else
    set _asdf_shims $ASDF_DATA_DIR/shims
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims

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
