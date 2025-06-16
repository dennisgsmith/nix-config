local fbft = {
  lua = { 'stylua' },
  python = { 'isort', 'black' },
}

local prettier_fts = {
  'javascript',
  'javascriptreact',
  'javascript.jsx',
  'typescript',
  'typescriptreact',
  'typescript.jsx',
  'json',
  'html',
  'scss',
  'css',
  'markdown',
  'yaml',
}

for _, v in ipairs(prettier_fts) do
  fbft[v] = { 'prettierd' }
end

return {
  'stevearc/conform.nvim',
  dependencies = { 'mason-org/mason.nvim' },
  opts = {
    formatters_by_ft = fbft,
    format_on_save = {
      lsp_fallback = true,
      timeout_ms = 2500,
    },
  },
}
