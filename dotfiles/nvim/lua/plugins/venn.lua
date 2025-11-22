return {
  {
    'jbyuki/venn.nvim',
    dependencies = {
      'echasnovski/mini.move',
      'lukas-reineke/indent-blankline.nvim',
    },

    keys = {
      { '<leader>v', '<cmd>VennToggle<CR>', desc = 'Venn: toggle draw mode' },
    },

    config = function()
      -- ── mini.move: Alt+hjkl to move lines/blocks ───────────────────────────────
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

      -- Map Neovim's mode() to the standard showmode labels
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
          ['\022'] = '-- VISUAL BLOCK --', -- <C-v>
          c = '-- COMMAND --',
          R = '-- REPLACE --',
          s = '-- SELECT --',
          S = '-- SELECT LINE --',
          ['\019'] = '-- SELECT BLOCK --', -- <C-s>
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

      -- Install buffer-local ModeChanged + BufWritePre while VENN is enabled
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

        -- Trim trailing whitespace on save, only when Venn is enabled for this buffer
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

      -- ── Toggle function ────────────────────────────────────────────────────────
      function _G.Toggle_venn()
        local buf = vim.api.nvim_get_current_buf()
        if not vim.b.venn_enabled then
          -- Enable Venn
          require('ibl').update { enabled = false }
          vim.b.venn_enabled = true

          -- Save & adjust window-local options
          vim.w._venn_prev_wrap = vim.wo.wrap -- remember previous wrap per window
          vim.cmd 'setlocal ve=all'
          vim.cmd 'setlocal nowrap' -- disable wrapping while drawing

          -- Drawing keymaps
          vim.keymap.set('n', 'J', '<C-v>j:VBox<CR>', { buffer = buf, noremap = true, silent = true })
          vim.keymap.set('n', 'K', '<C-v>k:VBox<CR>', { buffer = buf, noremap = true, silent = true })
          vim.keymap.set('n', 'L', '<C-v>l:VBox<CR>', { buffer = buf, noremap = true, silent = true })
          vim.keymap.set('n', 'H', '<C-v>h:VBox<CR>', { buffer = buf, noremap = true, silent = true })
          vim.keymap.set('v', 'f', ':VBox<CR>', { buffer = buf, noremap = true, silent = true })

          -- Replace builtin showmode while active
          vim.b._venn_prev_showmode = vim.o.showmode
          vim.o.showmode = false
          install_mode_echo(buf)
        else
          -- Disable Venn
          require('ibl').update { enabled = true }

          -- Restore window-local options
          if vim.w._venn_prev_wrap ~= nil then
            vim.wo.wrap = vim.w._venn_prev_wrap
            vim.w._venn_prev_wrap = nil
          else
            -- fallback if somehow unset
            vim.cmd 'setlocal wrap'
          end
          vim.cmd 'setlocal ve='

          -- Remove keymaps
          pcall(vim.keymap.del, 'n', 'J', { buffer = buf })
          pcall(vim.keymap.del, 'n', 'K', { buffer = buf })
          pcall(vim.keymap.del, 'n', 'L', { buffer = buf })
          pcall(vim.keymap.del, 'n', 'H', { buffer = buf })
          pcall(vim.keymap.del, 'v', 'f', { buffer = buf })
          vim.b.venn_enabled = nil

          -- Restore showmode
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

      -- Keybinding & :VennToggle command
      vim.keymap.set('n', '<leader>v', function()
        _G.Toggle_venn()
      end, { noremap = true, silent = true, desc = 'Venn: toggle draw mode' })

      vim.api.nvim_create_user_command('VennToggle', function()
        _G.Toggle_venn()
      end, {})
    end,
  },
}
