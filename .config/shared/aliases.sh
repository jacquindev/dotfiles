#!/usr/bin/env bash

alias lg=lazygit
alias ld=lazydocker

# package managers
alias npm-ls="npm list -g"
alias pnpm-ls="pnpm list -g"
alias bun-ls="bun pm ls -g"
alias gems="gem list"
alias go-ls="go-global-update --dry-run"

# eza
if command -v eza >/dev/null 2>&1; then
	alias ls="eza --icons --color --header --hyperlink --group --git --group-directories-first"
	alias la="ls -al --sort=modified"
	alias lD="ls -lDa --show-symlinks --time-style=relative --grid"
	alias lF="ls -lfa --show-symlinks --time-style=relative --grid"
	alias ll="ls -lbhHigUmuSa --time-style=relative --sort=modified --reverse --grid"
	alias lo="ls --oneline"
	alias tree="ls --tree"
fi
