local M = {}
local session_enabled = false
local pending = {}
local previous = {}
local library = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h:h:h') .. '/types/crow'

local function is_lua(buf)
  return vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == 'lua'
end

local function detach_regular(buf, client)
  previous[buf] = previous[buf] or {}
  previous[buf][client.id] = true
  vim.lsp.buf_detach_client(buf, client.id)
end

local function deactivate(buf)
  if not vim.api.nvim_buf_is_valid(buf) or not vim.b[buf].crow_lsp then
    return
  end
  vim.b[buf].crow_lsp = nil
  for _, client in ipairs(vim.lsp.get_clients { bufnr = buf, name = 'crow_lua_ls' }) do
    vim.lsp.buf_detach_client(buf, client.id)
  end
  for id in pairs(previous[buf] or {}) do
    local client = vim.lsp.get_client_by_id(id)
    if client and not client:is_stopped() then
      vim.lsp.buf_attach_client(buf, id)
    end
  end
  previous[buf] = nil
end

local function activate(buf)
  if not is_lua(buf) or vim.b[buf].crow_lsp then
    return
  end
  if vim.fn.executable 'lua-language-server' ~= 1 then
    vim.notify('Crow: lua-language-server is not on PATH', vim.log.levels.WARN)
    return
  end
  -- Single-file mode keeps crow metadata separate from the ordinary Lua
  -- workspace, even when a crow script lives alongside Neovim configuration.
  local id = vim.lsp.start({
    name = 'crow_lua_ls',
    cmd = { 'lua-language-server' },
    settings = {
      Lua = {
        runtime = { version = 'Lua 5.3' },
        workspace = { library = { library }, checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
    on_attach = function(client, attached_buf)
      vim.bo[attached_buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
      vim.lsp.completion.enable(true, client.id, attached_buf, { autotrigger = true })
      vim.keymap.set('n', 'K', function()
        vim.lsp.buf.hover { border = 'rounded' }
      end, { buffer = attached_buf, desc = 'Crow: hover documentation' })
      vim.keymap.set('n', '<C-k>', function()
        vim.lsp.buf.signature_help { border = 'rounded' }
      end, { buffer = attached_buf, desc = 'Crow: signature help' })
    end,
  }, {
    bufnr = buf,
    reuse_client = function(client)
      return client.name == 'crow_lua_ls'
    end,
  })
  if id then
    vim.b[buf].crow_lsp = true
    for _, client in ipairs(vim.lsp.get_clients { bufnr = buf, name = 'lua_ls' }) do
      detach_regular(buf, client)
    end
  end
end

function M.on_send(buf, success)
  if success then
    session_enabled = true
    activate(buf)
  else
    deactivate(buf)
  end
end

local function check(buf)
  if not session_enabled or not is_lua(buf) or pending[buf] then
    return
  end
  pending[buf] = true
  -- An empty connection checks druid without sending a command to crow.
  local ok = pcall(vim.system, { 'websocat', '-t', '-u', vim.g.druid_url or 'ws://localhost:6666' }, {
    stdin = '',
    timeout = 2000,
  }, function(result)
    vim.schedule(function()
      pending[buf] = nil
      if result.code == 0 then
        activate(buf)
      else
        deactivate(buf)
      end
    end)
  end)
  if not ok then
    pending[buf] = nil
    deactivate(buf)
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup('CrowLanguageServer', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'FileType', 'FocusGained' }, {
    group = group,
    callback = function(ev)
      check(ev.buf)
    end,
  })
  vim.api.nvim_create_autocmd('LspAttach', {
    group = group,
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if vim.b[ev.buf].crow_lsp and client and client.name == 'lua_ls' then
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ev.buf) and vim.b[ev.buf].crow_lsp then
            detach_regular(ev.buf, client)
          end
        end)
      end
    end,
  })
  vim.api.nvim_create_autocmd('BufWipeout', {
    group = group,
    callback = function(ev)
      previous[ev.buf] = nil
    end,
  })
end

return M
