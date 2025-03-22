return {
	{
		"mfussenegger/nvim-lint",
		opts = function(_, opts)
			local function add_linters(tbl)
				for ft, linters in pairs(tbl) do
					if opts.linters_by_ft[ft] == nil then
						opts.linters_by_ft[ft] = linters
					else
						vim.list_extend(opts.linters_by_ft[ft], linters)
					end
				end
			end

			add_linters({
				["ansible"] = { "ansible_lint" },
				["go"] = { "golangcilint" },
				["gomod"] = { "golangcilint" },
				["gowork"] = { "gotlangcilint" },
				["bash"] = { "shellcheck" },
				["html"] = { "htmlhint" },
        ["css"] = { "stylelint" },
        ["scss"] = { "stylelint" },
        ["less"] = { "stylelint" },
        ["sugarss"] = { "stylelint" },
			})
		end
	}
}
