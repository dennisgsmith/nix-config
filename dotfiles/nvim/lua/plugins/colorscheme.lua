local M = {
  -- {
  --   'Mofiqul/dracula.nvim',
  --   lazy = false,
  --   priority = 1001,
  --   opts = {
  --     transparent_bg = true,
  --   },
  --   config = function(_, opts)
  --     require('dracula').setup(opts)
  --   end,
  -- },
  {
    'EdenEast/nightfox.nvim',
    name = 'nightfox',
    priority = 1000,
    opts = {
      options = {
        transparent = true,
      },
    },
    config = true,
  },
  -- {
  --   'catppuccin/nvim',
  --   name = 'catppuccin',
  --   lazy = false,
  --   priority = 1000,
  --   config = true,
  -- },
  {
    'f-person/auto-dark-mode.nvim',
    dependencies = {
      'echasnovski/mini.icons',
      'petertriho/nvim-scrollbar',
      'lewis6991/gitsigns.nvim',
      'EdenEast/nightfox.nvim',
    },
    lazy = false,
    priority = 999,
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.cmd 'hi clear'
        if vim.fn.exists 'syntax_on' == 1 then
          vim.cmd 'syntax reset'
        end
        vim.o.background = 'dark'
        vim.cmd 'colorscheme terafox'
        vim.api.nvim_set_hl(0, 'WinSeparator', { fg = '#333333' })
        require('gitsigns').refresh()
        require('scrollbar').render()
        vim.cmd 'redraw!'
      end,
      set_light_mode = function()
        vim.cmd 'hi clear'
        if vim.fn.exists 'syntax_on' == 1 then
          vim.cmd 'syntax reset'
        end
        vim.o.background = 'light'
        vim.cmd 'colorscheme dayfox'
        vim.api.nvim_set_hl(0, 'WinSeparator', { fg = '#cccccc' })
        require('gitsigns').refresh()
        require('scrollbar').render()
        vim.cmd 'redraw!'
      end,
    },
  },
}

return M
