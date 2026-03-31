vim.pack.add {
  { src = 'https://github.com/echasnovski/mini.files' },
}

require('mini.files').setup {
  content = {
    filter = nil,
    prefix = nil,
    sort = nil,
  },

  mappings = {
    close = '<Esc><Esc>',
    go_in = 'l',
    go_in_plus = 'L',
    go_out = 'h',
    go_out_plus = 'H',
    mark_goto = "'",
    mark_set = 'm',
    reset = '<BS>',
    reveal_cwd = '@',
    show_help = 'g?',
    synchronize = '=',
    trim_left = '<',
    trim_right = '>',
  },

  options = {
    permanent_delete = false,
    use_as_default_explorer = true,
  },

  windows = {
    max_number = math.huge,
    preview = true,
    width_focus = 35,
    width_nofocus = 15,
    width_preview = 100,
  },
}

local function minifile_open_cwd()
  local minifiles = require 'mini.files'
  minifiles.open(vim.api.nvim_buf_get_name(0))
  minifiles.reveal_cwd()
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  callback = function(args)
    local buf_id = args.data.buf_id

    vim.keymap.set('n', '<CR>', function()
      local mini_files = require 'mini.files'
      local entry = mini_files.get_fs_entry()

      if entry ~= nil then
        if entry.fs_type == 'directory' then
          mini_files.go_in()
        else
          mini_files.go_in()
          mini_files.close()
        end
      end
    end, { buffer = buf_id, noremap = true, silent = true })
  end,
})

vim.api.nvim_create_user_command('Explore', minifile_open_cwd, {})
vim.api.nvim_create_user_command('E', minifile_open_cwd, {})
