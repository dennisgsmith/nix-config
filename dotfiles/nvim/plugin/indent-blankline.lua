vim.pack.add {
  { src = 'https://github.com/lukas-reineke/indent-blankline.nvim' },
}

require('ibl').setup {
  indent = {
    char = '▏',
  },
  scope = {
    show_start = false,
    show_end = false,
  },
}
