local actions = require("telescope.actions")
local symbols_prefix = "<leader>ss"
local symbols_workspace_prefix = "<leader>sS"

return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<S-esc>"] = actions.close,
            ["<C-p>"] = require("telescope.actions.layout").toggle_preview,
            ["<c-l>"] = require("telescope.actions.layout").cycle_layout_next,
            ["<a-l>"] = require("telescope.actions.layout").cycle_layout_prev,
            ["<C-Down>"] = actions.cycle_history_next,
            ["<C-Up>"] = actions.cycle_history_prev,
            ["<C-Tab>"] = actions.select_tab_drop,
            ["<M-h>"] = actions.results_scrolling_left,
            ["<M-l>"] = actions.results_scrolling_right,
          },
        },
        file_ignore_patterns = {
          ".gitignore",
          "node_modules",
          "build",
          "dist",
          "yarn.lock",
          "*.git/*",
          "*/tmp/*",
        },
        layout_strategy = "flex",
        layout_config = {
          prompt_position = "top",
          horizontal = { preview_width = { 0.55, max = 100, min = 30 } },
          vertical = { preview_cutoff = 20, preview_height = 0.5 },
          cursor = { height = 0.5, width = 0.8 },
        },
        sorting_strategy = "ascending",
        path_display = { filename_first = { reverse_directories = false } },
        dynamic_preview_title = true,
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({}),
        },
      },
    },
    -- stylua: ignore
    keys = {
      {
        symbols_prefix .. "a",
        LazyVim.pick("lsp_document_symbols",
          { symbols = { "Class", "Function", "Method", "Constructor", "Interface", "Module", "Struct", "Trait", "Field", "Property", "Enum", "Constant" } }),
        desc = "All",
      },
      { symbols_prefix .. "c", LazyVim.pick("lsp_document_symbols", { symbols = { "Class" } }),                 desc = "Class" },
      { symbols_prefix .. "f", LazyVim.pick("lsp_document_symbols", { symbols = { "Function" } }),              desc = "Function" },
      { symbols_prefix .. "m", LazyVim.pick("lsp_document_symbols", { symbols = { "Method" } }),                desc = "Method" },
      { symbols_prefix .. "C", LazyVim.pick("lsp_document_symbols", { symbols = { "Constructor" } }),           desc = "Constructor" },
      { symbols_prefix .. "e", LazyVim.pick("lsp_document_symbols", { symbols = { "Enum" } }),                  desc = "Enum" },
      { symbols_prefix .. "i", LazyVim.pick("lsp_document_symbols", { symbols = { "Interface" } }),             desc = "Interface" },
      { symbols_prefix .. "M", LazyVim.pick("lsp_document_symbols", { symbols = { "Module" } }),                desc = "Module" },
      { symbols_prefix .. "s", LazyVim.pick("lsp_document_symbols", { symbols = { "Struct" } }),                desc = "Struct" },
      { symbols_prefix .. "t", LazyVim.pick("lsp_document_symbols", { symbols = { "Trait" } }),                 desc = "Trait" },
      { symbols_prefix .. "F", LazyVim.pick("lsp_document_symbols", { symbols = { "Field" } }),                 desc = "Field" },
      { symbols_prefix .. "p", LazyVim.pick("lsp_document_symbols", { symbols = { "Property" } }),              desc = "Property" },
      { symbols_prefix .. "v", LazyVim.pick("lsp_document_symbols", { symbols = { "Variable", "Parameter" } }), desc = "Variable" },

      {
        symbols_workspace_prefix .. "a",
        LazyVim.pick("lsp_dynamic_workspace_symbols",
          { symbols = { "Class", "Function", "Method", "Constructor", "Interface", "Module", "Struct", "Trait", "Field", "Property", "Enum", "Constant" } }),
        desc = "All",
      },
      { symbols_workspace_prefix .. "c", LazyVim.pick("lsp_dynamic_workspace_symbols", { symbols = { "Class" } }),                 desc = "Class" },
      { symbols_workspace_prefix .. "f", LazyVim.pick("lsp_dynamic_workspace_symbols", { symbols = { "Function" } }),              desc = "Function" },
      { symbols_workspace_prefix .. "m", LazyVim.pick("lsp_dynamic_workspace_symbols", { symbols = { "Method" } }),                desc = "Method" },
      { symbols_workspace_prefix .. "C", LazyVim.pick("lsp_dynamic_workspace_symbols", { symbols = { "Constructor" } }),           desc = "Constructor" },
      { symbols_workspace_prefix .. "e", LazyVim.pick("lsp_dynamic_workspace_symbols", { symbols = { "Enum" } }),                  desc = "Enum" },
      { symbols_workspace_prefix .. "i", LazyVim.pick("lsp_dynamic_workspace_symbols", { symbols = { "Interface" } }),             desc = "Interface" },
      { symbols_workspace_prefix .. "M", LazyVim.pick("lsp_dynamic_workspace_symbols", { symbols = { "Module" } }),                desc = "Module" },
      { symbols_workspace_prefix .. "s", LazyVim.pick("lsp_dynamic_workspace_symbols", { symbols = { "Struct" } }),                desc = "Struct" },
      { symbols_workspace_prefix .. "t", LazyVim.pick("lsp_dynamic_workspace_symbols", { symbols = { "Trait" } }),                 desc = "Trait" },
      { symbols_workspace_prefix .. "F", LazyVim.pick("lsp_dynamic_workspace_symbols", { symbols = { "Field" } }),                 desc = "Field" },
      { symbols_workspace_prefix .. "p", LazyVim.pick("lsp_dynamic_workspace_symbols", { symbols = { "Property" } }),              desc = "Property" },
      { symbols_workspace_prefix .. "v", LazyVim.pick("lsp_dynamic_workspace_symbols", { symbols = { "Variable", "Parameter" } }), desc = "Variable" },

      -- Additional keymaps
      { "<leader>sA",                    LazyVim.pick("treesitter"),                                                               desc = "Treesitter Symbols" },
      { "<leader>sP",                    "<cmd>Telescope builtin<cr>",                                                             desc = "Pickers (Telescope)" },
      { "<leader>fh",                    LazyVim.pick("find_files", { hidden = true }),                                            desc = "Find Files (hidden)" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { symbols_prefix, group = "goto symbols", icon = " " },
        { symbols_workspace_prefix, group = "goto symbols (Workspace)", icon = " " },
      },
    },
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    config = function()
      LazyVim.on_load("telescope.nvim", function()
        require("telescope").setup({
          extensions = {
            file_browser = {
              hijack_netrw = true,
            },
          },
        })
        require("telescope").load_extension("file_browser")
      end)
    end,
    -- stylua: ignore
    keys = {
      { "<leader>'", "<cmd>Telescope file_browser<cr>",                               desc = "Telescope File Browser (root dir)" },
      { '<leader>"', "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", desc = "Telescope File Browser (cwd)" },
    },
  },
  {
    "crispgm/telescope-heading.nvim",
    config = function()
      LazyVim.on_load("telescope.nvim", function()
        require("telescope").setup({
          extensions = {
            heading = {
              treesitter = true,
            },
          },
        })
        require("telescope").load_extension("heading")
      end)
    end,
    keys = {
      { "<leader>s#", "<cmd>Telescope heading<CR>", desc = "Headings" },
    },
  },
  {
    "tsakirist/telescope-lazy.nvim",
    config = function()
      LazyVim.on_load("telescope.nvim", function()
        require("telescope").load_extension("lazy")
      end)
    end,
    keys = {
      { "<leader>sp", "<cmd>Telescope lazy<CR>", desc = "Plugins (Lazy)" },
    },
  },
  {
    "nvim-telescope/telescope-live-grep-args.nvim",
    config = function()
      LazyVim.on_load("telescope.nvim", function()
        require("telescope").load_extension("lazy")
      end)
    end,
    -- stylua: ignore
    keys = {
      { "<leader>sg", function() require("telescope").extensions.live_grep_args.live_grep_args() end, desc = "Grep (root dir)" },
      { "<leader>/",  function() require("telescope").extensions.live_grep_args.live_grep_args() end, desc = "Grep (root dir)" },
    },
  },
  {
    "debugloop/telescope-undo.nvim",
    opts = {},
    config = function()
      LazyVim.on_load("telescope.nvim", function()
        require("telescope").setup({
          extensions = {
            undo = {
              side_by_side = true,
              layout_strategy = "vertical",
              layout_config = {
                preview_height = 0.6,
              },
            },
          },
        })
        require("telescope").load_extension("undo")
      end)
    end,
    keys = {
      { "<leader>su", "<cmd>Telescope undo<cr>", desc = "Undos" },
    },
  },
  {
    "axieax/urlview.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    cmd = { "UrlView" },
    keys = { { "<leader>sU", "<cmd>UrlView<cr>", desc = "Search Urls" } },
    opts = {
      default_picker = "telescope",
    },
  },
  {
    "jvgrootveld/telescope-zoxide",
    config = function()
      LazyVim.on_load("telescope.nvim", function()
        require("telescope").setup({
          extensions = {
            zoxide = {
              mappings = {
                default = {
                  after_action = function(selection)
                    require("telescope.builtin").find_files({ cwd = selection.path })
                  end,
                },
              },
            },
          },
        })
        require("telescope").load_extension("zoxide")
      end)
    end,
    keys = {
      { "<leader>fz", "<cmd>Telescope zoxide list<CR>", desc = "Zoxide" },
    },
  }
}
