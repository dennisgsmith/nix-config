vim.pack.add {
  { src = 'https://github.com/mason-org/mason.nvim' },
  { src = 'https://github.com/zapling/mason-lock.nvim' },
}

require('mason').setup {
  ui = {
    border = 'rounded',
  },
}

require('mason-lock').setup {
  lockfile_path = vim.fn.stdpath 'config' .. '/mason-lock.json',
}
