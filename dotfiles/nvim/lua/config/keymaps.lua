-- Default
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- LSP
local bufopts = { noremap = true }
vim.keymap.set('n', '<leader>gD', vim.lsp.buf.declaration, bufopts)
vim.keymap.set('n', '<leader>K', vim.lsp.buf.hover, bufopts)
vim.keymap.set('n', '<leader>kh', vim.lsp.buf.signature_help, bufopts)
vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
vim.keymap.set('n', '<leader>wl', function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, bufopts)
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)

-- Diagnostics
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Clear highlight
vim.keymap.set('n', '<leader>l', '<Cmd>noh<CR>')

-- Terminal
vim.keymap.set('t', '<esc>', '<C-\\><C-N>')
vim.keymap.set('t', '<C-w>h', '<C-\\><C-N><C-w>h')
vim.keymap.set('t', '<C-w>j', '<C-\\><C-N><C-w>j')
vim.keymap.set('t', '<C-w>k', '<C-\\><C-N><C-w>k')
vim.keymap.set('t', '<C-w>l', '<C-\\><C-N><C-w>l')

-- Centering
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Toggle mouse
vim.keymap.set('n', '<leader>tm', function()
  local enable = not vim.wo.number
  vim.wo.number = enable
  vim.wo.relativenumber = enable
  vim.o.mouse = enable and 'a' or ''
end)

-- Pane movement
vim.keymap.set('n', '<M-h>', '<C-w>h')
vim.keymap.set('n', '<M-j>', '<C-w>j')
vim.keymap.set('n', '<M-k>', '<C-w>k')
vim.keymap.set('n', '<M-l>', '<C-w>l')

-- Resize
local function get_window_position()
  local function find(winid, layout)
    local t = layout[1]
    if t == 'leaf' then
      return layout[2] == winid and {} or nil
    end
    for i, child in ipairs(layout[2]) do
      local path = find(winid, child)
      if path then
        table.insert(path, 1, { type = t, index = i, total = #layout[2] })
        return path
      end
    end
    return nil
  end
  local winid = vim.api.nvim_get_current_win()
  return find(winid, vim.fn.winlayout())
end

local function is_leftmost()
  for _, node in ipairs(get_window_position() or {}) do
    if node.type == 'row' then
      return node.index == 1
    end
  end
  return false
end

local function is_rightmost()
  for _, node in ipairs(get_window_position() or {}) do
    if node.type == 'row' then
      return node.index == node.total
    end
  end
  return false
end

local function is_topmost()
  for _, node in ipairs(get_window_position() or {}) do
    if node.type == 'col' then
      return node.index == 1
    end
  end
  return false
end

local function is_bottommost()
  for _, node in ipairs(get_window_position() or {}) do
    if node.type == 'col' then
      return node.index == node.total
    end
  end
  return false
end

vim.keymap.set('n', '<M-H>', function()
  if is_leftmost() then
    vim.cmd 'vertical resize -4'
  elseif is_rightmost() then
    vim.cmd 'vertical resize +4'
  else
    vim.cmd 'vertical resize -4'
  end
end, { noremap = true, silent = true })

vim.keymap.set('n', '<M-L>', function()
  if is_rightmost() then
    vim.cmd 'vertical resize -4'
  elseif is_leftmost() then
    vim.cmd 'vertical resize +4'
  else
    vim.cmd 'vertical resize +4'
  end
end, { noremap = true, silent = true })

vim.keymap.set('n', '<M-K>', function()
  if is_topmost() then
    vim.cmd 'resize -2'
  elseif is_bottommost() then
    vim.cmd 'resize +2'
  else
    vim.cmd 'resize -2'
  end
end, { noremap = true, silent = true })

vim.keymap.set('n', '<M-J>', function()
  if is_bottommost() then
    vim.cmd 'resize -2'
  elseif is_topmost() then
    vim.cmd 'resize +2'
  else
    vim.cmd 'resize +2'
  end
end, { noremap = true, silent = true })
