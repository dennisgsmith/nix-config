local M = {
  'ray-x/go.nvim',
  dependencies = {
    'ray-x/guihua.lua',
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
  },
  opts = {
    lsp_cfg = false,
    lsp_inlay_hints = {
      enable = false,
    },
    lsp_codelens = false,
  },
  config = function(_, opts)
    require('go').setup(opts)

    local format_sync_grp = vim.api.nvim_create_augroup('GoImport', {})
    vim.api.nvim_create_autocmd('BufWritePre', {
      pattern = '*.go',
      callback = function()
        require('go.format').goimport()
      end,
      group = format_sync_grp,
    })
  end,
  event = { 'CmdlineEnter' },
  ft = { 'go', 'gomod' },
  build = ':lua require("go.install").update_all_sync()',
}

return M
