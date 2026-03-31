vim.pack.add {
  { src = 'https://github.com/obsidian-nvim/obsidian.nvim' },
  { src = 'https://github.com/saghen/blink.cmp' },
  { src = 'https://github.com/nvim-telescope/telescope.nvim' },
  { src = 'https://github.com/folke/snacks.nvim' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim' },
}

local obsidian_loaded = false
local render_markdown_loaded = false

local vault_path = vim.fn.expand '~' .. '/vault'

local function packadd(name)
  pcall(vim.cmd.packadd, name)
end

local function is_vault_markdown(bufnr)
  if vim.bo[bufnr].filetype ~= 'markdown' then
    return false
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == '' then
    return false
  end

  local normalized_name = vim.fs.normalize(name)
  local normalized_vault = vim.fs.normalize(vault_path)

  return normalized_name:sub(1, #normalized_vault) == normalized_vault
end

local function load_render_markdown()
  if render_markdown_loaded then
    return
  end

  packadd 'nvim-treesitter'
  packadd 'render-markdown.nvim'

  require('render-markdown').setup {}

  render_markdown_loaded = true
end

local function load_obsidian()
  if obsidian_loaded then
    return
  end

  packadd 'blink.cmp'
  packadd 'telescope.nvim'
  packadd 'snacks.nvim'
  packadd 'nvim-treesitter'
  packadd 'obsidian.nvim'

  require('obsidian').setup {
    legacy_commands = false,
    workspaces = {
      {
        name = 'vault',
        path = vault_path,
      },
    },
    attachments = {
      folder = '/assets',
    },
  }

  obsidian_loaded = true
end

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  pattern = '*.md',
  callback = function(args)
    if is_vault_markdown(args.buf) then
      load_obsidian()
    end
    load_render_markdown()
  end,
})

vim.api.nvim_create_user_command('Obsidian', function(opts)
  load_obsidian()
  vim.cmd('Obsidian ' .. opts.args)
end, {
  nargs = '*',
  complete = function(_, line)
    load_obsidian()

    local input = line:match '^%S+%s+(.*)$' or ''
    local ok, items = pcall(vim.fn.getcompletion, 'Obsidian ' .. input, 'cmdline')

    if ok then
      return items
    end

    return {}
  end,
})
