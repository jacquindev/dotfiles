local package_prefix = "<leader>pp"

return {
  {
    "MeanderingProgrammer/py-requirements.nvim",
    event = {
      "BufRead requirements.txt",
    },
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      {
        "hrsh7th/nvim-cmp",
        dependencies = {},
        opts = function(_, opts)
          table.insert(opts.sources, { name = "py-requirements" })
        end,
      },
    },
    opts = {},
    -- stylua: ignore
    keys = {
      { package_prefix .. "u", function() require("py-requirements").upgrade() end, desc = "Update Package" },
      { package_prefix .. "i", function() require("py-requirements").show_description() end, desc = "Package Info" },
      { package_prefix .. "a", function() require("py-requirements").upgrade_all() end, desc = "Update All Packages" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { package_prefix, group = "python", icon = " " },
      },
    },
  },
}
