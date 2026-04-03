local function path_exists(path)
  return path and path ~= '' and vim.uv.fs_stat(path) ~= nil
end

local function has_nix()
  return vim.fn.executable 'nix' == 1
end

local treesitter_nix_path = vim.env.NVIM_TREESITTER_NIX_PATH
local treesitter_context_nix_path = vim.env.TREESITTER_CONTEXT_NIX_PATH

local use_nix_treesitter = has_nix() and path_exists(treesitter_nix_path)
local use_nix_treesitter_context = has_nix() and path_exists(treesitter_context_nix_path)

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
