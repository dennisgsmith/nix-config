vim.cmd.syntax 'enable'
vim.g.sql_type_default = 'pgsql'

pcall(vim.treesitter.stop, 0)
