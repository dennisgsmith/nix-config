local utils = require 'utils'

local client_capabilities = vim.lsp.protocol.make_client_capabilities()
client_capabilities.textDocument.completion.completionItem.snippetSupport = true

local function get_capabilities()
  return require('cmp_nvim_lsp').default_capabilities(client_capabilities)
end

local function on_attach(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

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

local function make_servers(capabilities)
  return {
    bashls = {
      bin = 'bash-language-server',
      config = { on_attach = on_attach, capabilities = capabilities },
    },
    clangd = {
      bin = 'clangd',
      config = function()
        local c = vim.deepcopy(capabilities)
        c.offsetEncoding = { 'utf-16' }
        return { on_attach = on_attach, capabilities = c }
      end,
    },
    cssls = {
      bin = 'css-lsp',
      config = { on_attach = on_attach, capabilities = capabilities },
    },
    cssmodules_ls = {
      bin = 'cssmodules-language-server',
      config = { on_attach = on_attach, capabilities = capabilities },
    },
    docker_compose_language_service = {
      bin = 'docker-compose-language-service',
      config = { on_attach = on_attach, capabilities = capabilities },
    },
    dockerls = {
      bin = 'dockerfile-language-server',
      config = { on_attach = on_attach, capabilities = capabilities },
    },
    eslint = {
      bin = 'eslint-lsp',
      config = { on_attach = on_attach, capabilities = capabilities },
    },
    gopls = {
      bin = 'gopls',
      config = {
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = { 'gopls' },
        filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
        root_dir = vim.fs.root(0, { 'go.work', 'go.mod', '.git' }),
        settings = {
          gopls = {
            completeUnimported = true,
            usePlaceholders = true,
          },
          analyses = { unusedparams = true },
        },
      },
    },
    html = {
      bin = 'html-lsp',
      config = { on_attach = on_attach, capabilities = capabilities },
    },
    java_language_server = {
      bin = 'java-language-server',
      config = { on_attach = on_attach, capabilities = capabilities },
    },
    jsonls = {
      bin = 'json-lsp',
      config = {
        commands = {
          Format = {
            function()
              vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line '$', 0 })
            end,
          },
        },
        on_attach = on_attach,
        capabilities = capabilities,
      },
    },
    lua_ls = {
      bin = 'lua-language-server',
      config = {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim', 'require' } },
            format = { enable = true },
            telemetry = { enable = false },
          },
        },
      },
    },
    nil_ls = {
      bin = 'nil',
      config = { on_attach = on_attach, capabilities = capabilities },
    },
    pyright = {
      bin = 'pyright',
      config = { on_attach = on_attach, capabilities = capabilities },
    },
    rust_analyzer = {
      bin = 'rust-analyzer',
      config = { on_attach = on_attach, capabilities = capabilities },
    },
    taplo = {
      bin = 'taplo',
      config = { on_attach = on_attach, capabilities = capabilities },
    },
    ts_ls = {
      bin = 'typescript-language-server',
      config = {
        root_dir = vim.fs.root(0, { '.git' }),
        on_attach = on_attach,
        capabilities = capabilities,
      },
    },
    yamlls = {
      bin = 'yaml-language-server',
      config = { on_attach = on_attach, capabilities = capabilities },
    },
  }
end

for name, def in pairs(make_servers(get_capabilities())) do
  local cfg = type(def.config) == 'function' and def.config() or def.config
  vim.lsp.config(name, cfg)
end

vim.diagnostic.config {
  virtual_text = false,
  float = {
    focusable = true,
    style = 'minimal',
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
  signs = true,
  underline = true,
  update_in_insert = true,
  severity_sort = false,
}

local signs = utils.lsp_signs
for _, _ in pairs(signs) do
  vim.diagnostic.config {
    signs = {
      ['Error'] = { text = utils.lsp_signs.Error },
      ['Warn'] = { text = utils.lsp_signs.Warn },
      ['Info'] = { text = utils.lsp_signs.Info },
      ['Hint'] = { text = utils.lsp_signs.Hint },
    },
  }
end

local lsp_servers = {}

for name, _ in pairs(make_servers(function() end, get_capabilities())) do
  table.insert(lsp_servers, name)
end

return {
  {
    'mason-org/mason-lspconfig.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'mason.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'stevearc/conform.nvim',
    },
    config = function()
      require('mason-lspconfig').setup {
        ensure_installed = lsp_servers,
      }
    end,
  },
}
