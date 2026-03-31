local shared = require 'lsp._shared'

return {
  config = shared.with_defaults {
    cmd = { 'zls' },
    settings = {
      zls = {
        semantic_tokens = 'partial',
      },
    },
    on_init = function(client, init_result)
      vim.g.zig_fmt_parse_errors = 0
      vim.g.zig_fmt_autosave = 0

      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = { '*.zig', '*.zon' },
        callback = function()
          vim.lsp.buf.format()
        end,
      })

      local base = shared.with_defaults()
      if base.on_init then
        base.on_init(client, init_result)
      end
    end,
  },
}
