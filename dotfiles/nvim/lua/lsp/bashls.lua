local shared = require 'lsp._shared'

return {
  config = shared.with_defaults {
    filetypes = { 'bash', 'sh' },
    on_attach = function(client, bufnr)
      local filename = vim.api.nvim_buf_get_name(bufnr)
      if filename:match '%.env$' or vim.fn.fnamemodify(filename, ':t') == '.env' then
        client:stop()
        return
      end

      shared.on_attach(client, bufnr)
    end,
  },
}
