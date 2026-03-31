vim.pack.add {
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-context' },
}

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name ~= 'nvim-treesitter' then
      return
    end

    if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then
      return
    end

    vim.system({ vim.v.progpath, '--headless', '+TSUpdate', '+qa' }, { cwd = ev.data.path })
  end,
})

require('treesitter-context').setup {
  enable = true,
  multiwindow = true,
  max_lines = 1,
  min_window_height = 0,
  line_numbers = true,
  multiline_threshold = 20,
  trim_scope = 'inner',
  mode = 'cursor',
  separator = nil,
  zindex = 20,
  on_attach = nil,
}
