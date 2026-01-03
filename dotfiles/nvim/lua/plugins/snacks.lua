local M = {
  'folke/snacks.nvim',
  lazy = false,
  priority = 1000,
  ---@type snacks.Config
  opts = {
    image = {
      enabled = true,
      resolve = function(path, src)
        local ok, obsidian = pcall(require, 'obsidian.api')
        if not ok then
          return nil
        end
        if obsidian.path_is_note(path) then
          return obsidian.resolve_image_path(src)
        end
        return nil
      end,
    },

    animate = { enabled = false },
    bigfile = { enabled = false },
    bufdelete = { enabled = false },
    dashboard = { enabled = false },
    debug = { enabled = false },
    dim = { enabled = false },
    explorer = { enabled = false },
    gh = { enabled = false },
    git = { enabled = false },
    gitbrowse = { enabled = false },
    indent = { enabled = false },
    input = { enabled = false },
    keymap = { enabled = false },
    layout = { enabled = false },
    lazygit = { enabled = false },
    notifier = { enabled = false },
    notify = { enabled = false },
    picker = { enabled = false },
    profiler = { enabled = false },
    quickfile = { enabled = false },
    rename = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    terminal = { enabled = false },
    toggle = { enabled = false },
    util = { enabled = false },
    win = { enabled = false },
    words = { enabled = false },
    zen = { enabled = false },
  },

  config = function(_, opts)
    vim.env.PUPPETEER_EXECUTABLE_PATH = os.getenv 'PUPPETEER_EXECUTABLE_PATH'
    require('snacks').setup(opts)
    vim.api.nvim_create_autocmd({ 'BufWinLeave', 'BufLeave' }, {
      pattern = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp', '*.bmp', '*.tiff', '*.heic', '*.avif' },
      callback = function(args)
        vim.bo[args.buf].bufhidden = 'wipe'
        vim.bo[args.buf].swapfile = false
        vim.bo[args.buf].undofile = false
      end,
    })
  end,
}

return M
