return {
	{
		"Bekaboo/dropbar.nvim",
		dependencies = {
			"nvim-telescope/telescope-fzf-native.nvim"
		},
		event = "VeryLazy",
		opts = {
			menu = {
				win_configs = {
					border = border,
					col = function(menu)
						return menu.prev_menu and menu.prev_menu._win_configs.width + 1 or 0
					end,
				},
			},
			general = {
				update_interval = 100,
			},
		},
	}
}
