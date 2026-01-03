return {
  'saghen/blink.cmp',
  build = 'cargo build --release',

  dependencies = {
    'rafamadriz/friendly-snippets',
    { 'saghen/blink.compat', version = '1.*' },
    'zbirenbaum/copilot-cmp',
    'kristijanhusak/vim-dadbod-completion',
    'fang2hou/blink-copilot',
  },

  opts = function()
    local has_words_before = function()
      if vim.api.nvim_buf_get_option(0, 'buftype') == 'prompt' then
        return false
      end
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      if col == 0 then
        return false
      end
      local text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1] or ''
      return text:sub(col, col):match '%s' == nil
    end

    return {
      completion = {
        list = { selection = { preselect = false, auto_insert = true } },
        documentation = {
          auto_show = false,
          window = {
            border = 'rounded',
            winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpDocCursorLine,Search:None',
          },
        },
        ghost_text = { enabled = true },

        menu = {
          auto_show = true,
          border = 'rounded',
          winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpMenuSelection,Search:None',
          draw = {
            components = {
              kind_icon = {
                text = function(ctx)
                  local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
                  return kind_icon
                end,
                -- (optional) use highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                  return hl
                end,
              },
              kind = {
                -- (optional) use highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                  return hl
                end,
              },
            },
          },
        },
      },

      sources = {
        default = { 'copilot', 'lsp', 'path', 'snippets', 'buffer' },

        per_filetype = {
          sql = { 'snippets', 'dadbod', 'buffer' },
        },

        providers = {
          copilot = {
            name = 'copilot',
            module = 'blink-copilot',
            score_offset = 100,
            async = true,
          },
          dadbod = {
            name = 'Dadbod',
            module = 'vim_dadbod_completion.blink',
            score_offset = 0,
          },
        },
      },

      cmdline = {
        keymap = { preset = 'inherit' },
        completion = { menu = { auto_show = true } },
      },

      term = {
        enabled = false,
        keymap = { preset = 'inherit' },
        sources = {},
        completion = {
          trigger = {
            show_on_blocked_trigger_characters = {},
            show_on_x_blocked_trigger_characters = nil,
          },
          list = {
            selection = { preselect = nil, auto_insert = nil },
          },
          menu = { auto_show = nil },
          ghost_text = { enabled = nil },
        },
      },

      fuzzy = { implementation = 'prefer_rust_with_warning' },
    }
  end,

  opts_extend = { 'sources.default' },

  config = function(_, opts)
    require('blink.cmp').setup(opts)
  end,
}
