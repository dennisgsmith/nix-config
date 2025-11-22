require 'sqlc'
local utils = require 'utils'

local function get_python_venv_settings()
  local venv = vim.env.VIRTUAL_ENV
  if not venv or venv == '' then
    return nil
  end

  -- e.g. /Users/.../instrumentation-dcs-config/.venv
  local venv_name = vim.fn.fnamemodify(venv, ':t') -- ".venv"
  local venv_dir = vim.fn.fnamemodify(venv, ':h') -- "/Users/.../instrumentation-dcs-config"

  return {
    venvPath = venv_dir, -- directory that contains the venv
    venv = venv_name, -- name of the venv directory
  }
end

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
  local py_venv_settings = get_python_venv_settings()
  local pyright = {
    bin = 'pyright',
    config = {
      on_attach = on_attach,
      capabilities = capabilities,
      filetypes = { 'python' },
      root_dir = vim.fs.root(0, { 'pyproject.toml', 'requirements.txt', '.git' }),
      settings = {
        pyright = { disableOrganizeImports = true },
        python = {
          analysis = {
            typeCheckingMode = 'standard',
            reportMissingImports = 'error',
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
          },
        },
      },
    },
  }
  if py_venv_settings then
    pyright.config.settings.python.venvPath = py_venv_settings.venvPath
    pyright.config.settings.python.venv = py_venv_settings.venv
  end
  return {
    bashls = {
      bin = 'bash-language-server',
      config = {
        on_attach = function(client, bufnr)
          local filename = vim.api.nvim_buf_get_name(bufnr)
          if filename:match '%.env$' or vim.fn.fnamemodify(filename, ':t') == '.env' then
            client.stop()
            return
          end
          on_attach(client, bufnr)
        end,
        capabilities = capabilities,
        filetypes = { 'bash', 'sh' },
      },
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
      config = {
        on_attach = on_attach,
        root_dir = vim.fs.root(0, { 'eslint.config.ts', 'eslint.config.js', '.eslintrc', 'package.json', '.git' }),
        capabilities = capabilities,
        filetypes = { 'js', 'mjs', 'cjs' },
      },
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
        settings = {
          json = {
            schemas = require('schemastore').json.schemas {
              select = { 'openapi.json' },
            },
            validate = { enable = true },
          },
        },
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
    -- nil_ls = {
    --   bin = 'nil',
    --   config = { on_attach = on_attach, capabilities = capabilities },
    -- },
    -- postgres_lsp = {
    --   bin = 'postgrestools',
    --   config = {
    --     on_attach = on_attach,
    --     capabilities = capabilities,
    --     cmd = {
    --       'postgrestools',
    --       'lsp-proxy',
    --     },
    --     filetypes = {
    --       'sql',
    --     },
    --     root_markers = {
    --       'postgrestools.jsonc',
    --     },
    --     on_init = function(client, _)
    --       local filename = vim.api.nvim_buf_get_name(0)
    --       if not filename:match '%.sql$' then
    --         client.stop()
    --       end
    --     end,
    --   },
    -- },
    pyright = pyright,
    ruff = {
      bin = 'ruff',
      filetypes = { 'python' },
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
        root_dir = vim.fs.root(0, { 'tsconfig.json', 'package.json', '.git' }),
        on_attach = on_attach,
        capabilities = capabilities,
      },
    },
    yamlls = {
      bin = 'yaml-language-server',
      config = {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          yaml = {
            schemaStore = {
              enable = true,
              url = 'https://www.schemastore.org/api/json/catalog.json',
            },
            schemas = require('schemastore').json.schemas {
              select = { 'openapi.json' },
            },
          },
          -- replace = {
          --   ['openapi.yaml'] = {
          --     description = "OpenAPI 3.1",
          --     fileMatch = { "openapi.yaml", "openapi.yml" },
          --     name = "openapi.yaml",
          --     url = "https://example.com/schema/openapi.json"
          --   },
          -- },
        },
        on_init = function(client, _)
          local bufnr = vim.api.nvim_get_current_buf()
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, math.min(20, vim.api.nvim_buf_line_count(bufnr)), false)
          local openapi_version
          for _, line in ipairs(lines) do
            local v = line:match '^openapi:%s*([%d%.]+)'
            if v then
              openapi_version = v
              break
            end
          end
          if openapi_version then
            local major = openapi_version:match '^(%d+)'
            local schema_url
            if major == '3' then
              if openapi_version:find '^3%.0' then
                schema_url = 'https://spec.openapis.org/oas/3.0/schema/2021-09-28'
              elseif openapi_version:find '^3%.1' then
                schema_url = 'https://spec.openapis.org/oas/3.1/schema/2022-10-07'
              end
            end
            if schema_url then
              client.config.settings.yaml.schemas[schema_url] = { 'openapi.yaml', 'openapi.yml', 'openapi.json' }
              client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
            end
          end
        end,
      },
    },
  }
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

return {
  {
    'mason-org/mason-lspconfig.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'mason.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'stevearc/conform.nvim',
      'b0o/schemastore.nvim',
    },
    config = function()
      local lsp_servers = {}

      for name, def in pairs(make_servers(get_capabilities())) do
        local cfg = type(def.config) == 'function' and def.config() or def.config
        vim.lsp.config[name] = cfg
      end

      for name, _ in pairs(make_servers(function() end, get_capabilities())) do
        table.insert(lsp_servers, name)
      end

      require('mason-lspconfig').setup {
        ensure_installed = lsp_servers,
      }
    end,
  },
}
