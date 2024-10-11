-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Improve startup time as preferred in: https://github.com/LazyVim/LazyVim/discussions/4112
vim.opt.clipboard = ""
vim.schedule(function()
  vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
end)

-- Vim runtime
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- powershell (windows)
if vim.fn.has("win32") == 1 then
  LazyVim.terminal.setup("pwsh")
end

vim.opt.undofile = true

-- Toggle invisible characters 
vim.opt.list = true
vim.opt.listchars = {
  tab = "  ",
  trail = "⋅",
  extends = "❯",
  precedes = "❮",
}
vim.opt.fcs = "eob: "

vim.opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

-- Grep use ripgrep
if vim.fn.executable("rg") then
  vim.opt.grepprg = "rg --vimgrep --no-heading"
  -- opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
  vim.opt.grepformat = "%f:%l:%c:%m"
  -- create autocmd to automatically open quickfix window when grepping
  vim.cmd([[autocmd QuickFixCmdPost [^l]* nested cwindow]])
else
  vim.opt.grepformat = "%f:%l:%c:%m"
end