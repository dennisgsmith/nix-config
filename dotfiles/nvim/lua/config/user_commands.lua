vim.api.nvim_create_user_command('H', function(table)
  vim.cmd('help ' .. table.args .. ' | only')
end, { desc = 'Open [H]elp in new tab', nargs = 1 })
