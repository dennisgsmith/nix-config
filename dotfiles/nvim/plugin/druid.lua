-- Requires a running druid REPL. Crow's responses appear in that terminal.
local function send(lines, block)
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.fn.executable 'websocat' ~= 1 then
    vim.notify('Druid: websocat is not on PATH', vim.log.levels.ERROR)
    return
  end
  local text = table.concat(lines, '\n')
  if block then
    text = '```\n' .. text .. '\n```'
  end
  -- One WebSocket text frame per line, including blank lines. EOF closes the
  -- connection without waiting for a reply (many crow commands have none).
  local ok, err = pcall(vim.system, { 'websocat', '-t', '-u', vim.g.druid_url or 'ws://localhost:6666' }, {
    stdin = text .. '\n',
    text = true,
    timeout = 5000,
  }, function(result)
    vim.schedule(function()
      require('config.crow').on_send(bufnr, result.code == 0)
    end)
    if result.code ~= 0 then
      vim.schedule(function()
        vim.notify('Druid: send failed; is druid running?\n' .. (result.stderr or ''), vim.log.levels.ERROR)
      end)
    end
  end)
  if not ok then
    vim.notify('Druid: ' .. tostring(err), vim.log.levels.ERROR)
  end
end

require('config.crow').setup()

vim.api.nvim_create_user_command('DruidSend', function(opts)
  if opts.args ~= '' then
    if opts.range > 0 then
      vim.notify('DruidSend: use either text or a range', vim.log.levels.ERROR)
      return
    end
    send({ opts.args }, false)
  else
    send(vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false), opts.range > 0)
  end
end, { nargs = '*', range = true, desc = 'Druid: send text/current line, or a line range as a Lua block' })

vim.api.nvim_create_user_command('DruidSendBuffer', function()
  send(vim.api.nvim_buf_get_lines(0, 0, -1, false), true)
end, { desc = 'Druid: evaluate the current buffer as a Lua block (without saving to flash)' })

local function send_script(end_command)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  if #table.concat(lines, '\n') > 8 * 1024 then
    vim.notify('Druid: crow scripts are limited to 8 KiB', vim.log.levels.ERROR)
    return
  end
  table.insert(lines, 1, '^^s')
  table.insert(lines, end_command)
  send(lines, false)
end

vim.api.nvim_create_user_command('DruidExecuteScript', function()
  send_script '^^e'
end, { desc = 'Druid: send the current buffer to crow and run it without saving to flash' })

vim.api.nvim_create_user_command('DruidWriteScript', function()
  send_script '^^w'
end, { desc = 'Druid: send the current buffer to crow, save it to flash, and run it' })

-- https://monome.org/docs/crow/technical/#environment-commands
local environment = {
  { 'StartScript', 'startscript', 'Begin receiving a script' },
  { 'ExecuteScript', 'executescript', 'Upload the current buffer and run it', true },
  { 'WriteScript', 'writescript', 'Upload the current buffer, save it to flash, and run it', true },
  { 'ClearScript', 'clearscript', 'Clear the saved user script' },
  { 'First', 'First', 'Restore and run the First script' },
  { 'PrintScript', 'printscript', 'Print the saved script in the druid terminal' },
  { 'Bootloader', 'bootloader', 'Enter the firmware bootloader' },
  { 'Reset', 'reset', 'Reboot crow and reset its USB connection' },
  { 'Kill', 'kill', 'Restart Lua without running the user script' },
  { 'Identity', 'identity', 'Print the crow serial number' },
  { 'Version', 'version', 'Print the crow firmware version' },
}

for _, action in ipairs(environment) do
  if not action[4] then
    vim.api.nvim_create_user_command('Druid' .. action[1], function()
      send({ '^^' .. action[2] }, false)
    end, { desc = 'Druid: ' .. action[3] })
  end
end

vim.api.nvim_create_user_command('DruidEnvironment', function()
  vim.ui.select(environment, {
    prompt = 'Crow environment command:',
    format_item = function(action)
      return action[1] .. ' — ' .. action[3]
    end,
  }, function(action)
    if action then
      if action[4] then
        vim.cmd('Druid' .. action[1])
      else
        send({ '^^' .. action[2] }, false)
      end
    end
  end)
end, { desc = 'Druid: choose a crow environment command' })

vim.keymap.set('n', '<leader>cl', '<Cmd>DruidSend<CR>', { desc = 'Crow: send current line' })
vim.keymap.set('x', '<leader>cs', ':DruidSend<CR>', { desc = 'Crow: send selected lines as a block', silent = true })
vim.keymap.set('n', '<leader>cb', '<Cmd>DruidSendBuffer<CR>', { desc = 'Crow: evaluate buffer' })
vim.keymap.set('n', '<leader>ce', '<Cmd>DruidEnvironment<CR>', { desc = 'Crow: environment commands' })
