vim.pack.add {
  { src = 'https://github.com/echasnovski/mini.icons' },
}

local MiniIcons = require 'mini.icons'

MiniIcons.setup {
  lsp = {
    copilot = { glyph = ' ', hl = 'MiniIconsOrange' },
  },
}

MiniIcons.mock_nvim_web_devicons()
