local fbft = {
  lua = { 'stylua' },
  python = { 'ruff_organize_imports', 'ruff_format' },
}

local prettier_fts = {
  'javascript',
  'javascriptreact',
  'javascript.jsx',
  'typescript',
  'typescriptreact',
  'typescript.jsx',
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
  local uv = vim.loop
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

return {
  'stevearc/conform.nvim',
  dependencies = { 'mason-org/mason.nvim' },
  opts = {
    formatters_by_ft = fbft,
    format_on_save = {
      lsp_fallback = true,
      timeout_ms = 2500,
    },
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
  },
}
