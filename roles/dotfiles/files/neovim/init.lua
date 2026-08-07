-- TODO:
--   - Snacks: look into statuscolumn

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
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Find Files (Smart)" },
      { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },

      -- Find
      -- { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Find Buffers" },
      -- { "<leader>fs", function() Snacks.picker.scratch() end, desc = "Find Scratch Buffers" },
      { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config Files" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
      -- { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
      -- { "<leader>fp", function() Snacks.picker.projects() end, desc = "Find Projects" },
      -- { "<leader>fr", function() Snacks.picker.recent() end, desc = "Find Recent" },

      -- Git & GitHub
      -- { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
      -- { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
      -- { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log (Line)" },
      -- { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
      -- { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
      -- { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff" },
      -- { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log (File)" },
      -- { "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "GitHub Issues (Open)" },
      -- { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (All)" },
      -- { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub Pull Requests (Open)" },
      -- { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub Pull Requests (All)" },

      -- Grep
      -- { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Buffers" },
      { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
      -- { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Grep Selection/Word", mode = { "n", "x" } },

      -- Search
      -- { '<leader>s"', function() Snacks.picker.registers() end, desc = "Search Registers" },
      -- { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search Search History" },
      -- { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Search Autocmds" },
      -- { "<leader>sb", function() Snacks.picker.lines() end, desc = "Search Buffer Lines" },
      { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Search Command History" },
      -- { "<leader>sC", function() Snacks.picker.commands() end, desc = "Search Commands" },
      -- { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Search Diagnostics" },
      -- { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Search Buffer Diagnostics" },
      { "<leader>sh", function() Snacks.picker.help() end, desc = "Search Help Pages" },
      -- { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Search Highlights" },
      -- { "<leader>si", function() Snacks.picker.icons() end, desc = "Search Icons" },
      -- { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Search Jumps" },
      { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Search Keymaps" },
      -- { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Search Location List" },
      -- { "<leader>sm", function() Snacks.picker.marks() end, desc = "Search Marks" },
      { "<leader>sM", function() Snacks.picker.man() end, desc = "Search Man Pages" },
      { "<leader>sn", function() Snacks.picker.notifications() end, desc = "Search Notification History" },
      { "<leader>sp", function() Snacks.picker.pickers() end, desc = "Search Pickers" },
      -- { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Search Quickfix List" },
      { "<leader>sr", function() Snacks.picker.resume() end, desc = "Resume Search" },
      -- { "<leader>su", function() Snacks.picker.undo() end, desc = "Search Undo History" },
      -- { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Search Colorschemes" },

      -- LSP
      { 'gd', function() Snacks.picker.lsp_definitions({ confirm = vim.o.modified and 'vsplit' or 'jump' }) end, desc = "LSP Definitions" },
      { 'gs', function() Snacks.picker.lsp_definitions({ confirm = 'vsplit' }) end, desc = "LSP Definitions (V-Split)" },
      { 'gS', function() Snacks.picker.lsp_definitions({ confirm = 'split' }) end, desc = "LSP Definitions (H-Split)" },
      { "gD", function() Snacks.picker.lsp_declarations() end, desc = "LSP Declarations" },
      { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "LSP References" },
      { "gi", function() Snacks.picker.lsp_implementations() end, desc = "LSP Implementations" },
      { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "LSP Type Definitions" },
      { "gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "LSP Incoming Calls" },
      { "gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "LSP Outgoing Calls" },
      -- { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
      -- { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },

      -- Other
      -- { "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
      -- { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      -- { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
      { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          _G.dd = function(...) Snacks.debug.inspect(...) end
          _G.bt = function() Snacks.debug.backtrace() end
          vim._print = function(_, ...) dd(...) end

          -- Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          -- Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>n")
          -- Snacks.toggle.diagnostics():map("<leader>ud")
          -- Snacks.toggle.line_number():map("<leader>ul")
          -- Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
          -- Snacks.toggle.treesitter():map("<leader>uT")
          -- Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
          -- Snacks.toggle.inlay_hints():map("<leader>uh")
          -- Snacks.toggle.indent():map("<leader>ug")
          -- Snacks.toggle.dim():map("<leader>uD")
        end,
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

-- vim: sw=2
