return {
  {
    "folke/snacks.nvim",
    opts = {
      notifier = { enabled = true },
      image = { enabled = false },
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
            excluded = { "node_modules/", ".git/" },
          },
        },
      },
    },
  },
}
