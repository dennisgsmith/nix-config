return {
  {
    'olimorris/codecompanion.nvim',
    version = '17.33.0',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'echasnovski/mini.diff',
      'HakonHarnes/img-clip.nvim',
      { 'ravitemer/codecompanion-history.nvim', commit = 'eb99d256352144cf3b6a1c45608ec25544a0813d' },
    },
    opts = {
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
            -- Keymap to open history from chat buffer (default: gh)
            keymap = 'gh',
            -- Keymap to save the current chat manually (when auto_save is disabled)
            save_chat_keymap = 'sc',
            -- Save all chats by default (disable to save only manually using 'sc')
            auto_save = true,
            -- Number of days after which chats are automatically deleted (0 to disable)
            expiration_days = 0,
            -- Picker interface ("telescope" or "snacks" or "fzf-lua" or "default")
            picker = 'telescope',
            ---Automatically generate titles for new chats
            auto_generate_title = true,
            title_generation_opts = {
              ---Adapter for generating titles (defaults to active chat's adapter)
              adapter = nil, -- e.g "copilot"
              ---Model for generating titles (defaults to active chat's model)
              model = nil, -- e.g "gpt-4o"
            },
            ---On exiting and entering neovim, loads the last chat on opening chat
            continue_last_chat = false,
            ---When chat is cleared with `gx` delete the chat from history
            delete_on_clearing_chat = false,
            ---Directory path to save the chats
            dir_to_save = vim.fn.stdpath 'data' .. '/codecompanion-history',
            ---Enable detailed logging for history extension
            enable_logging = false,
          },
        },
      },
    },
  },
  {
    'zbirenbaum/copilot.lua',
    dependencies = {
      {
        'copilotlsp-nvim/copilot-lsp',
        init = function()
          vim.g.copilot_nes_debounce = 500
        end,
      },
    },
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
      --   panel = {
      --     enabled = false,
      --     auto_refresh = false,
      --     keymap = {
      --       jump_prev = '[[',
      --       jump_next = ']]',
      --       accept = '<CR>',
      --       refresh = 'gr',
      --       open = '<M-CR>',
      --     },
      --     layout = {
      --       position = 'bottom', -- | top | left | right | horizontal | vertical
      --       ratio = 0.4,
      --     },
      --   },
      --   suggestion = {
      --     enabled = false,
      --     auto_trigger = true,
      --     hide_during_completion = true,
      --     debounce = 75,
      --     keymap = {
      --       accept = '<M-l>',
      --       accept_word = false,
      --       accept_line = false,
      --       next = '<M-]>',
      --       prev = '<M-[>',
      --       dismiss = '<C-]>',
      --     },
      --   },
      --   filetypes = {
      --     yaml = false,
      --     markdown = false,
      --     help = false,
      --     gitcommit = false,
      --     gitrebase = false,
      --     hgcommit = false,
      --     svn = false,
      --     cvs = false,
      --     ['.'] = false,
      --   },
      --   copilot_node_command = 'node', -- Node.js version must be > 18.x
      --   server_opts_overrides = {},
      --   nes = {
      --     enabled = false,
      --     keymap = {
      --       accept_and_goto = '<leader>p',
      --       accept = false,
      --       dismiss = '<Esc>',
      --     },
      --   },
    },
    config = function(_, opts)
      require('copilot').setup(opts)
    end,
  },
}
