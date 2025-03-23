local icons = {
  ui = require("utils.icons").get("ui", true),
  misc = require("utils.icons").get("misc", true),
}

return {
  "williamboman/mason.nvim",
  dependencies = {
    "zapling/mason-lock.nvim",
    cmd = { "MasonLock", "MasonLockRestore" },
    opts = {},
  },
  keys = {
    { "<leader>cm", false },
    { "<leader>im", "<cmd>Mason<cr>", desc = "Mason" },
  },
  opts = {
    max_concurrent_installers = 10,
    ui = {
      border = "rounded",
      icons = {
        package_pending = icons.ui.Modified_alt,
        package_installed = icons.ui.Check,
        package_uninstalled = icons.misc.Ghost,
      },
    },
    ensure_installed = {
      "bash-language-server",
      "css-lsp",
      "css-variables-language-server",
      "cssmodules-language-server",
      "emmet-language-server",
      "golangci-lint",
      "html-lsp",
      "htmlhint",
      "htmx-lsp",
      "shellcheck",
      "stylelint",
      "graphql-language-service-cli",
      "lemminx",
      "jinja-lsp",
      "groovy-language-server",
    },
  },
}
