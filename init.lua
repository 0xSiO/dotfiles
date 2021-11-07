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
    use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } }
    use 'tpope/vim-fugitive'
    use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }
    use { 'nvim-lualine/lualine.nvim', requires = { 'kyazdani42/nvim-web-devicons' } }
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use { 'neoclide/coc.nvim', branch = 'release' }
    use 'honza/vim-snippets'
    use 'tpope/vim-commentary'
    use 'jiangmiao/auto-pairs'
    use 'machakann/vim-sandwich'

    if PACKER_BOOTSTRAP then
      require('packer').sync()
    end
  end,
  config = { display = { open_fn = require('packer.util').float } }
})

vim.cmd('command Update :PackerSync')

-- Configure NERDTree
vim.api.nvim_set_keymap('n', '<C-n>', ':NERDTreeToggle<CR>', map_opts)
vim.g['NERDTreeMinimalUI'] = true
vim.cmd("autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif")
-- This skips vim-sandwich in NERDTree
vim.cmd("autocmd FileType nerdtree nnoremap <buffer><nowait> s :call nerdtree#ui_glue#invokeKeyMap('s')<CR>")

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

-- Configure lualine
require('lualine').setup({
  options = { theme = 'jellybeans' },
  sections = {
    lualine_b = {
      'branch', 'diff', 
      {
        'diagnostics', sources = { 'coc' },
        diagnostics_color = {
          warn = { fg = '#ECBE7B' },
          info = { fg = '#FFFFFF' },
          hint = { fg = '#98be65' }
        }
      },
    },
    lualine_c = { { 'filename', path = 1 }, 'g:coc_status' }
  }
})

-- Configure nvim-treesitter
require('nvim-treesitter.configs').setup({
  ensure_installed = 'maintained',
  highlight = { enable = true },
  indent = { enable = true },
})

vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
vim.wo.foldlevel = 1

-- Configure coc.nvim
vim.g['coc_global_extensions'] = {
  'coc-snippets', 'coc-prettier', 'coc-tsserver', 'coc-solargraph', 'coc-rust-analyzer', 'coc-pyright', 'coc-json'
}
vim.cmd('source ~/.dotfiles/coc.vim')

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
vim.o.updatetime = 200
vim.o.hidden = true
vim.o.showmode = false

-- Window options
vim.wo.number = true

-- Buffer options
vim.bo.expandtab = true
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4

-- Keybindings
vim.api.nvim_set_keymap('n', '<M-t>', ':vnew<CR>:terminal<CR>i', map_opts)
vim.api.nvim_set_keymap('!', '<C-j>', '<C-n>', map_opts)
vim.api.nvim_set_keymap('!', '<C-k>', '<C-p>', map_opts)
vim.api.nvim_set_keymap('', '<C-j>', '<C-n>', map_opts)
vim.api.nvim_set_keymap('', '<C-k>', '<C-p>', map_opts)

-- Commands
vim.cmd('command W :w')
vim.cmd('command Q :q')
vim.cmd('command Qa :qa')
vim.cmd('command QA :qa')
