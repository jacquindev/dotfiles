return {
  {
    "akinsho/toggleterm.nvim",
    event = "VeryLazy",
    opts = {
      open_mapping = [[<c-\>]],
      shade_filetypes = {},
      direction = 'horizontal',
      autochdir = true,
      persist_mode = true,
      insert_mappings = false,
      start_in_insert = true,
      size = function(term)
        if term.direction == 'horizontal' then
          return 15
        elseif term.direction == 'vertical' then
          return math.floor(vim.o.columns * 0.4)
        end
      end,
      config = function(_, opts)
        require("toggleterm").setup(opts)

        local Terminal = require("toggleterm.terminal").Terminal

        local lazygit = Terminal:new({
          cmd = 'lazygit',
          dir = 'git_dir',
          hidden = true,
          direction = 'float',
        })

        local lazydocker = Terminal:new({
          cmd = 'lazydocker',
          dir = 'git_dir',
          hidden = true,
          direction = 'float',
        })

        local gh_dash = Terminal:new({
          cmd = 'gh dash',
          hidden = true,
          direction = 'float',
          float_opts = {
            height = function() return math.floor(vim.o.lines * 0.8) end,
            width = function() return math.floor(vim.o.columns * 0.95) end,
          },
        })

        map("n", "<localleader>tl", function() lazygit:toggle() end, { desc = "ToggleTerm: Toggle LazyGit" })
        map("n", "<localleader>td", function() lazydocker:toggle() end, { desc = "ToggleTerm: Toggle LazyDocker" })
        map("n", "<localleader>th", function() gh_dash:toggle() end, { desc = "ToggleTerm: Toggle GitHub Dashboard" })
      end,
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<localleader>t", group = "terminal" }
      },
    },
  },
}
