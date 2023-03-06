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
        ensure_installed = { 'bash', 'javascript', 'json', 'lua', 'regex', 'ruby', 'rust', 'toml', 'typescript' },
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
    dependencies = { 'honza/vim-snippets' },
    config = function()
      require('luasnip.loaders.from_snipmate').lazy_load()
    end,
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
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      local function confirm_or_jump(fallback)
        if cmp.visible() then
          cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
        elseif luasnip.in_snippet() and luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end

      local function jump_back(fallback)
        if luasnip.in_snippet() and luasnip.jumpable(-1) then
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
          ['<C-l>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<Tab>'] = cmp.mapping(confirm_or_jump, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(jump_back, { 'i', 's' }),
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
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim', 'neovim/nvim-lspconfig', 'nvim-lua/lsp-status.nvim', 'hrsh7th/cmp-nvim-lsp' },
    config = function()
      require('mason').setup({})

      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'pyright', 'rust_analyzer', 'solargraph', 'tsserver' },
      })

      local lsp_status = require('lsp-status')
      lsp_status.register_progress()

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, lsp_status.capabilities)
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      require('mason-lspconfig').setup_handlers({
        function(server)
          require('lspconfig')[server].setup({
            on_attach = lsp_status.on_attach,
            capabilities = capabilities
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
                workspace = {
                  library = vim.api.nvim_get_runtime_file('', true),
                  checkThirdParty = false,
                },
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
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = args.buf })
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = args.buf })
          vim.keymap.set('n', 'gs', function() vim.cmd.vsplit(); vim.lsp.buf.definition() end, { buffer = args.buf })
          vim.keymap.set('n', 'gS', function() vim.cmd.split(); vim.lsp.buf.definition() end, { buffer = args.buf })
          vim.keymap.set('n', 'ca', vim.lsp.buf.code_action, { buffer = args.buf })
          vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { buffer = args.buf })
        end,
      })
    end
  },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<C-n>', '<cmd>NvimTreeToggle<cr>' },
    },
    config = function()
      require('nvim-tree').setup({
        filters = { dotfiles = true },
        git = { ignore = false },
      })

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
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
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
        }
      })

      vim.keymap.set('n', 'ff', require('telescope.builtin').find_files)
      vim.keymap.set('n', 'fg', require('telescope.builtin').live_grep)
      vim.keymap.set('n', 'fh', require('telescope.builtin').help_tags)
    end,
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
    'windwp/nvim-autopairs',
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
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.showmode = false
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- Other keybindings
vim.keymap.set('n', '<M-t>', function() vim.cmd.vnew(); vim.cmd.terminal(); vim.cmd.startinsert() end)

-- Other commands
vim.cmd.command('W :w')
vim.cmd.command('Q :q')
vim.cmd.command('Qa :qa')
vim.cmd.command('QA :qa')
