local shared = require 'lsp._shared'

return {
  config = shared.with_defaults {
    settings = {
      json = {
        schemas = require('schemastore').json.schemas {
          select = {
            '.eslintrc',
            'package.json',
            'openapi.json',
          },
          replace = {
            ['openapi.json'] = 'file://' .. vim.fn.stdpath 'config' .. '/schemas/openapi-3.X.json',
          },
        },
        validate = { enable = true },
      },
    },
  },
}
