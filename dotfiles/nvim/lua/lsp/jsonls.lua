local shared = require 'lsp._shared'

return {
  config = shared.with_defaults {
    settings = {
      json = {
        schemas = require('schemastore').json.schemas {
          select = { 'openapi.json' },
        },
        validate = { enable = true },
      },
    },
  },
}
