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

local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.hl.on_yank()
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

vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'markdown',
    'text',
    'gitcommit',
    'rst',
    'asciidoc',
  },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { 'en_us' }
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'TelescopePrompt',
  callback = function(args)
    vim.bo[args.buf].autocomplete = false
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    if client:supports_method 'textDocument/completion' then
      vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, {
        -- Optional formating of items
        convert = function(item)
          -- Remove leading misc chars for abbr name,
          -- and cap field to 25 chars
          --local abbr = item.label
          --abbr = abbr:match("[%w_.]+.*") or abbr
          --abbr = #abbr > 25 and abbr:sub(1, 24) .. "…" or abbr
          --
          -- Remove return value
          --local menu = ""

          -- Only show abbr name, remove leading misc chars (bullets etc.),
          -- and cap field to 15 chars
          local abbr = item.label
          abbr = abbr:gsub('%b()', ''):gsub('%b{}', '')
          abbr = abbr:match '[%w_.]+.*' or abbr
          abbr = #abbr > 15 and abbr:sub(1, 14) .. '…' or abbr

          -- Cap return value field to 15 chars
          local menu = item.detail or ''
          menu = #menu > 15 and menu:sub(1, 14) .. '…' or menu

          return { abbr = abbr, menu = menu }
        end,
      })
    end
  end,
})

local min_chars = 2

vim.api.nvim_create_autocmd('CmdlineChanged', {
  pattern = { ':', '/', '?' },
  callback = function()
    local line = vim.fn.getcmdline()

    if #line >= min_chars then
      vim.fn.wildtrigger()
    end
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
