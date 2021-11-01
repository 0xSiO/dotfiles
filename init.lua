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
    use 'tpope/vim-commentary'

    if PACKER_BOOTSTRAP then
      require('packer').sync()
    end
  end,
  config = { display = { open_fn = require('packer.util').float } }
})

vim.cmd('command Update :PackerSync')

-- Configure LSP servers
-- local servers = { 'rust_analyzer', 'tsserver', 'pyright', 'solargraph' }

-- Configure NERDTree
vim.api.nvim_set_keymap('n', '<C-n>', ':NERDTreeToggle<CR>', {})
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

vim.api.nvim_set_keymap('n', 'ff', ':Telescope find_files<CR>', {})
vim.api.nvim_set_keymap('n', 'fg', ':Telescope live_grep<CR>', {})
vim.api.nvim_set_keymap('n', 'fh', ':Telescope help_tags<CR>', {})

-- Configure vim-fugitive
vim.api.nvim_set_keymap('n', '<leader>gd', ':Gvdiffsplit<CR>', {})
vim.api.nvim_set_keymap('n', '<leader>b', ':Git blame<CR>', {})

-- Configure gitsigns
require('gitsigns').setup()
vim.api.nvim_set_keymap('n', '<leader>d', ':lua require("gitsigns").preview_hunk()<CR>', {})

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
vim.api.nvim_set_keymap('n', '<M-t>', ':vnew<CR>:terminal<CR>i', {})

-- Commands
vim.cmd('command W :w')
vim.cmd('command Q :q')
vim.cmd('command Qa :qa')
vim.cmd('command QA :qa')
