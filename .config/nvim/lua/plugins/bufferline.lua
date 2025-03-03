local keys = {}

-- stylua: ignore start
for i = 1, 9 do
  table.insert(keys, { "<leader>b" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>", desc = "Buffer " .. i })
end

table.insert(keys, { "<leader>.", "<Cmd>BufferLinePick<CR>", desc = "Pick Buffer" })

table.insert(keys, { "<leader>bS", "<Cmd>BufferLineSortByDirectory<CR>", desc = "Sort By Directory" })
table.insert(keys, { "<leader>bs", "<Cmd>BufferLineSortByExtension<CR>", desc = "Sort By Extensions" })

table.insert(keys, { "<space><", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" })
table.insert(keys, { "<space>>", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" })
-- stylua: ignore end

return {
  "akinsho/bufferline.nvim",
  keys = keys,
  event = "UIEnter",
  opts = {
    options = {
      move_wraps_at_end = true,
      show_close_icon = false,
      show_buffer_close_icon = true,
      diagnostics = false,
      indicator = { style = "underline" },
      modified_icon = "",
      color_icons = true,
      style_preset = { require("bufferline").style_preset.minimal },
      hover = { enabled = true, reveal = { 'close' } },
      offsets = {
        {
          text = '  EXPLORER',
          filetype = 'neo-tree',
          highlight = 'PanelHeading',
          text_align = 'left',
          separator = true,
        },
        {
          text = '󰆼 DATABASE VIEWER',
          filetype = 'dbui',
          highlight = 'PanelHeading',
          text_align = 'left',
          separator = true,
        },
        {
          text = ' DIFF VIEW',
          filetype = 'DiffviewFiles',
          highlight = 'PanelHeading',
          text_align = 'left',
          separator = true,
        },
      },
      groups = {
        options = { toggle_hidden_on_enter = true },
        items = {
          require("bufferline").groups.builtin.pinned:with({ icon = '' }),
          require("bufferline").groups.builtin.ungrouped,
          {
            name = 'SQL',
            matcher = function(buf) return buf.name:match('%.sql$') end,
          },
          {
            name = 'KUBE',
            matcher = function(buf) return buf.name:match('kubernetes') and buf.name:match('%.yaml') end,
          },
          {
            name = 'TEST',
            highlight = { fg = "#eed49f" },
            matcher = function(buf)
              local name = buf.name
              return name:match('[_%.]spec') or name:match('[_%.]test')
            end,
          },
          {
            name = 'DEPS',
            highlight = { fg = "#f5a97f" },
            matcher = function(buf) return vim.startswith(buf.path, vim.env.VIMRUNTIME) end,
          },
          {
            name = 'DOCS',
            matcher = function(buf)
              if vim.bo[buf.id].filetype == 'man' or buf.path:match('man://') then return true end
              for _, ext in ipairs({ 'md', 'txt', 'org', 'norg', 'wiki' }) do
                if ext == vim.fn.fnamemodify(buf.path, ':e') then return true end
              end
            end,
          },
        }
      }
    }
  },
  config = function(_, opts)
    require("bufferline").setup(opts)
    vim.g.transparent_groups = vim.list_extend(
      vim.g.transparent_groups or {},
      vim.tbl_map(function(v)
        return v.hl_group
      end, vim.tbl_values(require('bufferline.config').highlights))
    )
  end,
}
