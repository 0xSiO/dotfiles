call plug#begin('~/.vim/bundle')

Plug 'itchyny/lightline.vim'
Plug 'sainnhe/edge'
Plug 'preservim/nerdtree'
Plug 'tpope/vim-commentary'
Plug 'mhinz/vim-signify'
" coc extensions: snippets, solargraph, rust-analyzer, json, prettier, tsserver
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'honza/vim-snippets'
Plug 'tpope/vim-surround'
Plug 'raimondi/delimitmate'
Plug 'airblade/vim-rooter'

call plug#end()

" lightline
let g:lightline = {
      \ 'colorscheme': 'jellybeans',
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

" edge
set background=dark
colorscheme edge
highlight EndOfBuffer ctermfg=black ctermbg=none

" nerdtree
map <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" vim-signify
nmap <leader>d :SignifyHunkDiff<CR>

" coc.nvim
source ~/.dotfiles/coc.vim

" delimitmate
let delimitMate_expand_cr = 1
let delimitMate_expand_space = 1
let delimitMate_jump_expansion = 1

" Other config options
set number
set mouse=a
map <M-t> :below new<CR>:terminal<CR>
let g:python3_host_prog = '~/.pyenv/versions/3.9.0/bin/python'

set foldmethod=syntax
" set foldnestmax=2
set foldlevel=1
set expandtab shiftwidth=4 tabstop=4
autocmd FileType ruby setlocal shiftwidth=2 tabstop=2
autocmd FileType crystal setlocal shiftwidth=2 tabstop=2

" Enhancements from Jon Gjengset's vimrc
if executable('rg')
    set grepprg=rg\ --no-heading\ --vimgrep
endif

nnoremap <up> <nop>
nnoremap <down> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

set undodir=~/.dotfiles/vimdid
set undofile
