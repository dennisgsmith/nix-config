-- keeps track of buffers that have been "touched" (entered insert mode or modified the buffer)
local id = vim.api.nvim_create_augroup('startup', { clear = false })

local persistbuffer = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.fn.setbufvar(bufnr, 'bufpersist', 1)
end

vim.api.nvim_create_autocmd({ 'BufRead' }, {
  group = id,
  pattern = { '*' },
  callback = function()
    vim.api.nvim_create_autocmd({ 'InsertEnter', 'BufModifiedSet' }, {
      buffer = 0,
      once = true,
      callback = function()
        persistbuffer()
      end,
    })
  end,
})

--- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

vim.cmd [[autocmd InsertEnter * :set norelativenumber]]
vim.cmd [[autocmd InsertLeave * :set relativenumber]]

vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  callback = function(args)
    local buf_id = args.data.buf_id

    vim.keymap.set('n', '<CR>', function()
      local mini_files = require 'mini.files'
      local entry = mini_files.get_fs_entry()
      if entry ~= nil then
        if entry.fs_type == 'directory' then
          mini_files.go_in()
        else
          mini_files.go_in()
          mini_files.close()
        end
      end
    end, { buffer = buf_id, noremap = true, silent = true })
  end,
})

-- Define a function to set the Avante highlights
local function set_avante_highlights()
  -- Link groups to standard Diff highlight groups
  vim.api.nvim_set_hl(0, 'AvanteReversedThirdTitle', { link = 'DiffText' })
  vim.api.nvim_set_hl(0, 'AvanteThirdTitle', { link = 'DiffText' })
  vim.api.nvim_set_hl(0, 'AvanteReversedSubtitle', { link = 'DiffChange' })
  vim.api.nvim_set_hl(0, 'AvanteSubtitle', { link = 'DiffChange' })
  vim.api.nvim_set_hl(0, 'AvanteReversedTitle', { link = 'DiffAdd' })
  vim.api.nvim_set_hl(0, 'AvanteTitle', { link = 'DiffAdd' })
  vim.api.nvim_set_hl(0, 'AvanteToBeDeletedWOStrikethrough', { link = 'DiffDelete' })
  vim.api.nvim_set_hl(0, 'AvanteConflictIncoming', { link = 'DiffAdd' })
  vim.api.nvim_set_hl(0, 'AvanteConflictCurrent', { link = 'DiffCurrent' })
  vim.api.nvim_set_hl(0, 'AvanteConflictCurrentLabel', { link = 'DiffText' })
  vim.api.nvim_set_hl(0, 'AvanteConflictIncomingLabel', { link = 'DiffText' })

  -- For AvanteToBeDeleted, copy DiffDelete's fg and bg and add strikethrough
  local diffdelete = vim.api.nvim_get_hl_by_name('DiffDelete', true)
  vim.api.nvim_set_hl(0, 'AvanteToBeDeleted', {
    fg = diffdelete.foreground,
    bg = diffdelete.background,
    strikethrough = true,
  })
end

-- Create an autocommand to reapply these settings when the colorscheme changes
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = set_avante_highlights,
})

set_avante_highlights()
