local shared = require 'lsp._shared'

return {
  config = shared.with_defaults {
    settings = {
      yaml = {
        schemaStore = {
          enable = true,
          url = 'https://www.schemastore.org/api/json/catalog.json',
        },
        schemas = {},
      },
    },
    on_init = function(client, _)
      local bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, math.min(20, vim.api.nvim_buf_line_count(bufnr)), false)

      local openapi_version
      for _, line in ipairs(lines) do
        local v = line:match '^openapi:%s*([%d%.]+)'
        if v then
          openapi_version = v
          break
        end
      end

      if not openapi_version then
        return
      end

      local major = openapi_version:match '^(%d+)'
      local schema_url

      if major == '3' then
        if openapi_version:find '^3%.0' then
          schema_url = 'https://spec.openapis.org/oas/3.0/schema/2021-09-28'
        elseif openapi_version:find '^3%.1' then
          schema_url = 'https://spec.openapis.org/oas/3.1/schema/2022-10-07'
        end
      end

      if schema_url then
        client.config.settings.yaml.schemas[schema_url] = {
          'openapi.yaml',
          'openapi.yml',
          'openapi.json',
        }

        client:notify('workspace/didChangeConfiguration', {
          settings = client.config.settings,
        })
      end
    end,
  },
}
