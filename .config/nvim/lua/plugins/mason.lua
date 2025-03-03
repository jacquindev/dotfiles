local icons = {
  ui = require("utils.icons").get("ui", true),
  misc = require("utils.icons").get("misc", true)
}

return {
  "williamboman/mason.nvim",
  dependencies = {
    "zapling/mason-lock.nvim",
    cmd = { "MasonLock", "MasonLockRestore" },
    opts = {}
  },
  keys = {
    { "<leader>cm", false },
    { "<leader>im", "<cmd>Mason<cr>", desc = "Mason" },
  },
  opts = {
    ui = {
      border = "rounded",
      icons = {
        package_pending = icons.ui.Modified_alt,
        package_installed = icons.ui.Check,
        package_uninstalled = icons.misc.Ghost
      },
    },
  },
}
