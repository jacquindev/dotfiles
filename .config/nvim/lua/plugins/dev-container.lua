local prefix = "<leader>C"

return {
  {
    "https://codeberg.org/esensar/nvim-dev-container",
    cmd = {
      "DevcontainerStart",
      "DevcontainerStop",
      "DevcontainerLogs",
      "DevcontainerEditNearestConfig",
      "DevcontainerAttach",
      "DevcontainerExec",
      "DevcontainerStopAll",
      "DevcontainerRemoveAll",
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
    keys = {
      { prefix .. "s", "<cmd>DevcontainerStart<cr>",             desc = "Start [devcontainer]" },
      { prefix .. "S", "<cmd>DevcontainerStop<cr>",              desc = "Stop [devcontainer]" },
      { prefix .. "l", "<cmd>DevcontainerLogs<cr>",              desc = "Log [devcontainer]" },
      { prefix .. "c", "<cmd>DevcontainerEditNearestConfig<cr>", desc = "Config [devcontainer]" },
      { prefix .. "a", "<cmd>DevcontainerAttach<cr>",            desc = "Attach [devcontainer]" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>C", group = "containers", icon = { icon = " ", color = "yellow" } },
      },
    },
  },
}
