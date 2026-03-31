-- https://github.com/harrisoncramer/nvim/blob/74b5f13282472b2b11d335c911d11de16b4c9fef/lua/sqlc.lua
local sqlc_namespace = vim.api.nvim_create_namespace 'sqlc'

---@param output string
---@return vim.Diagnostic[]
local function parse_sqlc_output(output)
  local diagnostics = {}

  for line in output:gmatch '[^\r\n]+' do
    local filename, lnum, col, message = line:match '^(.-):(%d+):(%d+): (.+)$'
    if filename and lnum and col and message then
      table.insert(diagnostics, {
        filename = filename,
        lnum = tonumber(lnum) - 1,
        col = tonumber(col) - 1,
        message = message,
        severity = vim.diagnostic.severity.ERROR,
      })
    end
  end

  return diagnostics
end

local function current_sqlc_paths()
  local bufname = vim.api.nvim_buf_get_name(0)
  local current_dir = vim.fs.dirname(bufname)
  local file_name = vim.fs.basename(bufname)

  return {
    cwd = current_dir,
    config_file = current_dir .. '/sqlc.yaml',
    target_file = current_dir .. '/' .. file_name,
  }
end

---@return string
local function run_sqlc_against_current_file()
  local paths = current_sqlc_paths()

  local result = vim
    .system({
      'sqlc',
      'vet',
      '-f',
      paths.config_file,
      paths.target_file,
    }, {
      cwd = paths.cwd,
      env = {
        SQLC_DATABASE_URI = 'postgresql://postgres:postgres@127.0.0.1:5432/postgres?connect_timeout=300',
      },
      text = true,
    })
    :wait()

  return result.stdout or result.stderr or ''
end

local function clear_diagnostics()
  vim.diagnostic.reset(sqlc_namespace, 0)
end

local function set_diagnostics()
  clear_diagnostics()

  local output = run_sqlc_against_current_file()
  if output == '' then
    return
  end

  local diagnostics = parse_sqlc_output(output)
  vim.diagnostic.set(sqlc_namespace, 0, diagnostics)
end

vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertEnter' }, {
  pattern = '*.sql',
  callback = function(args)
    if args.event == 'BufWritePost' then
      set_diagnostics()
    elseif args.event == 'InsertEnter' then
      clear_diagnostics()
    end
  end,
})

return {
  sqlc_namespace,
}
