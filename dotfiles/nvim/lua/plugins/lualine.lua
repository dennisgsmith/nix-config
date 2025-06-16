return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'echasnovski/mini.icons' },
  opts = {
    options = {
      theme = 'catppuccin',
      globalstatus = true,
    },
    extensions = { 'lazy', 'fugitive' },
    sections = {
      lualine_c = { { 'filename', path = 1 } },
    },
  },
  config = function(_, opts)
    require('lualine').setup(opts)
  end,
  event = 'VimEnter',
  lazy = false,
  priority = 1001,
}
