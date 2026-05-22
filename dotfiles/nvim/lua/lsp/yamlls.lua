local shared = require 'lsp._shared'

return {
  config = shared.with_defaults {
    settings = {
      yaml = {
        -- Ignore default schema store, use SchemaStore.nvim
        schemaStore = {
          enable = false,
          url = '',
        },
        schemas = require('schemastore').yaml.schemas {
          replace = {
            ['openapi.json'] = 'file://' .. vim.fn.stdpath 'config' .. '/schemas/openapi-3.X.json',
          },
        },
      },
    },
  },
}
