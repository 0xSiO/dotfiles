call plug#begin('~/.vim/bundle')

Plug 'itchyny/lightline.vim'
Plug 'altercation/vim-colors-solarized'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-commentary'
Plug 'airblade/vim-gitgutter'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'honza/vim-snippets'
Plug 'tpope/vim-bundler'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'

call plug#end()

" lightline
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
	  \             [ 'cocstatus', 'readonly', 'absolutepath', 'modified' ] ]
      \ },
      \ 'component': {
      \   'readonly': '%{&readonly?"":""}',
      \ },
      \ 'component_function': {
      \   'cocstatus': 'coc#status'
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
set noshowmode

" vim-colors-solarized
set background=dark
colorscheme solarized
let g:solarized_termcolors = 256
highlight EndOfBuffer ctermfg=black ctermbg=none

" nerdtree
map <C-n> :NERDTreeToggle<CR>

" coc.nvim
source ~/.dotfiles/coc.vim

" Other config options
set number
set mouse=a mousemodel=popup
command W w !sudo tee % > /dev/null
noremap <Space> za
map <M-t> :below new<CR>:terminal<CR>
let g:python3_host_prog = '~/.pyenv/versions/3.8.0/bin/python'

set foldmethod=syntax
" set foldnestmax=2
set foldlevel=1
set expandtab shiftwidth=4 tabstop=4
autocmd FileType ruby setlocal shiftwidth=2 tabstop=2
autocmd FileType crystal setlocal shiftwidth=2 tabstop=2
