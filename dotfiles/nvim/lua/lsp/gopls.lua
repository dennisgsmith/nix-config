local shared = require 'lsp._shared'

return {
  config = shared.with_defaults {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_markers = { 'go.work', 'go.mod', '.git' },
    settings = {
      gopls = {
        usePlaceholders = true,
        analyses = {
          unusedparams = true,
          any = false,
        },
        staticcheck = true,
        gofumpt = false,
      },
      analyses = {
        unusedparams = true,
      },
    },
    on_attach = function(_client, bufnr)
      local group = vim.api.nvim_create_augroup('gopls_format_' .. bufnr, { clear = true })

      vim.api.nvim_create_autocmd('BufWritePre', {
        group = group,
        buffer = bufnr,
        callback = function()
          local params = vim.lsp.util.make_range_params()
          params.context = { only = { 'source.organizeImports' } }

          local result = vim.lsp.buf_request_sync(bufnr, 'textDocument/codeAction', params, 3000)

          for cid, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
              if r.edit then
                local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or 'utf-16'
                vim.lsp.util.apply_workspace_edit(r.edit, enc)
              end
            end
          end

          vim.lsp.buf.format { bufnr = bufnr, async = false }
        end,
        desc = 'gopls organize imports and format on save',
      })
    end,
  },
}
