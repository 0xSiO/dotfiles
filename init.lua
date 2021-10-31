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
    use 'kyazdani42/nvim-tree.lua'
    use { 'nvim-telescope/telescope.nvim', requires = {'nvim-lua/plenary.nvim'} }

    if PACKER_BOOTSTRAP then
      require('packer').sync()
    end
  end,
  config = { display = { open_fn = require('packer.util').float } }
})

vim.cmd('command Update :PackerSync')

-- Configure LSP servers
-- local servers = { 'rust_analyzer', 'tsserver', 'pyright', 'solargraph' }

-- Configure nvim-tree
local tree_cb = require('nvim-tree.config').nvim_tree_callback
require('nvim-tree').setup({
  auto_close = true,
  filters = { dotfiles = true },
  view = {
    mappings = {
      list = {
        { key = "C", cb = tree_cb("cd") },
        { key = "i", cb = tree_cb("split") },
        { key = "s", cb = tree_cb("vsplit") },
        { key = "R", cb = tree_cb("rename") },
        { key = "r", cb = tree_cb("refresh") },
        { key = "o", cb = tree_cb("system_open") },
        { key = "I", cb = tree_cb("toggle_dotfiles") },
        { key = "?", cb = tree_cb("toggle_help") },
      }
    }
  }
})

vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', {})

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
