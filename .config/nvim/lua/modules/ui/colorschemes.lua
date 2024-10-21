return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		opts = {
			transparent = vim.g.transparent,
			styles = {
				sidebars = vim.g.transparent,
				floats = vim.g.transparent,
			},
		},
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		opts = {
			flavour = "mocha",
			transparent_background = vim.g.transparent,
			term_colors = true,
			integrations = {
				cmp = true,
				dadbod_ui = true,
				dashboard = true,
				dap = true,
				dap_ui = true,
				diffview = true,
				dropbar = { enabled = true, color_mode = true },
				fidget = true,
				fzf = true,
				gitsigns = true,
				grug_far = true,
				harpoon = true,
				indent_blankline = { enabled = true, colored_indent_levels = true },
				octo = true,
				overseer = true,
				markdown = true,
				mason = true,
				mini = { enabled = true, indentscope_color = "" },
				neotree = true,
				neogit = true,
				neotest = true,
				native_lsp = {
					enabled = true,
					underlines = {
						errors = { "undercurl" },
						hints = { "undercurl" },
						warnings = { "undercurl" },
						information = { "undercurl" },
					},
				},
				noice = true,
				notify = true,
				nvimtree = true,
				nvim_surround = true,
				semantic_tokens = true,
				telescope = { enabled = true },
				treesitter = true,
				treesitter_context = true,
				rainbow_delimiters = true,
				window_picker = true,
				which_key = true,
			},
		},
	},
	{
		"projekt0n/github-nvim-theme",
		name = "github-theme",
		lazy = false,
		opts = {
			options = {
				transparent = vim.g.transparent,
				styles = {
					comments = "italic",
					variables = "italic"
				},
			},
		},
	},
	{
		"oxfist/night-owl.nvim",
		lazy = false,
		opts = {
			transparent_background = vim.g.transparent
		},
	},
}
