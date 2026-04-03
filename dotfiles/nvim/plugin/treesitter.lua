local function path_exists(path)
  return path and path ~= '' and vim.uv.fs_stat(path) ~= nil
end

local function has_nix()
  return vim.fn.executable 'nix' == 1
end

local treesitter_nix_path = vim.env.NVIM_TREESITTER_NIX_PATH
local treesitter_context_nix_path = vim.env.TREESITTER_CONTEXT_NIX_PATH
local treesitter_textobjects_nix_path = vim.env.TREESITTER_TEXTOBJECTS_NIX_PATH

local use_nix_treesitter = has_nix() and path_exists(treesitter_nix_path)
local use_nix_treesitter_context = has_nix() and path_exists(treesitter_context_nix_path)
local use_nix_treesitter_textobjects = has_nix() and path_exists(treesitter_textobjects_nix_path)

local pack_specs = {}

if use_nix_treesitter then
  vim.opt.runtimepath:append(treesitter_nix_path)
else
  table.insert(pack_specs, {
    name = 'nvim-treesitter',
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
  })
end

if use_nix_treesitter_context then
  vim.opt.runtimepath:append(treesitter_context_nix_path)
else
  table.insert(pack_specs, {
    name = 'nvim-treesitter-context',
    src = 'https://github.com/nvim-treesitter/nvim-treesitter-context',
  })
end

if use_nix_treesitter_textobjects then
  vim.opt.runtimepath:append(treesitter_textobjects_nix_path)
else
  table.insert(pack_specs, {
    name = 'nvim-treesitter-textobjects',
    src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
    version = 'main',
  })
end

if #pack_specs > 0 then
  vim.pack.add(pack_specs)
end

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name ~= 'nvim-treesitter' then
      return
    end

    if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then
      return
    end

    vim.system({ vim.v.progpath, '--headless', '+TSUpdate', '+qa' }, { cwd = ev.data.path })
  end,
})

require('nvim-treesitter').setup {
  install_dir = vim.fn.stdpath 'data' .. '/site',
}

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'FileType' }, {
  callback = function(args)
    local b = args.buf
    if not vim.api.nvim_buf_is_valid(b) then
      return
    end

    local name = vim.api.nvim_buf_get_name(b)
    if name ~= '' then
      local ok, st = pcall(vim.loop.fs_stat, name)
      if ok and st and st.size > 1024 * 1024 then
        return
      end
    end

    vim.bo[b].syntax = 'off'
    pcall(vim.treesitter.start, b)
  end,
})

require('treesitter-context').setup {
  enable = true,
  multiwindow = true,
  max_lines = 1,
  min_window_height = 0,
  line_numbers = true,
  multiline_threshold = 20,
  trim_scope = 'inner',
  mode = 'cursor',
  separator = nil,
  zindex = 20,
  on_attach = nil,
}

require('nvim-treesitter-textobjects').setup {
  select = {
    lookahead = true,
    selection_modes = {
      ['@parameter.outer'] = 'v', -- charwise
      ['@function.outer'] = 'V', -- linewise
      ['@class.outer'] = '<c-v>', -- blockwise
    },
  },
  move = {
    set_jumps = true,
  },
}

vim.keymap.set({ 'x', 'o' }, 'af', function()
  require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'x', 'o' }, 'if', function()
  require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
end)
vim.keymap.set({ 'x', 'o' }, 'ac', function()
  require('nvim-treesitter-textobjects.select').select_textobject('@class.outer', 'textobjects')
end)
vim.keymap.set({ 'x', 'o' }, 'ic', function()
  require('nvim-treesitter-textobjects.select').select_textobject('@class.inner', 'textobjects')
end)
vim.keymap.set({ 'x', 'o' }, 'as', function()
  require('nvim-treesitter-textobjects.select').select_textobject('@local.scope', 'locals')
end)

vim.keymap.set('n', '<leader>a', function()
  require('nvim-treesitter-textobjects.swap').swap_next '@parameter.inner'
end)
vim.keymap.set('n', '<leader>A', function()
  require('nvim-treesitter-textobjects.swap').swap_next '@parameter.outer'
end)

vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
  require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, ']]', function()
  require('nvim-treesitter-textobjects.move').goto_next_start('@class.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, ']o', function()
  require('nvim-treesitter-textobjects.move').goto_next_start({ '@loop.inner', '@loop.outer' }, 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, ']s', function()
  require('nvim-treesitter-textobjects.move').goto_next_start('@local.scope', 'locals')
end)
vim.keymap.set({ 'n', 'x', 'o' }, ']z', function()
  require('nvim-treesitter-textobjects.move').goto_next_start('@fold', 'folds')
end)
vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
  require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '][', function()
  require('nvim-treesitter-textobjects.move').goto_next_end('@class.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
  require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '[[', function()
  require('nvim-treesitter-textobjects.move').goto_previous_start('@class.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
  require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '[]', function()
  require('nvim-treesitter-textobjects.move').goto_previous_end('@class.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, ']d', function()
  require('nvim-treesitter-textobjects.move').goto_next('@conditional.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '[d', function()
  require('nvim-treesitter-textobjects.move').goto_previous('@conditional.outer', 'textobjects')
end)
