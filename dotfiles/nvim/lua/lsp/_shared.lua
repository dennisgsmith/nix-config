require 'sqlc'

local M = {}

M.has_nix = vim.fn.executable 'nix' == 1

do
  local orig_make_client_capabilities = vim.lsp.protocol.make_client_capabilities

  -- Fix https://github.com/neovim/neovim/issues/28058
  function vim.lsp.protocol.make_client_capabilities()
    local caps = orig_make_client_capabilities()
    if caps.workspace then
      caps.workspace.didChangeWatchedFiles = nil
    end
    return caps
  end
end

local base_capabilities = vim.lsp.protocol.make_client_capabilities()
base_capabilities.textDocument.completion.completionItem.snippetSupport = true

local function get_python_venv_settings()
  local venv = vim.env.VIRTUAL_ENV
  if not venv or venv == '' then
    return nil
  end

  return {
    venvPath = vim.fn.fnamemodify(venv, ':h'),
    venv = vim.fn.fnamemodify(venv, ':t'),
  }
end

M.get_python_venv_settings = get_python_venv_settings

function M.get_capabilities(extra)
  local capabilities = vim.tbl_deep_extend('force', vim.deepcopy(base_capabilities), require('blink.cmp').get_lsp_capabilities({}, false), {
    textDocument = {
      foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      },
    },
  }, extra or {})

  return capabilities
end

function M.on_attach(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, {
      buffer = bufnr,
      desc = desc,
    })
  end

  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('gT', vim.lsp.buf.type_definition, '[G]oto [T]ype')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  nmap('K', function()
    vim.lsp.buf.hover { border = 'rounded' }
  end, 'Hover Documentation')

  nmap('<C-k>', function()
    vim.lsp.buf.signature_help { border = 'rounded' }
  end, 'Signature Documentation')

  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
    require('conform').format { bufnr = bufnr }
  end, { desc = 'Format current buffer with LSP' })
end

function M.with_defaults(config, extra_capabilities)
  config = config or {}
  local user_on_attach = config.on_attach
  config.on_attach = function(client, bufnr)
    M.on_attach(client, bufnr)
    if type(user_on_attach) == 'function' then
      user_on_attach(client, bufnr)
    end
  end
  config.capabilities = vim.tbl_deep_extend('force', M.get_capabilities(extra_capabilities), config.capabilities or {})
  return config
end

function M.setup_diagnostics(signs)
  vim.diagnostic.config {
    virtual_text = true,
    float = {
      focusable = true,
      style = 'minimal',
      border = 'rounded',
      source = 'always',
      header = '',
      prefix = '',
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = signs.Error,
        [vim.diagnostic.severity.WARN] = signs.Warn,
        [vim.diagnostic.severity.INFO] = signs.Info,
        [vim.diagnostic.severity.HINT] = signs.Hint,
      },
    },
    underline = true,
    update_in_insert = true,
    severity_sort = true,
  }
end

return M
