return {
  {
    'mason-org/mason.nvim',
    build = ':MasonUpdate',
    config = true,
    opts = {
      ui = {
        border = 'rounded',
      },
    },
  },
  {
    'zapling/mason-lock.nvim',
    init = function()
      require('mason-lock').setup {
        lockfile_path = vim.fn.stdpath 'config' .. '/mason-lock.json',
      }
    end,
  },
}
