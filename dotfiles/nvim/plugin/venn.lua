vim.pack.add {
  { src = 'https://github.com/jbyuki/venn.nvim' },
  { src = 'https://github.com/echasnovski/mini.move' },
  { src = 'https://github.com/lukas-reineke/indent-blankline.nvim' },
}

require('mini.move').setup {
  mappings = {
    left = '<M-h>',
    right = '<M-l>',
    down = '<M-j>',
    up = '<M-k>',
    line_left = '<M-h>',
    line_right = '<M-l>',
    line_down = '<M-j>',
    line_up = '<M-k>',
  },
}

local function mode_label()
  local m = vim.api.nvim_get_mode().mode
  if m:find '^ni' then
    return ''
  end
  if m:find '^no' then
    return '-- OP-PENDING --'
  end
  if m:find '^ic' then
    return '-- INSERT (COMPLETION) --'
  end
  if m:find '^Rc' then
    return '-- REPLACE (COMPLETION) --'
  end
  if m:find '^Rx' then
    return '-- V-REPLACE --'
  end
  if m:find '^t' then
    return '-- TERMINAL --'
  end

  local map = {
    n = '',
    i = '-- INSERT --',
    v = '-- VISUAL --',
    V = '-- VISUAL LINE --',
    ['\022'] = '-- VISUAL BLOCK --',
    c = '-- COMMAND --',
    R = '-- REPLACE --',
    s = '-- SELECT --',
    S = '-- SELECT LINE --',
    ['\019'] = '-- SELECT BLOCK --',
  }

  return map[m] or ('-- ' .. m .. ' --')
end

local function echo_mode(prepend)
  local label = mode_label()
  local msg = prepend and ('[VENN] ' .. label) or nil
  if msg then
    vim.api.nvim_echo({ { msg, 'ModeMsg' } }, false, {})
  else
    vim.api.nvim_echo({ { '', 'ModeMsg' } }, false, {})
  end
end

local function buf_augroup(buf, name)
  return vim.api.nvim_create_augroup(name .. buf, { clear = true })
end

local function install_mode_echo(buf)
  local gid = buf_augroup(buf, 'VennShowMode_')

  vim.api.nvim_create_autocmd('ModeChanged', {
    group = gid,
    buffer = buf,
    callback = function()
      if vim.api.nvim_get_current_buf() ~= buf then
        return
      end
      if not vim.b[buf].venn_enabled then
        return
      end
      echo_mode(true)
    end,
    desc = 'Show [VENN] + mode in cmdline when Venn is active',
  })

  vim.api.nvim_create_autocmd('BufWritePre', {
    group = gid,
    buffer = buf,
    callback = function()
      if vim.b[buf].venn_enabled then
        vim.cmd [[%s/\s\+$//e]]
      end
    end,
    desc = 'Trim trailing whitespace when saving in Venn mode',
  })

  echo_mode(true)
end

local function uninstall_mode_echo(buf)
  pcall(vim.api.nvim_del_augroup_by_name, 'VennShowMode_' .. buf)
end

function _G.Toggle_venn()
  local buf = vim.api.nvim_get_current_buf()

  if not vim.b.venn_enabled then
    require('ibl').update { enabled = false }
    vim.b.venn_enabled = true

    vim.w._venn_prev_wrap = vim.wo.wrap
    vim.cmd 'setlocal ve=all'
    vim.cmd 'setlocal nowrap'

    vim.keymap.set('n', 'J', '<C-v>j:VBox<CR>', { buffer = buf, noremap = true, silent = true })
    vim.keymap.set('n', 'K', '<C-v>k:VBox<CR>', { buffer = buf, noremap = true, silent = true })
    vim.keymap.set('n', 'L', '<C-v>l:VBox<CR>', { buffer = buf, noremap = true, silent = true })
    vim.keymap.set('n', 'H', '<C-v>h:VBox<CR>', { buffer = buf, noremap = true, silent = true })
    vim.keymap.set('v', 'f', ':VBox<CR>', { buffer = buf, noremap = true, silent = true })

    vim.b._venn_prev_showmode = vim.o.showmode
    vim.o.showmode = false
    install_mode_echo(buf)
  else
    require('ibl').update { enabled = true }

    if vim.w._venn_prev_wrap ~= nil then
      vim.wo.wrap = vim.w._venn_prev_wrap
      vim.w._venn_prev_wrap = nil
    else
      vim.cmd 'setlocal wrap'
    end

    vim.cmd 'setlocal ve='

    pcall(vim.keymap.del, 'n', 'J', { buffer = buf })
    pcall(vim.keymap.del, 'n', 'K', { buffer = buf })
    pcall(vim.keymap.del, 'n', 'L', { buffer = buf })
    pcall(vim.keymap.del, 'n', 'H', { buffer = buf })
    pcall(vim.keymap.del, 'v', 'f', { buffer = buf })
    vim.b.venn_enabled = nil

    uninstall_mode_echo(buf)
    local prev = vim.b._venn_prev_showmode
    if prev == nil then
      vim.o.showmode = true
    else
      vim.o.showmode = prev
    end

    echo_mode(false)
  end
end

vim.keymap.set('n', '<leader>v', function()
  _G.Toggle_venn()
end, { noremap = true, silent = true, desc = 'Venn: toggle draw mode' })

vim.api.nvim_create_user_command('VennToggle', function()
  _G.Toggle_venn()
end, {})
