vim.pack.add {
  { src = 'https://github.com/EdenEast/nightfox.nvim', name = 'nightfox' },
  { src = 'https://github.com/f-person/auto-dark-mode.nvim' },
  { src = 'https://github.com/echasnovski/mini.icons' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
}

require('nightfox').setup {
  transparent = true,
}

local function apply_theme(name, background, separator)
  vim.cmd 'hi clear'

  if vim.fn.exists 'syntax_on' == 1 then
    vim.cmd 'syntax reset'
  end

  vim.o.background = background
  vim.cmd.colorscheme(name)

  vim.api.nvim_set_hl(0, 'WinSeparator', { fg = separator })
  vim.api.nvim_set_hl(0, 'Pmenu', { bg = 'NONE' })
  vim.api.nvim_set_hl(0, '@lsp.type.comment', { fg = 'NONE' })

  require('gitsigns').refresh()
  vim.cmd 'redraw!'
end

require('auto-dark-mode').setup {
  update_interval = 1000,

  set_dark_mode = function()
    apply_theme('terafox', 'dark', '#333333')
  end,

  set_light_mode = function()
    apply_theme('dayfox', 'light', '#cccccc')
  end,
}
