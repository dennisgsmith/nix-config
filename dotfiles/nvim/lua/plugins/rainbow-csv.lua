return {
  'mechatroner/rainbow_csv',
  init = function()
    local rainbow_csv_filetypes = {
      'csv',
      'tsv',
      'csv_semicolon',
      'csv_whitespace',
      'csv_pipe',
      'rfc_csv',
      'rfc_semicolon',
    }
    for _, ft in ipairs(rainbow_csv_filetypes) do
      vim.api.nvim_create_autocmd('FileType', {
        pattern = ft,
        callback = function()
          vim.cmd 'TSDisable highlight'
        end,
      })
    end
    vim.cmd 'let g:rbql_with_headers = 1'
  end,
}
