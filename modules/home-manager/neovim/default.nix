{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    inputs.nvf.homeManagerModules.default
  ];

  home.shellAliases = {
    nv = "nvim";
  };

  # programs.neovim = {
  #   enable = true;
  #   extraPackages = with pkgs; [
  #     ripgrep
  #   ];
  # };

  # xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix-config/dotfiles/nvim/";

  home.sessionVariables = {
    VISUAL = lib.mkForce "nvim";
    EDITOR = lib.mkForce "nvim";
    ALTERNATE_EDITOR = "vim";
  };

  programs.nvf.enable = true;
  programs.nvf.settings.vim = {
    viAlias = false;
    vimAlias = true;

    spellcheck = {
      enable = true;
    };

    lsp = {
      formatOnSave = true;
      lspkind.enable = true;
      trouble.enable = true;
      lspSignature.enable = true;
      otter-nvim.enable = true;
      nvim-docs-view.enable = true;
    };

    debugger = {
      nvim-dap = {
        enable = true;
        ui.enable = true;
      };
    };

    languages = {
      enableLSP = true;
      enableFormat = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;

      nix.enable = true;
      markdown.enable = true;

      bash.enable = true;
      clang.enable = true;
      css.enable = true;
      html.enable = true;
      sql.enable = true;
      java.enable = true;
      ts.enable = true;
      go.enable = true;
      lua.enable = true;
      zig.enable = true;
      python.enable = true;
      rust.enable = true;
      rust.crates.enable = true;

      assembly.enable = false;
      elixir.enable = false;
      haskell.enable = false;
      ruby.enable = false;
      fsharp.enable = false;

      tailwind.enable = false;
      svelte.enable = false;
    };

    visuals = {
      nvim-scrollbar.enable = true;
      nvim-web-devicons.enable = true;
      nvim-cursorline.enable = true;
      cinnamon-nvim.enable = true;
      fidget-nvim.enable = true;

      highlight-undo.enable = true;
      indent-blankline.enable = true;

      # Fun
      cellular-automaton.enable = true;
    };

    statusline = {
      lualine = {
        enable = true;
        theme = "catppuccin";
      };
    };

    theme = {
      enable = true;
      name = "catppuccin";
      style = "mocha";
      transparent = false;
    };

    autocomplete = {
      nvim-cmp.enable = true;
    };

    snippets = {
      luasnip.enable = true;
    };

    binds = {
      whichKey.enable = true;
      cheatsheet.enable = true;
    };

    telescope.enable = true;

    git = {
      enable = true;
      gitsigns.enable = true;
    };

    notes = {
      todo-comments.enable = true;
    };

    ui = {
      borders.enable = true;
      colorizer.enable = true;
      illuminate.enable = true;
    };

    session = {
      nvim-session-manager.enable = true;
    };

    comments = {
      comment-nvim.enable = true;
    };

    mini = {
      files = {
        enable = true;
        setupOpts = {
          mappings = {
            close = "<Esc><Esc>";
          };
          options = {
            permanent_delete = false;
            use_as_default_explorer = true;
          };
          windows = {
            preview = true;
            width_focus = 35;
            width_nofocus = 15;
            width_preview = 100;
          };
        };
      };
      icons.enable = true;
    };

    luaConfigRC.config =
      /*
      lua
      */
      ''

        ------------
        -- config --
        ------------

        vim.g.mapleader = ' '
        vim.g.maplocalleader = ' '

        -- Set highlight on search
        vim.o.hlsearch = true

        -- Make line numbers default
        vim.wo.number = true
        vim.wo.relativenumber = true

        vim.o.modeline = false

        -- Enable mouse mode
        vim.o.mouse = 'a'

        -- Sync clipboard between OS and Neovim.
        vim.o.clipboard = 'unnamedplus'

        -- Enable break indent
        vim.o.breakindent = true

        -- Save undo history
        vim.o.undofile = true

        -- Case-insensitive searching UNLESS \C or capital in search
        vim.o.ignorecase = true
        vim.o.smartcase = true

        -- Keep signcolumn on by default
        vim.wo.signcolumn = 'yes'

        -- Decrease update time
        vim.o.updatetime = 250
        vim.o.timeoutlen = 300

        -- Set completeopt to have a better completion experience
        vim.o.completeopt = 'menuone,noselect'

        -- NOTE: You should make sure your terminal supports this
        vim.o.termguicolors = true

        -- Window split direction
        vim.cmd.set 'splitbelow'
        vim.cmd.set 'splitright'

        -- Turn off inline diagnostic text
        vim.diagnostic.config { virtual_text = false, float = { border = 'rounded' } }

        -------------
        -- keymaps --
        -------------

        -- Default
        vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

        -- Undotree
        vim.keymap.set('n', '<leader><F5>', vim.cmd.UndotreeToggle)

        -- Word wrap
        vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
        vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

        local function minifile_open_cwd()
          local minifiles = require 'mini.files'
          minifiles.open(vim.api.nvim_buf_get_name(0))
          minifiles.reveal_cwd()
        end

        vim.api.nvim_create_user_command('Explore', minifile_open_cwd, {})
        vim.api.nvim_create_user_command('E', minifile_open_cwd, {})

        vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
        vim.keymap.set('n', '<leader><leader>', '<Cmd>Telescope resume<CR>', { desc = 'Open most recent picker with last selection' })
        vim.keymap.set('n', '<leader>/', function()
          require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end, { desc = '[/] Fuzzily search in current buffer' })
        vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
        vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
        vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
        vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
        vim.keymap.set('n', '<leader>sb', require('telescope.builtin').buffers, { desc = '[S]earch open [B]uffers' })
        vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
        vim.keymap.set('n', '<leader>sk', require('telescope.builtin').keymaps, { desc = '[K]eymaps' })
        vim.keymap.set('n', '<leader>sa', '<cmd>Telescope git_status<cr>', { desc = '[S]earch [P]roject' })
        vim.keymap.set('n', '<leader>sg', '<cmd>Telescope live_grep<cr>', { desc = '[S]earch by [G]rep' })
        vim.keymap.set('n', '<leader>gs', require('telescope.builtin').git_status, { desc = '[G]it [S]tatus' })
        vim.keymap.set('n', '<leader>gh', require('telescope.builtin').git_stash, { desc = '[G]it Stas[h]' })
        vim.keymap.set('n', '<leader>gb', require('telescope.builtin').git_branches, { desc = '[G]it [B]ranches' })
        vim.keymap.set('n', '<leader>gc', require('telescope.builtin').git_commits, { desc = '[G]it [C]ommits' })

        -- Telescope / LSP
        local bufopts = { noremap = true }
        vim.keymap.set('n', '<leader>gD', vim.lsp.buf.declaration, bufopts)
        vim.keymap.set('n', '<leader>gd', '<cmd>Telescope lsp_definitions<cr>zz', bufopts)
        vim.keymap.set('n', '<leader>gr', '<cmd>Telescope lsp_references<cr>', bufopts)
        vim.keymap.set('n', '<leader>gi', '<cmd>Telescope lsp_implementations<cr>zz', bufopts)
        vim.keymap.set('n', '<leader>gt', '<cmd>Telescope lsp_type_definitions<cr>zz', bufopts)
        vim.keymap.set('n', '<leader>K', vim.lsp.buf.hover, bufopts)
        vim.keymap.set('n', '<leader>kh', vim.lsp.buf.signature_help, bufopts)
        vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
        vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
        vim.keymap.set('n', '<leader>wl', function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)

        -- Diagnostic
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
        vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

        --------------
        -- autocmds --
        --------------

        -- keeps track of buffers that have been "touched" (entered insert mode or modified the buffer)
        local id = vim.api.nvim_create_augroup('startup', { clear = false })

        local persistbuffer = function(bufnr)
          bufnr = bufnr or vim.api.nvim_get_current_buf()
          vim.fn.setbufvar(bufnr, 'bufpersist', 1)
        end

        vim.api.nvim_create_autocmd({ 'BufRead' }, {
          group = id,
          pattern = { '*' },
          callback = function()
            vim.api.nvim_create_autocmd({ 'InsertEnter', 'BufModifiedSet' }, {
              buffer = 0,
              once = true,
              callback = function()
                persistbuffer()
              end,
            })
          end,
        })

        --- [[ Highlight on yank ]]
        -- See `:help vim.highlight.on_yank()`
        local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
        vim.api.nvim_create_autocmd('TextYankPost', {
          callback = function()
            vim.highlight.on_yank()
          end,
          group = highlight_group,
          pattern = '*',
        })

        vim.cmd [[autocmd InsertEnter * :set norelativenumber]]
        vim.cmd [[autocmd InsertLeave * :set relativenumber]]

        vim.api.nvim_create_autocmd('User', {
          pattern = 'MiniFilesBufferCreate',
          callback = function(args)
            local buf_id = args.data.buf_id

            vim.keymap.set('n', '<CR>', function()
              local mini_files = require 'mini.files'
              local entry = mini_files.get_fs_entry()
              if entry ~= nil then
                if entry.fs_type == 'directory' then
                  mini_files.go_in()
                else
                  mini_files.go_in()
                  mini_files.close()
                end
              end
            end, { buffer = buf_id, noremap = true, silent = true })
          end,
        })
      '';
  };
}
