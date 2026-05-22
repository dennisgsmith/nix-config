local shared = require 'lsp._shared'

return {
  config = shared.with_defaults {
    cmd = function(dispatchers, config)
      return vim.lsp.rpc.start(
        {
          'csharp-ls',
          '--features',
          'metadata-uris',
        },
        dispatchers,
        {
          cwd = config.cmd_cwd or config.root_dir,
          env = config.cmd_env,
          detached = config.detached,
        }
      )
    end,

    filetypes = {
      'cs',
    },

    root_markers = {
      '*.sln',
      '*.csproj',
      '.git',
    },

    init_options = {
      AutomaticWorkspaceInit = true,
    },

    settings = {
      csharp = {
        format = {
          enable = true,
        },

        completion = {
          addUsingStatements = true,
        },

        inlayHints = {
          enableInlayHintsForImplicitObjectCreation = true,
          enableInlayHintsForImplicitVariableTypes = true,
          enableInlayHintsForLambdaParameterTypes = true,
          enableInlayHintsForTypes = true,
        },
      },
    },

    flags = {
      debounce_text_changes = 150,
    },

    on_attach = function(client, bufnr)
      -- use treesitter highlighting
      client.server_capabilities.semanticTokensProvider = nil

      -- metadata / decompilation support
      require('csharpls_extended').buf_read_cmd_bind()

      if shared.on_attach then
        shared.on_attach(client, bufnr)
      end
    end,
  },
}
