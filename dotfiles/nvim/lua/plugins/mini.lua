return {
  {
    'echasnovski/mini.icons',
    version = '*',
    config = function(_, opts)
      local MiniIcons = require 'mini.icons'
      MiniIcons.setup(opts)
      MiniIcons.mock_nvim_web_devicons()
    end,
  },
  {
    'echasnovski/mini.files',
    version = '*',
    opts = {
      content = {
        filter = nil,
        prefix = nil,
        sort = nil,
      },

      mappings = {
        close = '<Esc><Esc>',
        go_in = 'l',
        go_in_plus = 'L',
        go_out = 'h',
        go_out_plus = 'H',
        mark_goto = "'",
        mark_set = 'm',
        reset = '<BS>',
        reveal_cwd = '@',
        show_help = 'g?',
        synchronize = '=',
        trim_left = '<',
        trim_right = '>',
      },

      options = {
        permanent_delete = false,
        use_as_default_explorer = true,
      },

      windows = {
        max_number = math.huge,
        preview = true,
        width_focus = 35,
        width_nofocus = 15,
        width_preview = 100,
      },
    },
  },
  {
    'echasnovski/mini.diff',
    config = function()
      local diff = require 'mini.diff'
      diff.setup {
        -- Disabled by default
        source = diff.gen_source.none(),
      }
    end,
  },
}
