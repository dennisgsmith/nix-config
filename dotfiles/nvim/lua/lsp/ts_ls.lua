local shared = require 'lsp._shared'

return {
  config = shared.with_defaults {
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = {
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
    },
    root_markers = {
      'package-lock.json',
      'yarn.lock',
      'pnpm-lock.yaml',
      'bun.lockb',
      'bun.lock',
      'tsconfig.json',
      'jsconfig.json',
      'package.json',
      '.git',
    },
    settings = {
      format = { enable = false },
      diagnostics = { ignoredCodes = { 6133 } },
    },
  },
}
