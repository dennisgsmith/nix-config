local M = {
  'nvim-telescope/telescope.nvim',
  event = 'BufReadPre',
  lazy = false,
  priority = 2000,
  dependencies = {
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    {
      'nvim-telescope/telescope-live-grep-args.nvim',
      version = '^1.0.0',
    },
    { 'nvim-telescope/telescope-file-browser.nvim' },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-lua/plenary.nvim' },
  },
  opts = function()
    local select_dir_for_grep = function(prompt_bufnr)
      local action_state = require 'telescope.actions.state'
      local fb = require('telescope').extensions.file_browser
      local lga = require('telescope').extensions.live_grep_args
      local current_line = action_state.get_current_line()

      fb.file_browser {
        files = false,
        depth = false,
        attach_mappings = function(prompt_bufnr)
          require('telescope.actions').select_default:replace(function()
            local entry_path = action_state.get_selected_entry().Path
            local dir = entry_path:is_dir() and entry_path or entry_path:parent()
            local relative = dir:make_relative(vim.fn.getcwd())
            local absolute = dir:absolute()

            lga.live_grep_args {
              results_title = relative .. '/',
              cwd = absolute,
              default_text = current_line,
            }
          end)

          return true
        end,
      }
    end
    local lga_actions = require 'telescope-live-grep-args.actions'
    local fb_actions = require 'telescope._extensions.file_browser.actions'
    return {
      defaults = {
        file_ignore_patterns = { 'node%_modules/.*', 'go/pkg/mod/*', '.DS_Store' },
        layout_stategy = 'vertical',
        layout_config = { width = 0.95 },
        sorting_strategy = 'ascending',
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--no-ignore-vcs',
          '--hidden',
          '--glob',
          '!**/.git/*',
          '--glob',
          '!**/node_modules/*',
          '--glob',
          '!**/vendor/*',
          '--glob',
          '!**/.direnv/*',
          '--glob',
          '!**/build/*',
          '--glob',
          '!**/dist/*',
          '--glob',
          '!**/.next/*',
        },
        mappings = {
          i = {
            ['<M-p>'] = require('telescope.actions').cycle_history_prev,
            ['<M-n>'] = require('telescope.actions').cycle_history_next,
          },
          n = {
            ['<M-k>'] = require('telescope.actions').cycle_history_prev,
            ['<M-j>'] = require('telescope.actions').cycle_history_next,
          },
        },
        history = {
          limit = 100,
        },
      },
      extensions = {
        live_grep_args = {
          auto_quoting = true,
          mappings = {
            i = {
              ['<C-8>'] = lga_actions.quote_prompt(),
              ['<C-i>'] = lga_actions.quote_prompt { postfix = ' --iglob ' },
            },
          },
        },
        file_browser = {
          initial_mode = 'normal',
          no_ignore = true,
          cwd_to_path = false,
          grouped = true,
          files = true,
          add_dirs = true,
          depth = 1,
          auto_depth = false,
          select_buffer = false,
          hidden = { file_browser = true, folder_browser = true },
          hide_parent_dir = false,
          collapse_dirs = false,
          prompt_path = false,
          quiet = false,
          dir_icon = '',
          dir_icon_hl = 'Default',
          display_stat = { date = true, size = true, mode = true },
          hijack_netrw = false,
          use_fd = true,
          respect_gitignore = false,
          git_status = true,
          mappings = {
            i = {
              ['<A-c>'] = fb_actions.create,
              ['<S-CR>'] = fb_actions.create_from_prompt,
              ['<A-r>'] = fb_actions.rename,
              ['<A-m>'] = fb_actions.move,
              ['<A-y>'] = fb_actions.copy,
              ['<A-d>'] = fb_actions.remove,
              ['<C-o>'] = fb_actions.open,
              ['<C-g>'] = fb_actions.goto_parent_dir,
              ['<C-e>'] = fb_actions.goto_home_dir,
              ['<C-w>'] = fb_actions.goto_cwd,
              ['<C-t>'] = fb_actions.change_cwd,
              ['<C-h>'] = fb_actions.toggle_hidden,
              ['<C-s>'] = fb_actions.toggle_all,
              ['<bs>'] = fb_actions.backspace,
              ['<C-f>'] = select_dir_for_grep,
            },
            n = {
              ['c'] = fb_actions.create,
              ['r'] = fb_actions.rename,
              ['m'] = fb_actions.move,
              ['y'] = fb_actions.copy,
              ['d'] = fb_actions.remove,
              ['o'] = fb_actions.open,
              ['-'] = fb_actions.goto_parent_dir,
              ['e'] = fb_actions.goto_home_dir,
              ['w'] = fb_actions.goto_cwd,
              ['t'] = fb_actions.change_cwd,
              ['h'] = fb_actions.toggle_hidden,
              ['s'] = fb_actions.toggle_all,
              ['f'] = select_dir_for_grep,
            },
          },
        },
      },
    }
  end,
  config = function(_, opts)
    local telescope = require 'telescope'
    telescope.setup(opts)
    telescope.load_extension 'ui-select'
    telescope.load_extension 'live_grep_args'
    telescope.load_extension 'file_browser'
    telescope.load_extension 'fzf'
  end,
}

return M
