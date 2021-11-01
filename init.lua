local map_opts = { noremap = true, silent = true }

-- Install packer
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

-- Configure packer
require('packer').startup({
  function(use)
    use 'wbthomason/packer.nvim'
    use 'sainnhe/edge'
    use 'preservim/nerdtree'
    use { 'nvim-telescope/telescope.nvim', requires = {'nvim-lua/plenary.nvim'} }
    use 'tpope/vim-fugitive'
    use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use 'neovim/nvim-lspconfig'
    use 'williamboman/nvim-lsp-installer'
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'onsails/lspkind-nvim'
    use 'saadparwaiz1/cmp_luasnip'
    use 'L3MON4D3/LuaSnip'
    use 'tpope/vim-commentary'

    if PACKER_BOOTSTRAP then
      require('packer').sync()
    end
  end,
  config = { display = { open_fn = require('packer.util').float } }
})

vim.cmd('command Update :PackerSync')

-- Configure nvim-treesitter
require('nvim-treesitter.configs').setup({
  ensure_installed = 'maintained',
  highlight = { enable = true },
  indent = { enable = true },
})

vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
vim.wo.foldlevel = 1

-- Configure nvim-cmp
local luasnip = require('luasnip')
local lspkind = require('lspkind')
local cmp = require('cmp')
cmp.setup({
  formatting = { format = lspkind.cmp_format({ with_text = false, maxwidth = 50 }) },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    ['<C-j>'] = cmp.mapping.select_next_item(),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
})

-- Configure LSP servers
local servers = { 'rust_analyzer', 'tsserver', 'pyright', 'solargraph', 'sumneko_lua' }

local lsp_installer_servers = require('nvim-lsp-installer.servers')
for _, server_name in ipairs(servers) do
  local ok, server = lsp_installer_servers.get_server(server_name)
  if ok then
      if not server:is_installed() then
          server:install()
      end
  end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
require('nvim-lsp-installer').on_server_ready(function (server) server:setup { capabilities = capabilities } end)

-- Configure NERDTree
vim.api.nvim_set_keymap('n', '<C-n>', ':NERDTreeToggle<CR>', map_opts)
vim.g['NERDTreeMinimalUI'] = true
vim.cmd("autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif")

-- Configure telescope
require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ['<C-j>'] = 'move_selection_next',
        ['<C-k>'] = 'move_selection_previous',
        ['<Esc>'] = 'close',
      }
    }
  }
})

vim.api.nvim_set_keymap('n', 'ff', ':Telescope find_files<CR>', map_opts)
vim.api.nvim_set_keymap('n', 'fg', ':Telescope live_grep<CR>', map_opts)
vim.api.nvim_set_keymap('n', 'fh', ':Telescope help_tags<CR>', map_opts)

-- Configure vim-fugitive
vim.api.nvim_set_keymap('n', '<leader>gd', ':Gvdiffsplit<CR>', map_opts)
vim.api.nvim_set_keymap('n', '<leader>b', ':Git blame<CR>', map_opts)

-- Configure gitsigns
require('gitsigns').setup()
vim.api.nvim_set_keymap('n', '<leader>d', ':lua require("gitsigns").preview_hunk()<CR>', map_opts)

-- Color scheme
vim.o.termguicolors = true
vim.o.background = 'dark'
vim.cmd('colorscheme edge')

-- Global options
vim.o.mouse = 'a'
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.undofile = true
vim.o.updatetime = 300
vim.o.hidden = true

-- Window options
vim.wo.number = true

-- Buffer options
vim.bo.expandtab = true
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4

-- Keybindings
vim.api.nvim_set_keymap('n', '<M-t>', ':vnew<CR>:terminal<CR>i', map_opts)

-- Commands
vim.cmd('command W :w')
vim.cmd('command Q :q')
vim.cmd('command Qa :qa')
vim.cmd('command QA :qa')
