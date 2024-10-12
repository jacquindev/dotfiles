# Profile
if [ -f "$HOME/.profile" ]; then
    source "$HOME/.profile"
fi

# Zshrc
if [ -f "$HOME/.config/zsh/.zshrc" ]; then
    source "$HOME/.config/zsh/.zshrc"
fi