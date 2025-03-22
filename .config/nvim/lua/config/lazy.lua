local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local icons = {
  kind = require("utils.icons").get("kind"),
  documents = require("utils.icons").get("documents"),
  ui = require("utils.icons").get("ui"),
  ui_sep = require("utils.icons").get("ui", true),
  misc = require("utils.icons").get("misc"),
}

require("lazy").setup({
  spec = {
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts = {
        colorscheme = "catppuccin",
        news = { lazyvim = true, neovim = true },
      },
    },
    { import = "plugins" },
  },
  defaults = { lazy = false, version = false },
  install = { colorscheme = { "tokyonight", "catppuccin" } },
  checker = { enabled = true, notify = false },
  ui = {
    border = "rounded",
    size = { width = 0.88, height = 0.8 },
    icons = {
      cmd = icons.misc.Code,
      config = icons.ui.Gear,
      event = icons.kind.Event,
      ft = icons.documents.Files,
      init = icons.misc.ManUp,
      import = icons.documents.Import,
      keys = icons.ui.Keyboard,
      loaded = icons.ui.Check,
      not_loaded = icons.misc.Ghost,
      plugin = icons.ui.Package,
      runtime = icons.misc.Vim,
      source = icons.kind.StaticMethod,
      start = icons.ui.Play,
      list = {
        icons.ui_sep.BigCircle,
        icons.ui_sep.BigUnfilledCircle,
        icons.ui_sep.Square,
        icons.ui_sep.ChevronRight,
      },
    },
    wrap = true,
  },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
