local shared = require 'lsp._shared'

return {
  enabled = vim.fn.executable 'nix' == 1,
  mason = false,
  config = shared.with_defaults(),
}
