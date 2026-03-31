vim.pack.add {
  { src = 'https://github.com/nvim-telescope/telescope.nvim' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/nvim-telescope/telescope-live-grep-args.nvim', version = vim.version.range '1.0' },
  { src = 'https://github.com/nvim-telescope/telescope-file-browser.nvim' },
  { src = 'https://github.com/nvim-telescope/telescope-ui-select.nvim' },
}

-- optional native fzf build
if vim.fn.executable 'make' == 1 then
  vim.pack.add {
    { src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim' },
  }

  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      if ev.data.spec.name ~= 'telescope-fzf-native.nvim' then
        return
      end

      if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then
        return
      end

      vim.system({ 'make' }, { cwd = ev.data.path })
    end,
  })
end

local telescope = require 'telescope'

local select_dir_for_grep = function(_prompt_bufnr)
  local action_state = require 'telescope.actions.state'
  local fb = require('telescope').extensions.file_browser
  local lga = require('telescope').extensions.live_grep_args
  local current_line = action_state.get_current_line()

  fb.file_browser {
    files = false,
    depth = false,
    attach_mappings = function(_prompt_bufnr)
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

telescope.setup {
  defaults = {
    file_ignore_patterns = { 'node%_modules/.*', 'go/pkg/mod/*', '.DS_Store' },
    layout_stategy = 'vertical',
    layout_config = {
      width = 0.95,
      height = 0.95,
      preview_width = 0.55,
    },
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

telescope.load_extension 'ui-select'
telescope.load_extension 'live_grep_args'
telescope.load_extension 'file_browser'

if vim.fn.executable 'make' == 1 then
  pcall(telescope.load_extension, 'fzf')
end

local builtin = require 'telescope.builtin'
local themes = require 'telescope.themes'

vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><leader>', '<Cmd>Telescope resume<CR>')

vim.keymap.set('n', '<leader>/', function()
  builtin.current_buffer_fuzzy_find(themes.get_dropdown {
    winblend = 10,
    previewer = false,
  })
end)

vim.keymap.set('n', '<leader>gf', builtin.git_files)
vim.keymap.set('n', '<leader>sf', builtin.find_files)
vim.keymap.set('n', '<leader>sh', builtin.help_tags)
vim.keymap.set('n', '<leader>sw', builtin.grep_string)
vim.keymap.set('n', '<leader>sb', builtin.buffers)
vim.keymap.set('n', '<leader>sd', builtin.diagnostics)
vim.keymap.set('n', '<leader>sk', builtin.keymaps)

vim.keymap.set('n', '<leader>sa', function()
  require('telescope').extensions.live_grep_args.live_grep_args()
end)

vim.keymap.set('n', '<leader>sg', function()
  require('telescope').extensions.live_grep_args.live_grep_args()
end)

vim.keymap.set('n', '<leader>gs', builtin.git_status)
vim.keymap.set('n', '<leader>gh', builtin.git_stash)
vim.keymap.set('n', '<leader>gb', builtin.git_branches)
vim.keymap.set('n', '<leader>gc', builtin.git_commits)

-- LSP telescope
vim.keymap.set('n', '<leader>gd', '<cmd>Telescope lsp_definitions<cr>zz')
vim.keymap.set('n', '<leader>gr', '<cmd>Telescope lsp_references<cr>')
vim.keymap.set('n', '<leader>gi', '<cmd>Telescope lsp_implementations<cr>zz')
vim.keymap.set('n', '<leader>gt', '<cmd>Telescope lsp_type_definitions<cr>zz')
