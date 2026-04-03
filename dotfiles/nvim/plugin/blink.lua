local function path_exists(path)
  return path and path ~= '' and vim.uv.fs_stat(path) ~= nil
end

local function has_nix()
  return vim.fn.executable 'nix' == 1
end

local function load_runtime_plugin(path)
  if not path_exists(path) then
    return false
  end

  vim.opt.runtimepath:append(path)

  local after_path = vim.fs.joinpath(path, 'after')
  if path_exists(after_path) then
    vim.opt.runtimepath:append(after_path)
  end

  return true
end

local function blink_cmp_pack_spec()
  return {
    name = 'blink.cmp',
    src = 'https://github.com/saghen/blink.cmp',
    version = vim.version.range '1.0',
  }
end

local blink_cmp_nix_path = vim.env.BLINK_CMP_NIX_PATH
local use_nix_blink = has_nix() and path_exists(blink_cmp_nix_path)

local pack_specs = {
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
  { src = 'https://github.com/saghen/blink.compat', version = vim.version.range '1.0' },
  { src = 'https://github.com/kristijanhusak/vim-dadbod-completion' },
  { src = 'https://github.com/fang2hou/blink-copilot' },
}

if use_nix_blink then
  load_runtime_plugin(blink_cmp_nix_path)
else
  table.insert(pack_specs, 1, blink_cmp_pack_spec())
end

vim.pack.add(pack_specs)

local ok_copilot, blink_copilot = pcall(require, 'blink-copilot')
if ok_copilot and type(blink_copilot.setup) == 'function' then
  blink_copilot.setup {
    kind_name = 'copilot',
    kind_hl = true,
    debounce = 200,
  }
end

require('blink.cmp').setup {
  fuzzy = {
    implementation = 'prefer_rust_with_warning',
    prebuilt_binaries = {
      download = vim.fn.executable 'nix' == 0,
    },
  },
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
}
