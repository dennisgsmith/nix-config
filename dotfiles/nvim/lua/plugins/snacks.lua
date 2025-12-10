return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  ---@type snacks.Config
  opts = {
    image = {
      enabled = true,
      resolve = function(path, src)
        if require("obsidian.api").path_is_note(path) then
          return require("obsidian.api").resolve_image_path(src)
        end
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
  }
}
