local M = {}

function M.load()
  local dir = vim.fn.stdpath 'config' .. '/lua/lsp'
  local files = vim.fn.globpath(dir, '*.lua', false, true)

  table.sort(files)

  local servers = {}

  for _, path in ipairs(files) do
    local name = vim.fn.fnamemodify(path, ':t:r')

    if not name:match '^_' then
      local ok, mod = pcall(require, 'lsp.' .. name)

      if not ok then
        vim.notify(string.format('failed loading lsp.%s: %s', name, mod), vim.log.levels.ERROR)
      elseif type(mod) ~= 'table' then
        vim.notify(string.format('skipping lsp.%s: expected table, got %s', name, type(mod)), vim.log.levels.WARN)
      else
        servers[name] = vim.tbl_extend('force', {
          enabled = true,
        }, mod)
      end
    end
  end

  return servers
end

return M
