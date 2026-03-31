local shared = require 'lsp._shared'

return {
  config = shared.with_defaults {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        diagnostics = {
          globals = { 'vim', 'require' },
        },
        format = { enable = true },
        telemetry = { enable = false },
      },
    },
  },
}
