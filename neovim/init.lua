-- Disable unneeded dynamic providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Install lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {
    'sainnhe/edge',
    priority = 1000,
    config = function()
      vim.o.termguicolors = vim.fn.has('termguicolors') == 1
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
          'bash', 'javascript', 'json', 'lua', 'regex', 'ruby', 'rust', 'toml', 'typescript'
        },
        highlight = { enable = true },
        indent = { enable = true },
      })

      vim.o.foldmethod = 'expr'
      vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
      vim.o.foldlevel = 1
    end,
  },
  {
    'L3MON4D3/LuaSnip',
    version = 'v1.*',
    dependencies = {'honza/vim-snippets'},
    config = function()
      require('luasnip').setup({ region_check_events = 'InsertEnter' })
      require('luasnip.loaders.from_snipmate').lazy_load()
    end,
  },
  {
    'windwp/nvim-autopairs',
    config = true,
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'windwp/nvim-autopairs',
      'onsails/lspkind.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-nvim-lua',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline'
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      local function confirm_or_jump(fallback)
        if luasnip.in_snippet() then
          if cmp.get_selected_entry() then
            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace })
          else
            luasnip.jump(1)
          end
        elseif cmp.visible() then
          cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
        else
          fallback()
        end
      end

      local function jump_back(fallback)
        if luasnip.in_snippet() then
          luasnip.jump(-1)
        else
          fallback()
        end
      end

      cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())

      cmp.setup({
        formatting = { format = require('lspkind').cmp_format() },
        snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
        mapping = {
          ['<C-Space>'] = function() if cmp.visible() then cmp.abort() else cmp.complete() end end,
          ['<C-j>'] = cmp.mapping.select_next_item(),
          ['<C-k>'] = cmp.mapping.select_prev_item(),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<Tab>'] = cmp.mapping(confirm_or_jump, {'i', 's'}),
          ['<S-Tab>'] = cmp.mapping(jump_back, {'i', 's'}),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lua' },
          { name = 'nvim_lsp' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        })
      })

      cmp.setup.cmdline({'/', '?'}, {
        mapping = {
          ['<C-j>'] = cmp.mapping(cmp.mapping.select_next_item(), {'c'}),
          ['<C-k>'] = cmp.mapping(cmp.mapping.select_prev_item(), {'c'}),
        },
        sources = cmp.config.sources({ { name = 'buffer' } })
      })

      cmp.setup.cmdline(':', {
        mapping = {
          ['<C-j>'] = cmp.mapping(cmp.mapping.select_next_item(), {'c'}),
          ['<C-k>'] = cmp.mapping(cmp.mapping.select_prev_item(), {'c'}),
        },
        sources = cmp.config.sources({ { name = 'cmdline' } })
      })
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    version = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
      'nvim-telescope/telescope-ui-select.nvim'
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
        extensions = {
          ['ui-select'] = { require('telescope.themes').get_cursor({}) }
        },
      })

      require('telescope').load_extension('ui-select')

      vim.keymap.set('n', 'ff', require('telescope.builtin').find_files)
      vim.keymap.set('n', 'fg', require('telescope.builtin').live_grep)
      vim.keymap.set('n', 'fh', require('telescope.builtin').help_tags)
      vim.keymap.set('n', 'fm', require('telescope.builtin').man_pages)
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
      'nvim-lua/lsp-status.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'nvim-telescope/telescope.nvim'
    },
    config = function()
      require('mason').setup({})

      require('mason-lspconfig').setup({
        ensure_installed = {'eslint', 'lua_ls', 'pyright', 'rust_analyzer', 'solargraph', 'tsserver'},
      })

      local lsp_status = require('lsp-status')
      lsp_status.config({ current_function = false, diagnostics = false, status_symbol = 'λ' })
      lsp_status.register_progress()

      vim.diagnostic.config({ virtual_text = false })
      vim.api.nvim_create_autocmd('CursorHold', {
        -- TODO: Sometimes the cursor jumps into the floating window automatically and it's annoying
        callback = function() vim.diagnostic.open_float({ source = true }) end
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, lsp_status.capabilities)
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      require('mason-lspconfig').setup_handlers({
        function(server)
          require('lspconfig')[server].setup({ on_attach = lsp_status.on_attach, capabilities = capabilities })
        end,

        ['eslint'] = function()
          require('lspconfig').eslint.setup({
            on_attach = function(client, bufnr)
              lsp_status.on_attach(client)
              vim.api.nvim_create_autocmd('BufWritePre', { buffer = bufnr, command = 'EslintFixAll' })
            end
          })
        end,

        ['lua_ls'] = function()
          require('lspconfig').lua_ls.setup({
            on_attach = lsp_status.on_attach,
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = { version = 'LuaJIT' },
                diagnostics = { globals = {'vim'} },
                workspace = { library = vim.api.nvim_get_runtime_file('', true), checkThirdParty = false },
                telemetry = { enable = false },
              },
            },
          })
        end,
      })

      -- LSP keybindings
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          vim.keymap.set('n', '<C-Space>', vim.lsp.buf.hover, { buffer = args.buf })
          vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, { buffer = args.buf })
          vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, { buffer = args.buf })
          vim.keymap.set('n', 'gs', function()
            require('telescope.builtin').lsp_definitions({ jump_type = 'vsplit' })
          end, { buffer = args.buf })
          vim.keymap.set('n', 'gS', function()
            require('telescope.builtin').lsp_definitions({ jump_type = 'split' })
          end, { buffer = args.buf })
          vim.keymap.set('n', 'ca', vim.lsp.buf.code_action, { buffer = args.buf })
          vim.keymap.set({'n', 'v'}, '<leader>f', vim.lsp.buf.format, { buffer = args.buf })
        end,
      })
    end
  },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {'nvim-tree/nvim-web-devicons'},
    keys = {
      {'<C-n>', '<cmd>NvimTreeToggle<cr>'},
    },
    config = function()
      require('nvim-tree').setup({ filters = { dotfiles = true }, git = { ignore = false } })

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
    dependencies = {'nvim-tree/nvim-web-devicons', 'nvim-lua/lsp-status.nvim'},
    opts = {
      options = { globalstatus = true },
      sections = {
        lualine_c = { { 'filename', path = 1 }, "require('lsp-status').status()" }
      }
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      local gitsigns = require('gitsigns')

      local function git_diff()
        gitsigns.diffthis()
        vim.cmd.wincmd('h')
      end

      local function git_show()
        local commit = vim.b.gitsigns_blame_line_dict.sha
        -- Do nothing if changes haven't been committed
        if commit == '0000000000000000000000000000000000000000' then return end

        vim.cmd.tabnew()
        vim.cmd.terminal('git show ' .. commit)
        vim.cmd.startinsert()
      end

      local function git_blame()
        local abs_path = vim.api.nvim_buf_get_name(0)

        vim.cmd.tabnew()
        vim.cmd.terminal('git blame ' .. abs_path)
        vim.cmd.startinsert()
      end

      gitsigns.setup({
        current_line_blame = true,
        current_line_blame_opts = { virt_text = false, delay = 250 },
        on_attach = function(bufnr)
          vim.keymap.set('n', '<leader>gd', git_diff, { buffer = bufnr })
          vim.keymap.set('n', '<leader>gs', git_show, { buffer = bufnr })
          vim.keymap.set('n', '<leader>gb', git_blame, { buffer = bufnr })
          vim.keymap.set('n', '<leader>gc', require('telescope.builtin').git_bcommits, { buffer = bufnr })
          vim.keymap.set('n', '<leader>d', gitsigns.preview_hunk, { buffer = bufnr })
          vim.keymap.set('n', '<leader>b', function() gitsigns.blame_line({ full = true }) end, { buffer = bufnr })
        end
      })
    end
  },
  {
    'anuvyklack/help-vsplit.nvim',
    opts = { always = true },
  },
  {
    'numToStr/Comment.nvim',
    config = true,
  },
  {
    'machakann/vim-sandwich',
  },
})

-- Other options
vim.o.signcolumn = 'yes'
vim.o.number = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.undofile = true
vim.o.hidden = false
vim.o.updatetime = 200
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.showmode = false
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- Other keybindings
vim.keymap.set('n', '<M-t>', function() vim.cmd.vnew(); vim.cmd.terminal(); vim.cmd.startinsert() end)
vim.keymap.set('i', '<S-Tab>', function() vim.cmd('<') end)
vim.keymap.set('i', '<C-h>', '<C-w>') -- <C-h> is <C-BS>
vim.keymap.set('t', '<M-BS>', '<C-w>')

-- Other commands
vim.cmd.command('W :w')
vim.cmd.command('Q :q')
vim.cmd.command('Qa :qa')
vim.cmd.command('QA :qa')

-- vim: sw=2 ts=2
