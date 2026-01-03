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

vim.api.nvim_create_user_command('CopyPath', function()
  local path = vim.fn.expand '%:p'
  vim.fn.setreg('+', path)
  print(path .. ' yanked')
end, {})

vim.api.nvim_create_user_command('CopyRelPath', function()
  local relpath = vim.fn.expand '%'
  vim.fn.setreg('+', relpath)
  print(relpath .. ' yanked')
end, {})

vim.api.nvim_create_user_command('CopyFileName', function()
  local filename = vim.fn.expand '%:t'
  vim.fn.setreg('+', filename)
  print(filename .. ' yanked')
end, {})

-- https://go.dev/gopls/editor/vim#neovim-imports
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  pattern = '*.go',
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { 'source.organizeImports' } }
    -- buf_request_sync defaults to a 1000ms timeout. Depending on your
    -- machine and codebase, you may want longer. Add an additional
    -- argument after params if you find that you have to write the file
    -- twice for changes to be saved.
    -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
    local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or 'utf-16'
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
    vim.lsp.buf.format { async = false }
  end,
})
