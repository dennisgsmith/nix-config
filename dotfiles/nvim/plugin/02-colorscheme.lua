vim.pack.add {
  { src = 'https://github.com/EdenEast/nightfox.nvim', name = 'nightfox' },
  { src = 'https://github.com/f-person/auto-dark-mode.nvim' },
  { src = 'https://github.com/echasnovski/mini.icons' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
}

require('nightfox').setup {
  options = {
    transparent = true,
  },
}

require('auto-dark-mode').setup {
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
    vim.cmd 'redraw!'
  end,
}
