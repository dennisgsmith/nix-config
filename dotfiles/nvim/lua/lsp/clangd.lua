local shared = require 'lsp._shared'

return {
  config = shared.with_defaults({}, {
    offsetEncoding = { 'utf-16' },
  }),
}
