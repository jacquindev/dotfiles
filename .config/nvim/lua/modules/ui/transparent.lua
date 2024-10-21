return {
  "xiyaowong/transparent.nvim",
  cmd = {
    "TransparentEnable",
    "TransparentDisable",
    "TransparentToggle",
  },
  keys = {
    { "<leader>ux", "<cmd>TransparentToggle<cr>", desc = "Toggle Transparent" },
  },
  opts = {
    extra_groups = { "NormalFloat" },
  },
}
