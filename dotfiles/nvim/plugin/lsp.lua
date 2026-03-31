local has_nix = vim.fn.executable 'nix' == 1

local specs = {
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/saghen/blink.cmp' },
  { src = 'https://github.com/b0o/schemastore.nvim' },
}

if not has_nix then
  table.insert(specs, { src = 'https://github.com/mason-org/mason.nvim' })
  table.insert(specs, { src = 'https://github.com/mason-org/mason-lspconfig.nvim' })
end

vim.pack.add(specs)

local shared = require 'lsp._shared'
local registry = require 'lsp._registry'

shared.setup_diagnostics {
  Error = '✗ ',
  Warn = '! ',
  Hint = '󰌶 ',
  Info = ' ',
}

local servers = registry.load()
local enable = {}
local ensure_installed = {}

for name, def in pairs(servers) do
  if def.enabled ~= false then
    local config = def.config or def

    vim.lsp.config(name, config)
    table.insert(enable, name)

    if not has_nix and def.mason ~= false then
      table.insert(ensure_installed, name)
    end
  end
end

if not has_nix then
  require('mason').setup {}
  require('mason-lspconfig').setup {
    ensure_installed = ensure_installed,
  }
end

for _, name in ipairs(enable) do
  vim.lsp.enable(name)
end
