vim.pack.add {
  { src = 'https://github.com/jellydn/hurl.nvim' },
  { src = 'https://github.com/MunifTanjim/nui.nvim' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim' },
}

local hurl_loaded = false
local render_markdown_loaded = false

local function packadd(name)
  pcall(vim.cmd.packadd, name)
end

local function load_render_markdown()
  if render_markdown_loaded then
    return
  end

  packadd 'nvim-treesitter'
  packadd 'render-markdown.nvim'

  require('render-markdown').setup {
    file_types = { 'markdown' },
  }

  render_markdown_loaded = true
end

local function load_hurl()
  if hurl_loaded then
    return
  end

  packadd 'nui.nvim'
  packadd 'plenary.nvim'
  packadd 'nvim-treesitter'
  packadd 'hurl.nvim'

  require('hurl').setup {
    debug = false,
    auto_close = false,
    mode = 'split',

    formatters = {
      json = { 'jq' },
      html = { 'prettier', '--parser', 'html' },
      xml = { 'tidy', '-xml', '-i', '-q' },
    },

    mappings = {
      next_panel = '<C-n>',
      prev_panel = '<C-p>',
    },
  }

  hurl_loaded = true
end

local function hurl_cmd(cmd)
  return function()
    load_hurl()
    vim.cmd(cmd)
  end
end

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  pattern = '*.hurl',
  callback = function()
    load_hurl()
  end,
})

vim.api.nvim_create_user_command('HurlRunner', function(opts)
  load_hurl()
  vim.cmd('HurlRunner ' .. opts.args)
end, { nargs = '*' })

vim.api.nvim_create_user_command('HurlRunnerAt', function(opts)
  load_hurl()
  vim.cmd('HurlRunnerAt ' .. opts.args)
end, { nargs = '*' })

vim.api.nvim_create_user_command('HurlRunnerToEntry', function(opts)
  load_hurl()
  vim.cmd('HurlRunnerToEntry ' .. opts.args)
end, { nargs = '*' })

vim.api.nvim_create_user_command('HurlRunnerToEnd', function(opts)
  load_hurl()
  vim.cmd('HurlRunnerToEnd ' .. opts.args)
end, { nargs = '*' })

vim.api.nvim_create_user_command('HurlToggleMode', function(opts)
  load_hurl()
  vim.cmd('HurlToggleMode ' .. opts.args)
end, { nargs = '*' })

vim.api.nvim_create_user_command('HurlVerbose', function(opts)
  load_hurl()
  vim.cmd('HurlVerbose ' .. opts.args)
end, { nargs = '*' })

vim.api.nvim_create_user_command('HurlVeryVerbose', function(opts)
  load_hurl()
  vim.cmd('HurlVeryVerbose ' .. opts.args)
end, { nargs = '*' })

vim.api.nvim_create_user_command('HurlShowLastResponse', function(opts)
  load_hurl()
  load_render_markdown()
  vim.cmd('HurlShowLastResponse ' .. opts.args)
end, { nargs = '*' })

vim.keymap.set('n', '<leader>hi', function()
  load_hurl()
  load_render_markdown()

  local hurl_win = nil

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local bufnr = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
    local buftype = vim.api.nvim_get_option_value('buftype', { buf = bufnr })

    if ft == 'markdown' and buftype == 'nofile' then
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 2, false)
      if lines[1] and lines[1]:match '^# Request' then
        hurl_win = win
        break
      end
    end
  end

  if hurl_win then
    local prev_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(hurl_win)
    vim.cmd 'q'

    if prev_win ~= hurl_win and vim.api.nvim_win_is_valid(prev_win) then
      pcall(vim.api.nvim_set_current_win, prev_win)
    end
  else
    vim.defer_fn(function()
      vim.cmd 'HurlShowLastResponse'
    end, 50)
  end
end, { desc = 'Toggle Hurl Panel' })

vim.keymap.set('n', '<leader>hA', hurl_cmd 'HurlRunner', { desc = 'Run All requests' })
vim.keymap.set('n', '<leader>ha', hurl_cmd 'HurlRunnerAt', { desc = 'Run Api request' })
vim.keymap.set('n', '<leader>hte', hurl_cmd 'HurlRunnerToEntry', { desc = 'Run Api request to entry' })
vim.keymap.set('n', '<leader>htE', hurl_cmd 'HurlRunnerToEnd', { desc = 'Run Api request from current entry to end' })
vim.keymap.set('n', '<leader>htm', hurl_cmd 'HurlToggleMode', { desc = 'Hurl Toggle Mode' })
vim.keymap.set('n', '<leader>htv', hurl_cmd 'HurlVerbose', { desc = 'Run Api in verbose mode' })
vim.keymap.set('n', '<leader>htV', hurl_cmd 'HurlVeryVerbose', { desc = 'Run Api in very verbose mode' })

vim.keymap.set('v', '<leader>h', function()
  load_hurl()
  vim.cmd 'HurlRunner'
end, { desc = 'Hurl Runner' })
