local shared = require 'lsp._shared'

return {
  mason = false,
  config = shared.with_defaults {
    cmd = {
      'postgrestools',
      'lsp-proxy',
    },
    filetypes = { 'sql' },
    root_markers = { 'postgrestools.jsonc' },
    on_init = function(client, _)
      local filename = vim.api.nvim_buf_get_name(0)
      if not filename:match '%.sql$' then
        client:stop()
      end
    end,
  },
}
