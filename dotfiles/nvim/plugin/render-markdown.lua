vim.pack.add {
  { src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/echasnovski/mini.icons' },
}

require('render-markdown').setup {
  heading = {
    enabled = false,
  },
}
