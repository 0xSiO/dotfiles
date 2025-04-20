-- Disable unneeded dynamic providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Install lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- TODO: Other plugins to explore - replace dressing.nvim with snacks.nvim

require('lazy').setup({
  {
    'sainnhe/edge',
    priority = 1000,
    config = function()
      vim.g.edge_show_eob = 0
      vim.g.edge_better_performance = 1
      vim.cmd.colorscheme('edge')
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'bash', 'javascript', 'json', 'lua', 'markdown', 'python', 'regex', 'ruby', 'rust', 'sql',
          'toml', 'typescript'
        },
        highlight = { enable = true },
        indent = { enable = true },
      })

      vim.o.foldmethod = 'expr'
      vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.o.foldlevel = 1
    end,
  },
  {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = '1.*',
    opts = {
      keymap = {
        preset = 'super-tab',
        ['<C-j>'] = { 'select_next' },
        ['<C-k>'] = { 'select_prev' },
        ['<C-f>'] = { 'scroll_documentation_down' },
        ['<C-b>'] = { 'scroll_documentation_up' },
      },
      completion = { documentation = { auto_show = true } },
      signature = { enabled = true },
      cmdline = {
        keymap = {
          ['<C-j>'] = { 'select_next' },
          ['<C-k>'] = { 'select_prev' },
        },
      },
    }
  },
  {
    'nvim-telescope/telescope.nvim',
    version = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
      'stevearc/dressing.nvim',
    },
    config = function()
      require('telescope').setup({
        defaults = {
          mappings = {
            i = {
              ['<C-j>'] = 'move_selection_next',
              ['<C-k>'] = 'move_selection_previous',
              ['<C-f>'] = 'preview_scrolling_down',
              ['<C-b>'] = 'preview_scrolling_up',
              ['<Esc>'] = 'close',
            }
          }
        },
      })

      vim.keymap.set('n', 'ff', require('telescope.builtin').find_files)
      vim.keymap.set('n', 'fg', require('telescope.builtin').live_grep)
      vim.keymap.set('n', 'fh', require('telescope.builtin').help_tags)
      vim.keymap.set('n', 'fm', require('telescope.builtin').man_pages)
    end,
  },
  {
    'williamboman/mason.nvim',
    config = true,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
      'nvim-lua/lsp-status.nvim',
      'saghen/blink.cmp',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = { 'bashls', 'eslint', 'lua_ls', 'pyright', 'rust_analyzer', 'solargraph', 'ts_ls', 'volar' },
      })

      vim.api.nvim_create_augroup('user_format', {})
      vim.api.nvim_create_augroup('user_highlight', {})
      vim.api.nvim_create_augroup('user_hover', {})

      local function vsplit_lsp_definitions()
        require('telescope.builtin').lsp_definitions({
          jump_type = 'vsplit',
          attach_mappings = function(_, map)
            map('i', '<CR>', 'select_vertical')
            return true
          end,
        })
      end

      local function hsplit_lsp_definitions()
        require('telescope.builtin').lsp_definitions({
          jump_type = 'split',
          attach_mappings = function(_, map)
            map('i', '<CR>', 'select_horizontal')
            return true
          end,
        })
      end

      local function lsp_definitions()
        if vim.o.modified then
          vsplit_lsp_definitions()
        else
          require('telescope.builtin').lsp_definitions()
        end
      end

      local function highlight_references()
        vim.lsp.buf.document_highlight()
        vim.api.nvim_clear_autocmds({ event = 'CursorMoved', group = 'user_highlight' })
        vim.api.nvim_create_autocmd('CursorMoved', {
          group = 'user_highlight',
          callback = vim.lsp.buf.clear_references,
          once = true
        })
      end

      local function open_diagnostics()
        vim.diagnostic.open_float({
          focusable = false,
          format = function(d)
            local result = string.format('%s: %s', d.source, d.message)

            if d.user_data.lsp
                and d.user_data.lsp.codeDescription
                and d.user_data.lsp.codeDescription.href then
              result = result .. '\n  ' .. d.user_data.lsp.codeDescription.href
            end

            return result
          end,
          close_events = { 'CursorMoved', 'BufEnter', 'BufWritePre' }
        })
      end

      -- LSP keybindings & autocommands
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          vim.keymap.set('n', 'grr', require('telescope.builtin').lsp_references, { buffer = args.buf })
          vim.keymap.set('n', 'gri', require('telescope.builtin').lsp_implementations, { buffer = args.buf })
          vim.keymap.set('n', 'gO', require('telescope.builtin').lsp_document_symbols, { buffer = args.buf })
          vim.keymap.set('n', 'gd', lsp_definitions, { buffer = args.buf })
          vim.keymap.set('n', 'gs', vsplit_lsp_definitions, { buffer = args.buf })
          vim.keymap.set('n', 'gS', hsplit_lsp_definitions, { buffer = args.buf })
          vim.keymap.set({ 'n', 'v' }, '<leader>f', vim.lsp.buf.format, { buffer = args.buf })
          vim.keymap.set('n', '<leader>lr', vim.cmd.LspRestart, { buffer = args.buf })

          vim.api.nvim_clear_autocmds({ event = 'BufWritePre', buffer = args.buf, group = 'user_format' })
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = 'user_format',
            buffer = args.buf,
            callback = vim.lsp.buf.format,
          })

          vim.api.nvim_clear_autocmds({ event = 'CursorHold', buffer = args.buf, group = 'user_hover' })
          vim.api.nvim_create_autocmd('CursorHold', {
            group = 'user_hover',
            buffer = args.buf,
            callback = function()
              highlight_references()
              open_diagnostics()
            end
          })
        end,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        callback = function(args)
          vim.api.nvim_clear_autocmds({ event = 'BufWritePre', buffer = args.buf, group = 'user_format' })
          vim.api.nvim_clear_autocmds({ event = 'CursorHold', buffer = args.buf, group = 'user_hover' })
        end,
      })

      local lsp_status = require('lsp-status')
      lsp_status.config({ current_function = false, diagnostics = false, status_symbol = 'λ' })
      lsp_status.register_progress()

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_extend('keep', capabilities, lsp_status.capabilities)
      capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)

      require('mason-lspconfig').setup_handlers({
        function(server)
          require('lspconfig')[server].setup({ on_attach = lsp_status.on_attach, capabilities = capabilities })
        end,
        eslint = function()
          require('lspconfig').eslint.setup({
            on_attach = function(client, bufnr)
              lsp_status.on_attach(client)
              vim.api.nvim_clear_autocmds({ event = 'BufWritePre', buffer = bufnr, group = 'user_format' })
              vim.api.nvim_create_autocmd('BufWritePre', {
                group = 'user_format',
                buffer = bufnr,
                command = 'EslintFixAll',
              })
            end,
            capabilities = capabilities,
          })
        end,
        lua_ls = function()
          require('lspconfig').lua_ls.setup({
            on_attach = lsp_status.on_attach,
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = { version = 'LuaJIT' },
                diagnostics = { globals = { 'vim' } },
                workspace = { library = vim.api.nvim_get_runtime_file('', true), checkThirdParty = false },
                telemetry = { enable = false },
              },
            },
          })
        end,
        rust_analyzer = function()
          require('lspconfig').rust_analyzer.setup({
            on_attach = lsp_status.on_attach,
            capabilities = capabilities,
            settings = {
              ['rust-analyzer'] = {
                check = { command = 'clippy' },
                interpret = { tests = true },
              }
            }
          })
        end
      })
    end,
  },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('nvim-tree').setup({
        view = { width = 40 },
        filters = { dotfiles = true, git_ignored = false },
      })

      vim.keymap.set('n', '<C-n>', require('nvim-tree.api').tree.toggle)
      vim.api.nvim_create_autocmd('BufEnter', {
        nested = true,
        callback = function()
          if #vim.api.nvim_list_wins() == 1 and require('nvim-tree.utils').is_nvim_tree_buf() then
            vim.cmd.quit()
          end
        end
      })
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'nvim-lua/lsp-status.nvim' },
    opts = {
      options = { globalstatus = true },
      sections = {
        lualine_c = { { 'filename', path = 1 }, "require('lsp-status').status()" }
      }
    },
  },
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('diffview').setup({
        keymaps = {
          view = { { 'n', 'q', vim.cmd.tabclose } },
          file_history_panel = { { 'n', 'q', vim.cmd.tabclose } },
          file_panel = { { 'n', 'q', vim.cmd.tabclose } }
        }
      })

      vim.keymap.set('n', '<leader>gd', vim.cmd.DiffviewOpen)
      vim.keymap.set('n', '<leader>gf', function() vim.cmd.DiffviewFileHistory('%', '--follow') end)
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    dependencies = { 'sindrets/diffview.nvim' },
    config = function()
      local gitsigns = require('gitsigns')

      local function git_show()
        local commit = vim.b.gitsigns_blame_line_dict.sha
        -- Do nothing if changes haven't been committed
        if commit == '0000000000000000000000000000000000000000' then return end

        vim.cmd.DiffviewOpen(commit .. '^..' .. commit)
      end

      gitsigns.setup({
        current_line_blame = true,
        current_line_blame_opts = { virt_text = false, delay = 250 },
        on_attach = function(bufnr)
          vim.keymap.set('n', '<leader>gs', git_show, { buffer = bufnr })
          vim.keymap.set('n', '<leader>d', gitsigns.preview_hunk, { buffer = bufnr })
          vim.keymap.set('n', '<leader>b', function()
            gitsigns.blame_line({ full = true })
          end, { buffer = bufnr })
        end
      })
    end
  },
  {
    'echasnovski/mini.nvim',
    version = '0.15.x',
    config = function()
      require('mini.comment').setup()
      require('mini.pairs').setup()
      require('mini.surround').setup()
    end,
  },
})

-- Other options
vim.o.signcolumn = 'yes'
vim.o.number = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.undofile = true
vim.o.hidden = false
vim.o.updatetime = 400
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.showmode = false
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.opt.diffopt:append({ 'algorithm:histogram' })
vim.opt.fillchars:append({ diff = ' ' })

-- Other keybindings
vim.keymap.set('n', '<M-t>', function()
  vim.cmd('vertical botright terminal')
  vim.cmd.startinsert()
end)
vim.keymap.set('i', '<S-Tab>', function() vim.cmd('<') end)
vim.keymap.set('i', '<C-h>', '<C-w>') -- <C-h> is <C-BS>
vim.keymap.set('t', '<M-BS>', '<C-w>')

-- Other commands
vim.cmd.command('W :w')
vim.cmd.command('Q :q')
vim.cmd.command('Qa :qa')
vim.cmd.command('QA :qa')

-- vim: sw=2 ts=2
