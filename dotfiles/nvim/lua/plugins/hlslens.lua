local M = {
  'kevinhwang91/nvim-hlslens',
  keys = {
    {
      'n',
      [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
      silent = true,
      remap = false,
    },
    {
      'N',
      [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
      silent = true,
      remap = false,
    },
    {
      '*',
      [[*<Cmd>lua require('hlslens').start()<CR>]],
      silent = true,
      remap = false,
    },
    {
      '#',
      [[#<Cmd>lua require('hlslens').start()<CR>]],
      silent = true,
      remap = false,
    },
    {
      'g*',
      [[g*<Cmd>lua require('hlslens').start()<CR>]],
      silent = true,
      remap = false,
    },
    {
      'g#',
      [[g#<Cmd>lua require('hlslens').start()<CR>]],
      silent = true,
      remap = false,
    },
    {
      '<leader>l',
      '<cmd>noh<cr>',
      silent = true,
      remap = false,
    },
  },
  config = function()
    require('scrollbar.handlers.search').setup()
  end,
}

return M
