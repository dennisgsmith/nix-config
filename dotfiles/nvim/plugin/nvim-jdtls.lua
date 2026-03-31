vim.pack.add {
  { src = 'https://github.com/mfussenegger/nvim-jdtls' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
}

local has_mason, mason_registry = pcall(require, 'mason-registry')

local function is_mason_pkg_installed(name)
  return has_mason and mason_registry.is_installed(name)
end

local function get_mason_pkg_path(name)
  if not is_mason_pkg_installed(name) then
    return nil
  end

  return mason_registry.get_package(name):get_install_path()
end

local function first_readable(paths)
  for _, path in ipairs(paths) do
    if path and path ~= '' then
      local expanded = vim.fn.expand(path)
      if vim.fn.filereadable(expanded) == 1 then
        return expanded
      end
    end
  end

  return nil
end

local function get_lombok_jar()
  local env_path = vim.env.LOMBOK_JAR
  if env_path and env_path ~= '' then
    local found = first_readable { env_path }
    if found then
      return found
    end
  end

  local nix_env_path = vim.env.NIX_LOMBOK_JAR
  if nix_env_path and nix_env_path ~= '' then
    local found = first_readable { nix_env_path }
    if found then
      return found
    end
  end

  local mason_path = vim.fn.expand '$MASON/share/jdtls/lombok.jar'
  local found = first_readable { mason_path }
  if found then
    return found
  end

  return nil
end

local root_markers = {
  '.git',
  'mvnw',
  'gradlew',
  'pom.xml',
  'build.gradle',
  'build.gradle.kts',
  'settings.gradle',
  'settings.gradle.kts',
}

local function root_dir(fname)
  fname = fname ~= '' and fname or vim.api.nvim_buf_get_name(0)
  return vim.fs.root(fname, root_markers)
end

local function project_name(root)
  return root and vim.fs.basename(root) or nil
end

local function jdtls_config_dir(proj)
  return vim.fn.stdpath 'cache' .. '/jdtls/' .. proj .. '/config'
end

local function jdtls_workspace_dir(proj)
  return vim.fn.stdpath 'cache' .. '/jdtls/' .. proj .. '/workspace'
end

local function capabilities()
  local base = vim.lsp.protocol.make_client_capabilities()
  local caps = vim.tbl_deep_extend('force', base, require('blink.cmp').get_lsp_capabilities({}, false))

  caps = vim.tbl_deep_extend('force', caps, {
    textDocument = {
      foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      },
    },
  })

  return caps
end

local function build_cmd_base()
  local cmd = { vim.fn.exepath 'jdtls' }
  local lombok_jar = get_lombok_jar()

  if lombok_jar then
    table.insert(cmd, string.format('--jvm-arg=-javaagent:%s', lombok_jar))
  else
    vim.notify('Using jdtls without lombok support', vim.log.levels.WARN)
  end

  return cmd
end

local function collect_bundles(opts)
  local bundles = {}

  if not opts.dap then
    return bundles
  end

  local java_dbg_path = get_mason_pkg_path 'java-debug-adapter'
  if not java_dbg_path then
    return bundles
  end

  local jar_patterns = {
    java_dbg_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar',
  }

  if opts.test then
    local java_test_path = get_mason_pkg_path 'java-test'
    if java_test_path then
      vim.list_extend(jar_patterns, {
        java_test_path .. '/extension/server/*.jar',
      })
    end
  end

  for _, pattern in ipairs(jar_patterns) do
    for _, bundle in ipairs(vim.split(vim.fn.glob(pattern), '\n')) do
      if bundle ~= '' then
        table.insert(bundles, bundle)
      end
    end
  end

  return bundles
end

local opts = {
  root_dir = root_dir,
  project_name = project_name,
  jdtls_config_dir = jdtls_config_dir,
  jdtls_workspace_dir = jdtls_workspace_dir,
  cmd_base = build_cmd_base(),
  dap = { hotcodereplace = 'auto', config_overrides = {} },
  test = true,
  settings = {
    java = {
      inlayHints = {
        parameterNames = { enabled = 'all' },
      },
    },
    semanticHighlighting = { enabled = false },
  },
  _capabilities = capabilities(),
}

local bundles = collect_bundles(opts)

local function attach_jdtls()
  local fname = vim.api.nvim_buf_get_name(0)
  local root = opts.root_dir(fname)
  if not root then
    return
  end

  local proj = opts.project_name(root)
  if not proj then
    return
  end

  local base_cfg = vim.lsp.config.jdtls or {}

  local cmd = vim.deepcopy(opts.cmd_base)
  vim.list_extend(cmd, {
    '-configuration',
    opts.jdtls_config_dir(proj),
    '-data',
    opts.jdtls_workspace_dir(proj),
  })

  local cfg = vim.tbl_deep_extend('force', base_cfg, {
    cmd = cmd,
    root_dir = root,
    init_options = { bundles = bundles },
    settings = vim.tbl_deep_extend('force', opts.settings, base_cfg.settings or {}),
    capabilities = base_cfg.capabilities or opts._capabilities,
    on_attach = function(client, bufnr)
      client.server_capabilities.semanticTokensProvider = nil

      if type(base_cfg.on_attach) == 'function' then
        base_cfg.on_attach(client, bufnr)
      end

      if opts.dap and is_mason_pkg_installed 'java-debug-adapter' then
        require('jdtls').setup_dap(opts.dap)
      end
    end,
  })

  require('jdtls').start_or_attach(cfg)
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  callback = attach_jdtls,
})

if vim.bo.filetype == 'java' then
  attach_jdtls()
end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= 'jdtls' then
      return
    end

    local buf = args.buf

    if opts.test and is_mason_pkg_installed 'java-test' then
      vim.keymap.set('n', '<leader>tt', function()
        require('jdtls.dap').test_class()
      end, { buffer = buf, desc = 'Run All Tests' })

      vim.keymap.set('n', '<leader>tr', function()
        require('jdtls.dap').test_nearest_method()
      end, { buffer = buf, desc = 'Run Nearest Test' })
    end
  end,
})
