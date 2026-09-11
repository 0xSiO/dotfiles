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
      -- vim.cmd.colorscheme('edge')
    end,
  },
  {
    'Aejkatappaja/cendre',
    lazy = false,
    priority = 1000,
    config = function()
      require('cendre').setup({ background = 'medium', italic_virtual_text = false })
      vim.cmd.colorscheme('cendre')
    end,
  },
  {
    'folke/snacks.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      explorer = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      picker = {
        enabled = true,
        win = { input = { keys = { ['<Esc>'] = { 'close', mode = { 'n', 'i' } } } } }
      },
      quickfile = { enabled = true },
      words = { enabled = true },
    },
    keys = {
      -- Top Pickers & Explorer
      { "<leader><space>", function() Snacks.picker.smart() end,                                                              desc = "Find Files (Smart)" },
      { "<leader>e",       function() Snacks.explorer() end,                                                                  desc = "File Explorer" },

      -- Find
      { "<leader>fc",      function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end,                            desc = "Find Config Files" },
      { "<leader>ff",      function() Snacks.picker.files() end,                                                              desc = "Find Files" },
      { "<leader>fp",      function() Snacks.picker.projects() end,                                                           desc = "Find Projects" },

      -- Git & GitHub
      { "<leader>gb",      function() Snacks.picker.git_branches() end,                                                       desc = "Git Branches" },
      { "<leader>gi",      function() Snacks.picker.gh_issue() end,                                                           desc = "GitHub Issues (Open)" },
      { "<leader>gI",      function() Snacks.picker.gh_issue({ state = "all" }) end,                                          desc = "GitHub Issues (All)" },
      { "<leader>gp",      function() Snacks.picker.gh_pr() end,                                                              desc = "GitHub Pull Requests (Open)" },
      { "<leader>gP",      function() Snacks.picker.gh_pr({ state = "all" }) end,                                             desc = "GitHub Pull Requests (All)" },

      -- Grep
      { "<leader>sg",      function() Snacks.picker.grep() end,                                                               desc = "Grep" },

      -- Search
      { '<leader>s/',      function() Snacks.picker.search_history() end,                                                     desc = "Search Search History" },
      { "<leader>sa",      function() Snacks.picker.autocmds() end,                                                           desc = "Search Autocmds" },
      { "<leader>sb",      function() Snacks.picker.lines() end,                                                              desc = "Search Buffer Lines" },
      { "<leader>sc",      function() Snacks.picker.command_history() end,                                                    desc = "Search Command History" },
      { "<leader>sC",      function() Snacks.picker.commands() end,                                                           desc = "Search Commands" },
      { "<leader>sd",      function() Snacks.picker.diagnostics() end,                                                        desc = "Search Diagnostics" },
      { "<leader>sD",      function() Snacks.picker.diagnostics_buffer() end,                                                 desc = "Search Buffer Diagnostics" },
      { "<leader>sh",      function() Snacks.picker.help() end,                                                               desc = "Search Help Pages" },
      { "<leader>si",      function() Snacks.picker.icons() end,                                                              desc = "Search Icons" },
      { "<leader>sj",      function() Snacks.picker.jumps() end,                                                              desc = "Search Jumps" },
      { "<leader>sk",      function() Snacks.picker.keymaps() end,                                                            desc = "Search Keymaps" },
      { "<leader>sm",      function() Snacks.picker.man() end,                                                                desc = "Search Man Pages" },
      { "<leader>sn",      function() Snacks.picker.notifications() end,                                                      desc = "Search Notification History" },
      { "<leader>sp",      function() Snacks.picker.pickers() end,                                                            desc = "Search Pickers" },
      { "<leader>sq",      function() Snacks.picker.qflist() end,                                                             desc = "Search Quickfix List" },
      { "<leader>sr",      function() Snacks.picker.resume() end,                                                             desc = "Resume Search" },

      -- LSP
      { 'gd',              function() Snacks.picker.lsp_definitions({ confirm = vim.o.modified and 'vsplit' or 'jump' }) end, desc = "LSP Definitions" },
      { 'gs',              function() Snacks.picker.lsp_definitions({ confirm = 'vsplit' }) end,                              desc = "LSP Definitions (V-Split)" },
      { 'gS',              function() Snacks.picker.lsp_definitions({ confirm = 'split' }) end,                               desc = "LSP Definitions (H-Split)" },
      { "gD",              function() Snacks.picker.lsp_declarations() end,                                                   desc = "LSP Declarations" },
      { "gr",              function() Snacks.picker.lsp_references() end,                                                     nowait = true,                       desc = "LSP References" },
      { "gi",              function() Snacks.picker.lsp_implementations() end,                                                desc = "LSP Implementations" },
      { "gy",              function() Snacks.picker.lsp_type_definitions() end,                                               desc = "LSP Type Definitions" },
      { "gai",             function() Snacks.picker.lsp_incoming_calls() end,                                                 desc = "LSP Incoming Calls" },
      { "gao",             function() Snacks.picker.lsp_outgoing_calls() end,                                                 desc = "LSP Outgoing Calls" },

      -- Other
      { "<leader>gB",      function() Snacks.gitbrowse() end,                                                                 desc = "Git Browse",                 mode = { "n", "v" } },
      { "<leader>un",      function() Snacks.notifier.hide() end,                                                             desc = "Dismiss All Notifications" },
      { "]]",              function() Snacks.words.jump(vim.v.count1) end,                                                    desc = "Next Reference",             mode = { "n", "t" } },
      { "[[",              function() Snacks.words.jump(-vim.v.count1) end,                                                   desc = "Prev Reference",             mode = { "n", "t" } },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          _G.dd = function(...) Snacks.debug.inspect(...) end
          vim._print = function(_, ...) dd(...) end

          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>n")
          Snacks.toggle.inlay_hints():map("<leader>uh")
          Snacks.toggle.indent():map("<leader>ug")
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').install({
        'bash', 'go', 'javascript', 'json', 'lua', 'markdown', 'php', 'python', 'regex', 'ruby', 'rust', 'sql', 'toml',
        'tsx', 'typescript', 'yaml'
      })

      vim.o.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      vim.o.foldmethod = 'expr'
      vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.o.foldlevel = 1

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(opts)
          local lang = vim.treesitter.language.get_lang(vim.bo[opts.buf].filetype)
          if lang and vim.treesitter.language.add(lang) then
            vim.treesitter.start(opts.buf, lang)
          end
        end,
      })
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
    },
  },
  {
    'mason-org/mason-lspconfig.nvim',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'neovim/nvim-lspconfig',
    },
    config = function()
      require('mason-lspconfig').setup({
        automatic_enable = true,
        ensure_installed = {
          'bashls', 'biome', 'golangci_lint_ls', 'gopls', 'lua_ls', 'phpantom_lsp', 'rust_analyzer', 'tombi', 'tsc',
          'ty'
        },
      })

      vim.api.nvim_create_augroup('user_format', {})
      vim.api.nvim_create_augroup('user_diagnostics', {})
      vim.api.nvim_create_augroup('user_hover', {})

      local function open_diagnostics()
        vim.diagnostic.open_float({
          focusable = false,
          source = true,
          format = function(d)
            if d.user_data.lsp and d.user_data.lsp.codeDescription and d.user_data.lsp.codeDescription.href then
              return d.message .. '\n  ' .. d.user_data.lsp.codeDescription.href
            else
              return d.message
            end
          end,
          close_events = { 'CursorMoved', 'BufEnter', 'BufWritePre', 'BufLeave' }
        })
      end

      local function persist_hover()
        vim.opt.eventignore:append('CursorHold')
        vim.lsp.buf.hover()
        vim.api.nvim_clear_autocmds({ event = 'CursorMoved', group = 'user_hover' })
        vim.api.nvim_create_autocmd('CursorMoved', {
          group = 'user_hover',
          callback = function() vim.opt.eventignore:remove('CursorHold') end,
          once = true
        })
      end

      -- LSP keybindings & autocommands
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          vim.keymap.set('n', '<C-Space>', persist_hover, { buffer = args.buf })
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = args.buf })
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = args.buf })
          vim.keymap.set('n', '<leader>lr', function() vim.cmd.lsp('restart') end, { buffer = args.buf })

          vim.api.nvim_clear_autocmds({ buffer = args.buf, group = 'user_format' })
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = 'user_format',
            buffer = args.buf,
            callback = function() vim.lsp.buf.format({ bufnr = args.buf }) end,
          })

          vim.api.nvim_clear_autocmds({ buffer = args.buf, group = 'user_diagnostics' })
          vim.api.nvim_create_autocmd('CursorHold', {
            group = 'user_diagnostics',
            buffer = args.buf,
            callback = open_diagnostics
          })
        end,
      })

      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file('', true),
            },
          },
        },
      })

      vim.lsp.config('rust_analyzer', {
        settings = {
          ['rust-analyzer'] = {
            check = { command = 'clippy' },
            interpret = { tests = true },
          }
        }
      })
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = { globalstatus = true },
      sections = {
        lualine_c = { { 'filename', path = 1 }, 'lsp_status' }
      }
    },
  },
  {
    'dlyongemallo/diffview-plus.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local actions = require('diffview.actions')
      require('diffview').setup({
        keymaps = {
          view = { { 'n', 'q', vim.cmd.DiffviewClose } },
          file_history_panel = {
            { 'n', 'q', vim.cmd.DiffviewClose },
            { 'n', 'd', actions.open_in_diffview }
          },
          file_panel = { { 'n', 'q', vim.cmd.DiffviewClose } }
        }
      })

      vim.keymap.set('n', '<leader>gd', vim.cmd.DiffviewOpen)
      vim.keymap.set('n', '<leader>gl', vim.cmd.DiffviewFileHistory)
      vim.keymap.set('n', '<leader>gf', function() vim.cmd.DiffviewFileHistory('%', '--follow') end)
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    dependencies = { 'dlyongemallo/diffview-plus.nvim' },
    config = function()
      local gitsigns = require('gitsigns')

      local function git_show()
        if not vim.b.gitsigns_blame_line_dict then return end
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
          vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, { buffer = bufnr })
          vim.keymap.set('n', '<leader>hb', function()
            gitsigns.blame_line({ full = true })
          end, { buffer = bufnr })
        end
      })
    end
  },
  {
    'nvim-mini/mini.nvim',
    config = function()
      require('mini.pairs').setup()
      require('mini.surround').setup()
    end,
  },
  {
    'folke/sidekick.nvim',
    config = function()
      require('sidekick').setup({
        cli = { mux = { enabled = true } }
      })

      local sidekick = require('sidekick.cli')
      vim.keymap.set({ 'n', 't', 'i', 'x' }, '<C-a>', function() sidekick.toggle({ focus = true }) end)
      vim.keymap.set({ 'n', 'x' }, '<leader>ap', function() sidekick.prompt() end)
    end
  },
})

-- Other options
vim.o.expandtab = true
vim.o.hidden = false
vim.o.ignorecase = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.shiftwidth = 2
vim.o.showmode = false
vim.o.signcolumn = 'yes'
vim.o.smartcase = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.tabstop = 4
vim.o.undofile = true
vim.o.updatetime = 400
vim.o.winborder = 'rounded'
vim.opt.clipboard:append('unnamedplus')
vim.opt.diffopt:append('algorithm:histogram')
vim.opt.fillchars:append('diff: ')

-- Other keybindings
vim.keymap.set('n', '<leader>bc', function() vim.cmd('%bd|e#') end, { desc = 'Delete Other Buffers' })
vim.keymap.set('n', '<M-t>', function()
  vim.cmd('vertical botright terminal')
  vim.cmd.startinsert()
end, { desc = 'Open Terminal (V-Split)' })
vim.keymap.set('i', '<S-Tab>', function() vim.cmd('<') end, { desc = 'Unindent Line' })

-- Other commands
vim.cmd.command('W :w')
vim.cmd.command('Q :q')
vim.cmd.command('Qa :qa')
vim.cmd.command('QA :qa')
