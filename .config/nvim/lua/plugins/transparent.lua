return {
  {
    "xiyaowong/nvim-transparent",
    cmd = {
      "TransparentToggle",
      "TransparentEnable",
      "TransparentDisable"
    },
    opts = {
      extra_groups = { "NormalFloat" }
    },
    keys = { { "<leader>uy", "<Cmd>TransparentToggle<CR>", desc = "Toggle Transparent" } },
  },
}
