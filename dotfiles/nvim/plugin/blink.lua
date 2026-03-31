vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name ~= 'blink.cmp' then
      return
    end

    if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then
      return
    end

    vim.system({ 'cargo', 'build', '--release' }, { cwd = ev.data.path }, function(res)
      if res.code ~= 0 then
        vim.schedule(function()
          vim.notify('blink.cmp build failed:\n' .. ((res.stderr and res.stderr ~= '') and res.stderr or (res.stdout or '')), vim.log.levels.ERROR)
        end)
      end
    end)
  end,
})

vim.pack.add {
  { src = 'https://github.com/saghen/blink.cmp' },
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
  { src = 'https://github.com/saghen/blink.compat', version = vim.version.range '1.0' },
  { src = 'https://github.com/kristijanhusak/vim-dadbod-completion' },
  { src = 'https://github.com/fang2hou/blink-copilot' },
}

local ok_copilot, blink_copilot = pcall(require, 'blink-copilot')
if ok_copilot and type(blink_copilot.setup) == 'function' then
  blink_copilot.setup {
    kind_name = 'copilot',
    kind_hl = true,
    debounce = 200,
  }
end

require('blink.cmp').setup {
  keymap = {
    preset = 'default',

    ['<C-p>'] = { 'select_prev', 'fallback' },
    ['<C-n>'] = { 'select_next', 'fallback' },
    ['<C-d>'] = {
      function(cmp)
        cmp.scroll_documentation_up(4)
      end,
      'fallback',
    },
    ['<C-f>'] = {
      function(cmp)
        cmp.scroll_documentation_down(4)
      end,
      'fallback',
    },
    ['<C-Space>'] = { 'show' },
    ['<C-e>'] = { 'hide' },
    ['<CR>'] = { 'accept', 'fallback' },
    ['<Tab>'] = {
      function(cmp)
        if vim.b[vim.api.nvim_get_current_buf()].nes_state then
          cmp.hide()
          return require('copilot-lsp.nes').apply_pending_nes() and require('copilot-lsp.nes').walk_cursor_end_edit()
        end

        if cmp.snippet_active() then
          return cmp.accept()
        end

        return cmp.select_and_accept()
      end,
      'snippet_forward',
      'select_next',
      'fallback',
    },
    ['<S-Tab>'] = { 'select_prev', 'fallback' },
  },

  completion = {
    list = {
      selection = {
        preselect = false,
        auto_insert = false,
      },
    },

    documentation = {
      auto_show = true,
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
            highlight = function(ctx)
              local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
              return hl
            end,
          },
          kind = {
            highlight = function(ctx)
              local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
              return hl
            end,
          },
        },
      },

      direction_priority = function()
        local ctx = require('blink.cmp').get_context()
        local item = require('blink.cmp').get_selected_item()

        if ctx == nil or item == nil then
          return { 's', 'n' }
        end

        local item_text = item.textEdit ~= nil and item.textEdit.newText or item.insertText or item.label
        local is_multi_line = item_text:find '\n' ~= nil

        if is_multi_line or vim.g.blink_cmp_upwards_ctx_id == ctx.id then
          vim.g.blink_cmp_upwards_ctx_id = ctx.id
          return { 'n', 's' }
        end

        return { 's', 'n' }
      end,
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
      cmdline = {
        min_keyword_length = function(ctx)
          if ctx.mode == 'cmdline' and string.find(ctx.line, ' ') == nil then
            return 3
          end
          return 0
        end,
      },
    },
  },

  cmdline = {
    keymap = {
      preset = 'inherit',
      ['<CR>'] = { 'accept_and_enter', 'fallback' },
      ['<ESC>'] = { 'fallback' },
    },
    completion = {
      menu = { auto_show = true },
      list = {
        selection = { preselect = false, auto_insert = true },
      },
    },
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
        selection = { preselect = false, auto_insert = false },
      },
      menu = { auto_show = nil },
      ghost_text = { enabled = false },
    },
  },

  fuzzy = { implementation = 'prefer_rust_with_warning' },
}
