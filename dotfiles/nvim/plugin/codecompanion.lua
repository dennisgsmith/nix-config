vim.pack.add {
  { src = 'https://github.com/olimorris/codecompanion.nvim', version = 'v17.33.0' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/echasnovski/mini.diff' },
  { src = 'https://github.com/ravitemer/codecompanion-history.nvim', version = 'eb99d256352144cf3b6a1c45608ec25544a0813d' },
  { src = 'https://github.com/HakonHarnes/img-clip.nvim' },
  { src = 'https://github.com/zbirenbaum/copilot.lua' },
  { src = 'https://github.com/copilotlsp-nvim/copilot-lsp' },
}

local codecompanion_loaded = false
local copilot_loaded = false
local img_clip_loaded = false
local copilot_ls_enabled = false

local function packadd(name)
  pcall(vim.cmd.packadd, name)
end

local function load_img_clip()
  if img_clip_loaded then
    return
  end

  packadd 'img-clip.nvim'

  require('img-clip').setup {
    filetypes = {
      codecompanion = {
        prompt_for_file_name = false,
        template = '[Image]($FILE_PATH)',
        use_absolute_path = true,
      },
    },
  }

  img_clip_loaded = true
end

local function load_copilot()
  if copilot_loaded then
    return
  end

  packadd 'copilot.lua'
  packadd 'copilot-lsp'

  vim.g.copilot_nes_debounce = 500

  require('copilot').setup {
    panel = {
      enabled = false,
      auto_refresh = false,
      keymap = {
        jump_prev = '[[',
        jump_next = ']]',
        accept = '<CR>',
        refresh = 'gr',
        open = '<M-CR>',
      },
      layout = {
        position = 'bottom',
        ratio = 0.4,
      },
    },

    suggestion = {
      enabled = false,
      auto_trigger = true,
      hide_during_completion = true,
      debounce = 75,
      keymap = {
        accept = '<M-l>',
        accept_word = false,
        accept_line = false,
        next = '<M-]>',
        prev = '<M-[>',
        dismiss = '<C-]>',
      },
    },

    filetypes = {
      yaml = false,
      markdown = false,
      help = false,
      gitcommit = false,
      gitrebase = false,
      hgcommit = false,
      svn = false,
      cvs = false,
      ['.'] = false,
    },

    copilot_node_command = 'node',

    server_opts_overrides = {
      settings = {
        telemetry = {
          telemetryLevel = 'off',
        },
      },
    },

    nes = {
      enabled = false,
      keymap = {
        accept_and_goto = '<leader>p',
        accept = false,
        dismiss = '<Esc>',
      },
    },
  }

  if not copilot_ls_enabled then
    vim.lsp.enable 'copilot_ls'
    copilot_ls_enabled = true
  end

  copilot_loaded = true
end

local function load_codecompanion()
  if codecompanion_loaded then
    return
  end

  packadd 'plenary.nvim'
  packadd 'nvim-treesitter'
  packadd 'mini.diff'
  packadd 'codecompanion.nvim'
  packadd 'codecompanion-history.nvim'

  load_copilot()
  load_img_clip()

  require('codecompanion').setup {
    interactions = {
      chat = {
        opts = {
          completion_provider = 'blink',
        },
      },
    },

    copilot = function()
      return require('codecompanion.adapters').extend('copilot', {
        schema = {
          model = {
            default = 'gpt-5-mini',
          },
        },
      })
    end,

    display = {
      chat = {
        auto_scroll = false,
      },
    },

    strategies = {
      chat = {
        adapter = 'copilot',
      },
      inline = {
        adapter = 'copilot',
      },
      cmd = {
        adapter = 'copilot',
      },
    },

    extensions = {
      history = {
        enabled = true,
        opts = {
          keymap = 'gh',
          save_chat_keymap = 'sc',
          auto_save = true,
          expiration_days = 0,
          picker = 'telescope',
          auto_generate_title = true,
          title_generation_opts = {
            adapter = nil,
            model = nil,
          },
          continue_last_chat = false,
          delete_on_clearing_chat = false,
          dir_to_save = vim.fn.stdpath 'data' .. '/codecompanion-history',
          enable_logging = false,
        },
      },
    },
  }

  codecompanion_loaded = true
end

local function codecompanion_cmd(cmd)
  return function()
    load_codecompanion()
    vim.cmd(cmd)
  end
end

vim.keymap.set('n', '<leader>ai', codecompanion_cmd 'CodeCompanionChat Toggle', {
  desc = 'CodeCompanionChat Toggle',
})

vim.keymap.set('n', '<tab>', function()
  load_copilot()

  local bufnr = vim.api.nvim_get_current_buf()
  local state = vim.b[bufnr].nes_state

  if state then
    local nes = require 'copilot-lsp.nes'
    local _ = nes.walk_cursor_start_edit() or (nes.apply_pending_nes() and nes.walk_cursor_end_edit())
    return nil
  end

  return '<C-i>'
end, { desc = 'Accept Copilot NES suggestion', expr = true })

vim.api.nvim_create_user_command('CodeCompanion', function(opts)
  load_codecompanion()
  vim.cmd('CodeCompanion ' .. opts.args)
end, {
  nargs = '*',
  complete = function(_, line)
    load_codecompanion()

    local input = line:match '^%S+%s+(.*)$' or ''
    local ok, items = pcall(vim.fn.getcompletion, 'CodeCompanion ' .. input, 'cmdline')

    if ok then
      return items
    end

    return {}
  end,
})

vim.api.nvim_create_user_command('CodeCompanionChat', function(opts)
  load_codecompanion()
  vim.cmd('CodeCompanionChat ' .. opts.args)
end, {
  nargs = '*',
  complete = function(_, line)
    load_codecompanion()

    local input = line:match '^%S+%s+(.*)$' or ''
    local ok, items = pcall(vim.fn.getcompletion, 'CodeCompanionChat ' .. input, 'cmdline')

    if ok then
      return items
    end

    return {}
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'codecompanion',
  callback = function()
    load_img_clip()
  end,
})
