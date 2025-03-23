local g = vim.g
local o = vim.opt

-- Define leader key
g.mapleader = " "
g.maplocalleader = "\\"

-- Autoformat on save (Global)
g.autoformat = true

-- Enable EditorConfig integration
g.editorconfig = true

-- Disable builtin providers
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0

-- Python settings
g.lazyvim_python_lsp = "basedpyright"
g.lazyvim_python_ruff = "ruff"

-- Disable annoying cmd line stuff
o.showcmd = false
o.laststatus = 3
o.cmdheight = 0

-- Backspacing and indentation when wrapping
o.backspace = { "start", "eol", "indent" }
o.breakindent = true

-- Backup
o.backup = false
o.backupdir = vim.fn.stdpath("state") .. "/backup"

-- Smoothscroll
if vim.fn.has("nvim-0.10") == 1 then
  o.smoothscroll = true
end

o.conceallevel = 2

o.mousefocus = true
o.mousemoveevent = true
o.mousescroll = { "ver:1", "hor:6" }
