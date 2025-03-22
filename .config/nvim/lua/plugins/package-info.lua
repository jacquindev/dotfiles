local prefix = "<leader>pn"

return {
  {
    "vuki656/package-info.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
    event = {
      "BufRead package.json",
      "BufRead package-lock.json",
    },
    opts = {},
    -- stylua: ignore
    keys = {
			{ prefix .. "h", function() require('package-info').hide() end, desc = "Hide Dependency Versions" },
			{ prefix .. "t", function() require('package-info').toggle() end, desc = "Toggle Dependency Versions" },
      { prefix .. "c", function() require('package-info').change_version() end, desc = "Change Package Version" },
      { prefix .. "i", function() require('package-info').install() end, desc = "Install New Dependency" },
      { prefix .. "r", function() require('package-info').delete() end, desc = "Remove Package" },
      { prefix .. "u", function() require('package-info').update() end, desc = "Update Package" },
      { prefix .. "v", function() require('package-info').show({ force = true }) end, desc = "Show Package Versions" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { prefix, group = "npm/yarn/pnpm", icon = "󰖟 ", mode = { "n", "v" } },
      },
    },
  },
}
