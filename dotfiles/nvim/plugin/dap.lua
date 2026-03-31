vim.pack.add {
  { src = 'https://github.com/jay-babu/mason-nvim-dap.nvim' },
  { src = 'https://github.com/mfussenegger/nvim-dap' },
  { src = 'https://github.com/nvim-neotest/nvim-nio' },
  { src = 'https://github.com/rcarriga/nvim-dap-ui' },
  { src = 'https://github.com/leoluz/nvim-dap-go' },
  { src = 'https://github.com/mfussenegger/nvim-dap-python' },
  { src = 'https://github.com/mason-org/mason.nvim' },
}

local dap_loaded = false

local function packadd(name)
  pcall(vim.cmd.packadd, name)
end

local function load_dap()
  if dap_loaded then
    return
  end

  packadd 'mason.nvim'
  packadd 'nvim-dap'
  packadd 'nvim-nio'
  packadd 'nvim-dap-ui'
  packadd 'nvim-dap-go'
  packadd 'nvim-dap-python'
  packadd 'mason-nvim-dap.nvim'

  require('mason-nvim-dap').setup {
    automatic_setup = true,
    handlers = {},
    ensure_installed = {
      'delve',
    },
    automatic_installation = true,
  }

  local dap = require 'dap'
  local dapui = require 'dapui'

  dap.adapters.api = {
    type = 'server',
    host = 'api',
    port = 2345,
  }

  dap.configurations.go = dap.configurations.go or {}

  table.insert(dap.configurations.go, {
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
  })

  dapui.setup {
    icons = {
      expanded = '▾',
      collapsed = '▸',
      current_frame = '*',
    },
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
  }

  dap.listeners.after.event_initialized['dapui_config'] = dapui.open
  dap.listeners.before.event_terminated['dapui_config'] = dapui.close
  dap.listeners.before.event_exited['dapui_config'] = dapui.close

  require('dap-go').setup()
  require('dap-python').setup(os.getenv 'VIRTUAL_ENV')

  dap_loaded = true
end

vim.keymap.set('n', '<F5>', function()
  load_dap()
  require('dap').continue()
end, { desc = 'Debug: Start/Continue' })

vim.keymap.set('n', '<F1>', function()
  load_dap()
  require('dap').step_into()
end, { desc = 'Debug: Step Into' })

vim.keymap.set('n', '<F2>', function()
  load_dap()
  require('dap').step_over()
end, { desc = 'Debug: Step Over' })

vim.keymap.set('n', '<F3>', function()
  load_dap()
  require('dap').step_out()
end, { desc = 'Debug: Step Out' })

vim.keymap.set('n', '<leader>b', function()
  load_dap()
  require('dap').toggle_breakpoint()
end, { desc = 'Debug: Toggle Breakpoint' })

vim.keymap.set('n', '<leader>B', function()
  load_dap()
  require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
end, { desc = 'Debug: Set Breakpoint' })

vim.keymap.set('n', '<F7>', function()
  load_dap()
  require('dapui').toggle()
end, { desc = 'Debug: See last session result.' })
