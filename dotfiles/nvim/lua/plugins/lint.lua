local lbft = {}

local eslint_fts = {
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
}

for _, v in ipairs(eslint_fts) do
  lbft[v] = { 'eslint_d' }
end

-- https://github.com/LazyVim/LazyVim/blob/f086bcde253c29be9a2b9c90b413a516f5d5a3b2/lua/lazyvim/plugins/linting.lua#L4
return {
  'mfussenegger/nvim-lint',
  opts = {
    events = { 'BufWritePost', 'BufReadPost', 'InsertLeave' },
    linters_by_ft = lbft,
  },
  config = function(_, opts)
    local M = {}

    local lint = require 'lint'
    lint.linters_by_ft = opts.linters_by_ft

    -- List of possible config files
    local config_files = {
      '.eslintrc',
      'eslint.config.json',
      'eslint.config.ts',
      'eslint.config.js',
      'eslint.config.mjs',
      'eslint.config.cjs',
    }

    -- Helper to find config for a file
    local function find_eslint_config(filename)
      local foundChild = vim.fs.find(config_files, {
        path = filename,
        upward = false,
      })
      if foundChild and #foundChild > 0 then
        return foundChild[1]
      end
      local foundParent = vim.fs.find(config_files, {
        path = filename,
        upward = true,
        stop = vim.loop.os_homedir(),
      })
      if foundParent and #foundParent > 0 then
        return foundParent[1]
      end
      return nil
    end

    -- Optionally, set a condition to only run if config exists
    local eslint_d = lint.linters.eslint_d
    if eslint_d then
      eslint_d.condition = function(ctx)
        return find_eslint_config(ctx.filename) ~= nil
      end
    end

    function M.debounce(ms, fn)
      local timer = vim.uv.new_timer()
      return function(...)
        local argv = { ... }
        timer:start(ms, 0, function()
          timer:stop()
          vim.schedule_wrap(fn)(unpack(argv))
        end)
      end
    end

    function M.lint()
      local names = lint._resolve_linter_by_ft(vim.bo.filetype)
      names = vim.list_extend({}, names)
      if #names == 0 then
        vim.list_extend(names, lint.linters_by_ft['_'] or {})
      end
      vim.list_extend(names, lint.linters_by_ft['*'] or {})
      local ctx = { filename = vim.api.nvim_buf_get_name(0) }
      ctx.dirname = vim.fn.fnamemodify(ctx.filename, ':h')
      names = vim.tbl_filter(function(name)
        local linter = lint.linters[name]
        if not linter then
          vim.api.nvim_err_writeln('Linter not found: ' .. name)
        end
        return linter and not (type(linter) == 'table' and linter.condition and not linter.condition(ctx))
      end, names)

      -- Dynamically set args for eslint_d if needed
      for _, name in ipairs(names) do
        if name == 'eslint_d' then
          local linter = lint.linters.eslint_d
          local config = find_eslint_config(ctx.filename)
          linter.args = {
            '--no-warn-ignored',
            '--format',
            'json',
            '--stdin',
            '--stdin-filename',
            ctx.filename,
          }
          if config then
            vim.notify(config)
            table.insert(linter.args, '--config')
            table.insert(linter.args, config)
          end
        end
      end

      if #names > 0 then
        lint.try_lint(names)
      end
    end

    vim.api.nvim_create_autocmd(opts.events, {
      group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
      callback = M.debounce(100, M.lint),
    })
  end,
}
