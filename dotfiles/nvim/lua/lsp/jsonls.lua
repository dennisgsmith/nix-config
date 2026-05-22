local shared = require 'lsp._shared'

return {
  config = shared.with_defaults {
    settings = {
      json = {
        schemas = require('schemastore').json.schemas {
          replace = {
            ['openapi.json'] = 'file://' .. vim.fn.stdpath 'config' .. '/schemas/openapi-3.X.json',
          },
        },
        validate = { enable = true },
      },
    },
  },
}
