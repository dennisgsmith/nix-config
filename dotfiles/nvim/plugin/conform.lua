local fbft = {
  lua = { 'stylua' },
  python = { 'ruff_organize_imports', 'ruff_format' },
}

local prettier_fts = {
  'javascript',
  'javascriptreact',
  'typescript',
  'typescriptreact',
  'json',
  'html',
  'scss',
  'css',
  'markdown',
  'yaml',
}

local prettier_config_files = {
  '.prettierrc',
  '.prettierrc.json',
  '.prettierrc.yaml',
  '.prettierrc.yml',
  '.prettierrc.js',
  '.prettierrc.cjs',
  'prettier.config.js',
  'prettier.config.cjs',
  'package.json',
}

for _, v in ipairs(prettier_fts) do
  fbft[v] = { 'prettierd' }
end

local function find_config_in_children(start_dir, config_names)
  local uv = vim.uv or vim.loop

  local function scan_dir(dir)
    local handle = uv.fs_scandir(dir)
    if not handle then
      return nil
    end

    while true do
      local name, typ = uv.fs_scandir_next(handle)
      if not name then
        break
      end

      local full_path = dir .. '/' .. name

      if typ == 'file' then
        for _, config in ipairs(config_names) do
          if name == config then
            return dir
          end
        end
      elseif typ == 'directory' then
        local found = scan_dir(full_path)
        if found then
          return found
        end
      end
    end

    return nil
  end

  return scan_dir(start_dir)
end

local function get_format_on_save_opts(bufnr)
  if vim.b[bufnr].format_on_save ~= nil then
    if vim.b[bufnr].format_on_save then
      return {
        lsp_fallback = true,
        timeout_ms = 2500,
      }
    end

    return nil
  end

  if vim.g.format_on_save == nil then
    vim.g.format_on_save = true
  end

  if vim.g.format_on_save then
    return {
      lsp_fallback = true,
      timeout_ms = 2500,
    }
  end

  return nil
end

vim.pack.add {
  { src = 'https://github.com/stevearc/conform.nvim' },
  { src = 'https://github.com/mason-org/mason.nvim' },
}

local conform = require 'conform'

conform.setup {
  formatters_by_ft = fbft,
  format_on_save = function(bufnr)
    return get_format_on_save_opts(bufnr)
  end,
  formatters = {
    prettierd = {
      command = 'prettierd',
      cwd = function(ctx)
        local start_dir = vim.fn.fnamemodify(ctx.filename, ':h')
        local config_dir = find_config_in_children(start_dir, prettier_config_files)
        return config_dir or start_dir
      end,
      require_cwd = false,
    },
  },
}

vim.g.format_on_save = true

vim.api.nvim_create_user_command('FormatToggle', function()
  vim.g.format_on_save = not vim.g.format_on_save
  vim.notify('format on save (global): ' .. (vim.g.format_on_save and 'on' or 'off'))
end, { desc = 'Toggle format on save globally' })

vim.api.nvim_create_user_command('FormatToggleBuffer', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local current = vim.b[bufnr].format_on_save

  if current == nil then
    vim.b[bufnr].format_on_save = false
  else
    vim.b[bufnr].format_on_save = not current
  end

  vim.notify('format on save (buffer): ' .. (vim.b[bufnr].format_on_save and 'on' or 'off'))
end, { desc = 'Toggle format on save for current buffer' })

vim.api.nvim_create_user_command('FormatBufferEnable', function()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.b[bufnr].format_on_save = true
  vim.notify 'format on save (buffer): on'
end, { desc = 'Enable format on save for current buffer' })

vim.api.nvim_create_user_command('FormatBufferDisable', function()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.b[bufnr].format_on_save = false
  vim.notify 'format on save (buffer): off'
end, { desc = 'Disable format on save for current buffer' })

vim.api.nvim_create_user_command('FormatBufferReset', function()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.b[bufnr].format_on_save = nil
  vim.notify 'format on save (buffer): reset to global default'
end, { desc = 'Reset current buffer format on save override' })
