return {
  {
    "akinsho/toggleterm.nvim",
    cmd = {
      "ToggleTerm",
      "ToggleTermSetName",
      "ToggleTermToggleAll",
      "ToggleTermSendVisualLines",
      "ToggleTermSendCurrentLine",
      "ToggleTermSendVisualSelection",
    },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 30
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<c-\>]],
      hide_numbers = true,      -- hide the number column in toggleterm buffers
      shade_filetypes = {},
      shade_terminals = true,   -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
      shading_factor = "-10",   -- the percentage by which to lighten terminal background, default: -30 (gets multiplied by -3 if background is light)
      start_in_insert = true,
      insert_mappings = true,   -- whether or not the open mapping applies in insert mode
      terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
      persist_size = true,
      persist_mode = true,      -- if set to true (default) the previous terminal mode will be remembered
      direction = "float",
      close_on_exit = true,     -- close the terminal window when the process exits
      -- Change the default shell. Can be a string or a function returning a string
      shell = vim.o.shell,
      -- This field is only relevant if direction is set to 'float'
      float_opts = {
        -- The border key is *almost* the same as 'nvim_open_win'
        -- see :h nvim_open_win for details on borders however
        -- the 'curved' border is a custom border type
        -- not natively supported but implemented in this plugin.
        border = "curved",
        -- like `size`, width and height can be a number or function which is passed the current terminal
        highlights = { border = "Normal", background = "Normal" },
        winblend = 3,
      },
    },
    -- stylua: ignore
    keys = {
      { [[<c-\>]], "<cmd>ToggleTerm<cr>", mode = "n", desc = "Toggle Terminal" },
    },
  },
  {
    "ryanmsnyder/toggleterm-manager.nvim",
    opts = {},
    keys = {
      { "<c-/>", "<cmd>Telescope toggleterm_manager<cr>", desc = "Terminals" },
    },
  },
  {
    "voldikss/vim-floaterm",
    cmd = { "FloatermNew", "FloatermToggle", "FloatermNext", "FloatermPrev", "FloatermLast", "FloatermFirst" },
    --stylua: ignore
    keys = {
      { "<A-e>",       "<cmd>FloatermNew --disposable --name=yaziroot --opener=edit --titleposition=center --height=0.85 --width=0.85 --cwd=<root> yazi<CR>", desc = "Yazi" },
      { "<leader>gg",  "<cmd>FloatermNew --name=lazygitroot --opener=edit --titleposition=center --height=0.85 --width=0.85 --cwd=<root> lazygit<CR>",        desc = "Lazygit (root dir)" },
      { "<leader>gG",  "<cmd>FloatermNew --name=lazygitbuffer --opener=edit --titleposition=center --height=0.85 --width=0.85 --cwd=<buffer> lazygit<CR>",    desc = "Lazygit (cwd)" },
      { "<leader>cen", "<cmd>FloatermNew --name=node --opener=edit --titleposition=center --wintype=split --height=0.35 node<CR>",                            desc = "Node" },
      { "<leader>cep", "<cmd>FloatermNew --name=python --opener=edit --titleposition=center --wintype=split --height=0.35 python<CR>",                        desc = "Python" },
      { "<S-Right>",   "<Esc><Esc><cmd>FloatermNext<CR>",                                                                                                     mode = { "t" },              desc = "Next Terminal" },
      { "<S-Left>",    "<Esc><Esc><cmd>FloatermPrev<CR>",                                                                                                     mode = { "t" },              desc = "Prev Terminal" },
      { "<A-Right>",   "<Esc><Esc><cmd>FloatermLast<CR>",                                                                                                     mode = { "t" },              desc = "Last Terminal" },
      { "<A-Left>",    "<Esc><Esc><cmd>FloatermFirst<CR>",                                                                                                    mode = { "t" },              desc = "First Terminal" },
      { [[<c-\>]],     "<cmd>FloatermToggle<cr>",                                                                                                             mode = { "n", "t" },         desc = "Toggle Terminal" },
      { "<leader>ftf", "<cmd>FloatermNew --name=floatroot --opener=edit --titleposition=center --height=0.85 --width=0.85 --cwd=<root><cr>",                  desc = "Floating (root dir)" },
      { "<leader>ftF", "<cmd>FloatermNew --name=floatbuffer --opener=edit --titleposition=center --height=0.85 --width=0.85 --cwd=<buffer><cr>",              desc = "Floating (cwd)" },
      { "<leader>fts", "<cmd>FloatermNew --name=splitroot --opener=edit --titleposition=center --height=0.35 --wintype=split --cwd=<root><cr>",               desc = "Split (root dir)" },
      { "<leader>ftS", "<cmd>FloatermNew --name=splitbuffer --opener=edit --titleposition=center --height=0.35 --wintype=split --cwd=<buffer><cr>",           desc = "Split (cwd)" },
    },
  },
  {
    "dawsers/telescope-floaterm.nvim",
    config = function()
      LazyVim.on_load("telescope.nvim", function()
        require("telescope").load_extension("floaterm")
      end)
    end,
    keys = {
      { [[<A-\>]], "<cmd>Telescope floaterm<cr>", desc = "Terminals" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>ce", group = "r[e]pl", icon = "󰫧 " },
        { "<leader>ft", group = "terminals", icon = " " },
      },
    },
  },
}
