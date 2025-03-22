return {
  "folke/which-key.nvim",
  opts = {
    icons = {
      group = " ⦁ ",
      separator = " │ ",
    },
    preset = "modern",
    spec = {
      { "<leader>i", group = "info", icon = { icon = " ", color = "azure" } },
      { "<leader>l", group = "lazy", icon = { icon = "󰒲 ", color = "purple" } },
      { "<leader>p", group = "packages/dependencies", icon = { icon = " ", color = "yellow" } },
    },
  },
}
