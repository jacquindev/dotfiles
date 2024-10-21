_G.map = vim.keymap.set
_G.border = require("utils.icons").border.rounded or "rounded"

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.cmd [[colorscheme tokyonight]]
