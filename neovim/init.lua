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
          'bash', 'go', 'javascript', 'json', 'lua', 'markdown', 'python', 'regex', 'ruby', 'rust',
          'sql', 'toml', 'typescript'
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
    'williamboman/mason.nvim',
    config = true,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
      'saghen/blink.cmp',
    },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = {
          'bashls', 'eslint', 'gopls', 'lua_ls', 'pyright', 'rust_analyzer', 'solargraph', 'ts_ls',
          'volar'
        },
      })

      vim.api.nvim_create_augroup('user_format', {})
      vim.api.nvim_create_augroup('user_highlight', {})
      vim.api.nvim_create_augroup('user_hover', {})

      local function open_diagnostics()
        vim.diagnostic.open_float({
          focusable = false,
          source = true,
          format = function(d)
            if d.user_data.lsp
                and d.user_data.lsp.codeDescription
                and d.user_data.lsp.codeDescription.href then
              return d.message .. '\n  ' .. d.user_data.lsp.codeDescription.href
            else
              return d.message
            end
          end,
          close_events = { 'CursorMoved', 'BufEnter', 'BufWritePre' }
        })
      end

      local function persist_hover()
        vim.opt.eventignore:append('CursorHold')
        vim.lsp.buf.hover()
        vim.api.nvim_clear_autocmds({ event = 'CursorMoved', group = 'user_hover' })
        vim.api.nvim_create_autocmd('CursorMoved', {
          group = 'user_hover',
          callback = function()
            vim.opt.eventignore:remove('CursorHold')
          end,
          once = true
        })
      end

      -- LSP keybindings & autocommands
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          vim.keymap.set('n', '<C-Space>', persist_hover, { buffer = args.buf })
          vim.keymap.set({ 'n', 'v' }, '<leader>f', vim.lsp.buf.format, { buffer = args.buf })
          vim.keymap.set('n', 'ca', vim.lsp.buf.code_action, { buffer = args.buf })
          vim.keymap.set('n', 'rn', vim.lsp.buf.rename, { buffer = args.buf })
          vim.keymap.set('n', '<leader>lr', vim.cmd.LspRestart, { buffer = args.buf })

          vim.api.nvim_clear_autocmds({ buffer = args.buf, group = 'user_format' })
          vim.api.nvim_clear_autocmds({ buffer = args.buf, group = 'user_highlight' })

          vim.api.nvim_create_autocmd('BufWritePre', {
            group = 'user_format',
            buffer = args.buf,
            callback = function() vim.lsp.buf.format({ bufnr = args.buf }) end,
          })
          vim.api.nvim_create_autocmd('CursorHold', {
            group = 'user_highlight',
            buffer = args.buf,
            callback = function()
              vim.lsp.buf.clear_references()
              vim.lsp.buf.document_highlight()
              open_diagnostics()
            end
          })
          vim.api.nvim_create_autocmd('CursorMoved', {
            group = 'user_highlight',
            buffer = args.buf,
            callback = vim.lsp.buf.clear_references
          })
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)

      require('mason-lspconfig').setup_handlers({
        function(server)
          require('lspconfig')[server].setup({ capabilities = capabilities })
        end,
        eslint = function()
          require('lspconfig').eslint.setup({
            on_attach = function(client, bufnr)
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
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = { globalstatus = true },
      sections = {
        lualine_c = { { 'filename', path = 1 }, 'lsp_status' }
      }
    },
  },
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local actions = require('diffview.actions')
      require('diffview').setup({
        keymaps = {
          view = { { 'n', 'q', vim.cmd.tabclose } },
          file_history_panel = {
            { 'n', 'q', vim.cmd.tabclose },
            { 'n', 'd', actions.open_in_diffview }
          },
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
      require('mini.notify').setup({
        window = {
          config = function()
            return { anchor = 'SE', col = vim.o.columns, row = vim.o.lines - vim.o.cmdheight - 1 }
          end
        }
      })
      vim.notify = require('mini.notify').make_notify()
    end,
  },
  {
    'folke/snacks.nvim',
    config = function()
      require('snacks').setup({
        input = {},
        picker = {
          hidden = true,
          win = {
            input = { keys = { ['<Esc>'] = { 'close', mode = { 'n', 'i' } } } }
          }
        }
      })

      vim.keymap.set('n', 'ff', function() Snacks.picker.files({ hidden = true }) end)
      vim.keymap.set('n', 'fg', Snacks.picker.grep)
      vim.keymap.set('n', 'fh', Snacks.picker.help)
      vim.keymap.set('n', 'fm', Snacks.picker.man)
      vim.keymap.set('n', 'gd', function()
        Snacks.picker.lsp_definitions({ confirm = vim.o.modified and 'vsplit' or 'jump' })
      end)
      vim.keymap.set('n', 'gs', function() Snacks.picker.lsp_definitions({ confirm = 'vsplit' }) end)
      vim.keymap.set('n', 'gS', function() Snacks.picker.lsp_definitions({ confirm = 'split' }) end)
      vim.keymap.set('n', 'gi', Snacks.picker.lsp_implementations)
      vim.keymap.set('n', 'gr', Snacks.picker.lsp_references, { nowait = true })
    end
  }
})

-- Other options
vim.o.signcolumn = 'yes'
vim.o.winborder = 'rounded'
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
