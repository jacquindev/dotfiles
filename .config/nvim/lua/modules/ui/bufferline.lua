return {
  {
    "akinsho/bufferline.nvim",
    event = "UIEnter",
    config = function()
      local bufferline = require("bufferline")

      bufferline.setup({
        options = {
          style_preset = { bufferline.style_preset.minimal },
          mode = "buffers",
          sort_by = 'insert_after_current',
          move_wraps_at_ends = true,
          show_close_icon = false,
          show_buffer_close_icons = true,
          indicator = { style = 'underline' },
          diagnostics = false,
          hover = { enabled = true, reveal = { 'close' } },
          offsets = {
            {
              text = 'EXPLORER',
              filetype = 'neo-tree',
              highlight = 'PanelHeading',
              text_align = 'left',
              separator = true,
            },
            {
              text = ' DIFF VIEW',
              filetype = 'DiffviewFiles',
              highlight = 'PanelHeading',
              separator = true,
            },
          },
          groups = {
            options = { toggle_hidden_on_enter = true },
            items = {
              bufferline.groups.builtin.pinned:with({ icon = '' }),
              bufferline.groups.builtin.ungrouped,
              {
                name = 'Dependencies',
                icon = '',
                highlight = { fg = '#ECBE7B' },
                matcher = function(buf) return vim.startswith(buf.path, vim.env.VIMRUNTIME) end,
              },
              {
                name = 'Kubernetes',
                matcher = function(buf) return buf.name:match('kubernetes') and buf.name:match('%.yaml') end,
              },
              {
                name = 'SQL',
                matcher = function(buf) return buf.name:match('%.sql$') end,
              },
              {
                name = 'tests',
                icon = '',
                matcher = function(buf)
                  local name = buf.name
                  return name:match('[_%.]spec') or name:match('[_%.]test')
                end,
              },
              {
                name = 'docs',
                icon = '',
                matcher = function(buf)
                  if vim.bo[buf.id].filetype == 'man' or buf.path:match('man://') then return true end
                  for _, ext in ipairs({ 'md', 'txt', 'org', 'norg', 'wiki' }) do
                    if ext == vim.fn.fnamemodify(buf.path, ':e') then return true end
                  end
                end,
              },
            },
          },
        },
      })
    end,
  },
}
