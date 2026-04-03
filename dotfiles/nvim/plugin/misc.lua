vim.cmd.packadd 'nvim.undotree'
vim.cmd.packadd 'nvim.difftool'

vim.pack.add {
  { src = 'https://github.com/tpope/vim-abolish' },
  { src = 'https://github.com/tpope/vim-fugitive' },
  { src = 'https://github.com/tpope/vim-rhubarb' },
  { src = 'https://github.com/tpope/vim-sleuth' },
  { src = 'https://github.com/kburdett/vim-nuuid' },
  { src = 'https://github.com/folke/which-key.nvim' },
  { src = 'https://github.com/LunarVim/bigfile.nvim' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
}

require('which-key').setup()
require('bigfile').setup()
require('gitsigns').setup()

vim.keymap.set('n', '<leader><F5>', vim.cmd.UndotreeToggle)
