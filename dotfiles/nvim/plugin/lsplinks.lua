vim.pack.add {
  { src = 'https://github.com/icholy/lsplinks.nvim' },
}

local lsplinks = require 'lsplinks'
lsplinks.setup()
vim.keymap.set('n', 'gx', lsplinks.gx)
