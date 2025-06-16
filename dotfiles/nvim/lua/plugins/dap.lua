return {
  {
    'jay-babu/mason-nvim-dap.nvim',
    opts = {
      automatic_setup = true,
      handlers = {},
      ensure_installed = {
        'delve',
      },
      automatic_installation = true,
    },
  },
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'rcarriga/nvim-dap-ui',
      'leoluz/nvim-dap-go',
      'mfussenegger/nvim-dap-python',
      'mason-org/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
    },
    opts = {
      adapters = {
        api = {
          type = 'server',
          host = 'api',
          port = 2345,
        },
      },
      configurations = {
        go = {
          {
            type = 'go',
            name = 'delve container debug',
            request = 'attach',
            mode = 'remote',
            substitutepath = {
              {
                from = '',
                to = '',
              },
            },
          },
        },
      },
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '↑',
          step_over = '⏭',
          step_out = '↓',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    },
    config = function(_, opts)
      local dap = require 'dap'
      local dapui = require 'dapui'

      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
      vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Set Breakpoint' })

      -- Dap UI setup
      -- For more information, see |:help nvim-dap-ui|
      dapui.setup(opts)
      -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      require('dap-go').setup()
      require('dap-python').setup(os.getenv 'VIRTUAL_ENV')
    end,
  },
}
