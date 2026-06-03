vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

vim.o.modeline = false

-- Enable mouse mode
vim.o.mouse = 'a'

vim.opt.showtabline = 0

-- Sync clipboard between OS and Neovim.
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true
vim.o.undodir = vim.fn.expand '~/.local/share/nvim/undodir'

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

vim.o.termguicolors = true

-- cursor shapes
vim.o.guicursor = 'n-v-c-sm:block,' .. 'i-ci-ve:ver25,' .. 'r-cr-o:hor20,' .. 't:ver25,' .. 'a:blinkon0'

-- Autocomplete
vim.o.autocomplete = true
vim.opt.complete:append 'o'
vim.opt.completeopt = { 'fuzzy', 'menuone', 'noselect' }
vim.o.pumheight = 7
vim.o.pumborder = 'rounded'

vim.opt.wildmenu = true
vim.opt.wildmode = { 'noselect:lastused', 'full' }
vim.opt.wildoptions = { 'pum' }

-- Window split direction
vim.cmd.set 'splitbelow'
vim.cmd.set 'splitright'

-- rounded borders on hover windows
vim.o.winborder = 'rounded'

vim.lsp.handlers['textDocument/hover'] = vim.lsp.buf.hover {
  border = 'rounded',
}

vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.buf.signature_help {
  border = 'rounded',
}
