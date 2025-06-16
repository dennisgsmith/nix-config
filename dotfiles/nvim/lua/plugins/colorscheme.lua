local M = {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    opts = {
      background = {
        light = 'latte',
        dark = 'mocha',
      },
      transparent_background = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        treesitter = true,
        telescope = { enabled = true },
        lsp_trouble = true,
        dap = {
          enabled = true,
          enable_ui = true,
        },
        mason = true,
      },
    },
    config = function(_, opts)
      require('catppuccin').setup(opts)
    end,
  },
  {
    'f-person/auto-dark-mode.nvim',
    dependencies = {
      'nvim-lualine/lualine.nvim',
      'petertriho/nvim-scrollbar',
      'lewis6991/gitsigns.nvim',
    },
    lazy = false,
    priority = 999,
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.api.nvim_set_option_value('background', 'dark', { scope = 'global' })
        vim.cmd 'colorscheme catppuccin-mocha'
        vim.api.nvim_set_hl(0, 'WinSeparator', { fg = '#333333' })
        require('lualine').refresh()
        require('gitsigns').refresh()
        require('scrollbar').render()
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value('background', 'light', { scope = 'global' })
        vim.cmd 'colorscheme catppuccin-latte'
        vim.api.nvim_set_hl(0, 'WinSeparator', { fg = '#cccccc' })
        require('lualine').refresh()
        require('gitsigns').refresh()
        require('scrollbar').render()
      end,
    },
  },
}

return M
