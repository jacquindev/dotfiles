local palette = require("catppuccin.palettes").get_palette("macchiato")

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    opts = {
      term_colors = true,
      styles = { comments = { "italic" } },
      background = {
        light = "latte",
        dark = "macchiato"
      },
      custom_highlights = function()
        return {
          WhichKeyDesc = { fg = palette.flamingo },
          WhichKeyGroup = { fg = palette.mauve },
        }
      end,
      integrations = {
        cmp = true,
        colorful_winsep = { enabled = true, color = "mauve" },
        dadbod_ui = true,
        dap = true,
        dap_ui = true,
        dashboard = true,
        diffview = true,
        dropbar = { enabled = true, color_mode = true },
        fzf = true,
        gitsigns = true,
        grug_far = true,
        harpoon = true,
        headlines = true,
        illuminate = { enabled = true, lsp = true },
        indent_blankline = { enabled = true, scope_color = "lavender", colored_indent_levels = true },
        lsp_trouble = true,
        markdown = true,
        mason = true,
        mini = { enabled = true, indentscope_color = "lavender" },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
          inlay_hints = {
            background = true,
          },
        },
        neogit = true,
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        nvim_surround = true,
        nvimtree = true,
        octo = true,
        overseer = true,
        rainbow_delimiters = true,
        semantic_tokens = true,
        telescope = { enabled = true },
        treesitter = true,
        treesitter_context = true,
        which_key = true,
        window_picker = true,
      },
    },
  },
  {
    "akinsho/bufferline.nvim",
    opts = {
      highlights = require("catppuccin.groups.integrations.bufferline").get({
        styles = { "italic", "bold" },
        custom = {
          all = {
            fill = {
              bg = palette.mantle,
            },
            separator_selected = {
              bg = palette.base,
              fg = palette.mantle,
            },
            separator = {
              bg = palette.mantle,
              fg = palette.mantle,
            },
            tab_separator = {
              bg = palette.mantle,
              fg = palette.mantle,
            },
            tab_selected = {
              bg = palette.base,
            },
            tab_separator_selected = {
              bg = palette.base,
              fg = palette.mantle,
            },
          },
        },
      }),
    },
  },
  {
    "rasulomaroff/reactive.nvim",
    opts = {
      load = { "catppuccin-macchiato-cursor", "catppuccin-macchiato-cursorline" },
    },
  },
}
