local shared = require 'lsp._shared'

local config = shared.with_defaults {
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'requirements.txt', '.git' },
  settings = {
    pyright = {
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        typeCheckingMode = 'standard',
        reportMissingImports = 'error',
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
}

local venv = shared.get_python_venv_settings()
if venv then
  config.settings.python.venvPath = venv.venvPath
  config.settings.python.venv = venv.venv
end

return {
  config = config,
}
