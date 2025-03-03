local g = vim.g
local o = vim.opt

-- Define leader key
g.mapleader = " "
g.maplocalleader = "\\"

-- Autoformat on save (Global)
g.autoformat = true

-- Enable EditorConfig integration
g.editorconfig = true

-- Root dir detection
g.root_spec = {
  "lsp",
  { ".git", "lua", ".obsidian", "package.json", "Makefile", "go.mod", "cargo.toml", "pyproject.toml", "src" },
  "cwd",
}

-- Disable annoying cmd line stuff
o.showcmd = false
o.laststatus = 3
o.cmdheight = 0

-- Backspacing and indentation when wrapping
o.backspace = { "start", "eol", "indent" }
o.breakindent = true

-- Smoothscroll
if vim.fn.has("nvim-0.10") == 1 then
  o.smoothscroll = true
end

o.conceallevel = 2

o.mousefocus = true
o.mousemoveevent = true
o.mousescroll = { 'ver:1', 'hor:6' }
