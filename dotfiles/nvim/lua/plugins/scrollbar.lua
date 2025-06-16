local M = {
  'petertriho/nvim-scrollbar',
  dependencies = {
    'f-person/auto-dark-mode.nvim',
    'kevinhwang91/nvim-hlslens',
  },
  opts = {
    handlers = {
      search = true, -- hlslens
    },
  },
  lazy = false,
  priority = 1002,
}

return M
