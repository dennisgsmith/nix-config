vim.pack.add {
  { src = 'https://github.com/tpope/vim-dadbod' },
  { src = 'https://github.com/kristijanhusak/vim-dadbod-ui' },
  { src = 'https://github.com/kristijanhusak/vim-dadbod-completion' },
}

vim.api.nvim_create_user_command('DBCompletionConnect', function(opts)
  local dbname = opts.args
  if dbname == '' then
    vim.notify('DBCompletionConnect: provide a database name', vim.log.levels.ERROR)
    return
  end

  local url = ('postgresql://postgres:postgres@localhost:5432/%s'):format(dbname)
  vim.b.db = url
  vim.notify(('dadbod completion: connected buffer to %s'):format(url), vim.log.levels.INFO)
end, { nargs = 1 })

vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_use_postgres_views = 1
vim.g.db_ui_use_nvim_notify = 1
vim.g.db_ui_win_position = 'right'
vim.opt.shiftwidth = 2
