-- Default
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Undotree
vim.keymap.set('n', '<leader><F5>', vim.cmd.UndotreeToggle)

-- Word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- vim.api.nvim_create_user_command('Explore', 'Telescope file_browser path=%:p:h select_buffer=true', {})
-- vim.api.nvim_create_user_command('E', 'Telescope file_browser path=%:p:h select_buffer=true', {})

local function minifile_open_cwd()
  local minifiles = require 'mini.files'
  minifiles.open(vim.api.nvim_buf_get_name(0))
  minifiles.reveal_cwd()
end

vim.api.nvim_create_user_command('Explore', minifile_open_cwd, {})
vim.api.nvim_create_user_command('E', minifile_open_cwd, {})

vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><leader>', '<Cmd>Telescope resume<CR>', { desc = 'Open most recent picker with last selection' })
vim.keymap.set('n', '<leader>/', function()
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sb', require('telescope.builtin').buffers, { desc = '[S]earch open [B]uffers' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sk', require('telescope.builtin').keymaps, { desc = '[K]eymaps' })
vim.keymap.set('n', '<leader>sa', require('telescope').extensions.live_grep_args.live_grep_args, { desc = '[S]earch [P]roject' })
vim.keymap.set('n', '<leader>sg', require('telescope').extensions.live_grep_args.live_grep_args, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>gs', require('telescope.builtin').git_status, { desc = '[G]it [S]tatus' })
vim.keymap.set('n', '<leader>gh', require('telescope.builtin').git_stash, { desc = '[G]it Stas[h]' })
vim.keymap.set('n', '<leader>gb', require('telescope.builtin').git_branches, { desc = '[G]it [B]ranches' })
vim.keymap.set('n', '<leader>gc', require('telescope.builtin').git_commits, { desc = '[G]it [C]ommits' })

-- Telescope / LSP
local bufopts = { noremap = true }
vim.keymap.set('n', '<leader>gD', vim.lsp.buf.declaration, bufopts)
vim.keymap.set('n', '<leader>gd', '<cmd>Telescope lsp_definitions<cr>zz', bufopts)
vim.keymap.set('n', '<leader>gr', '<cmd>Telescope lsp_references<cr>', bufopts)
vim.keymap.set('n', '<leader>gi', '<cmd>Telescope lsp_implementations<cr>zz', bufopts)
vim.keymap.set('n', '<leader>gt', '<cmd>Telescope lsp_type_definitions<cr>zz', bufopts)
vim.keymap.set('n', '<leader>K', vim.lsp.buf.hover, bufopts)
vim.keymap.set('n', '<leader>kh', vim.lsp.buf.signature_help, bufopts)
vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
vim.keymap.set('n', '<leader>wl', function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, bufopts)
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)

-- Diagnostic
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

local n_opts = { silent = true, noremap = true }
local t_opts = { silent = true }

-- Terminal mode
vim.keymap.set('t', '<esc>', '<C-\\><C-N>', t_opts)
vim.keymap.set('t', '<C-w>h', '<C-\\><C-N><C-w>h', t_opts)
vim.keymap.set('t', '<C-w>j', '<C-\\><C-N><C-w>j', t_opts)
vim.keymap.set('t', '<C-w>k', '<C-\\><C-N><C-w>k', t_opts)
vim.keymap.set('t', '<C-w>l', '<C-\\><C-N><C-w>l', t_opts)

vim.keymap.set('n', '<C-d>', '<C-d>zz', n_opts)
vim.keymap.set('n', '<C-u>', '<C-u>zz', n_opts)
vim.keymap.set('n', 'n', 'nzzzv', n_opts)
vim.keymap.set('n', 'N', 'Nzzzv', n_opts)
