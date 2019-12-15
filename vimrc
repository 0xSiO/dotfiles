call plug#begin('~/.vim/bundle')

Plug 'itchyny/lightline.vim'
Plug 'altercation/vim-colors-solarized'
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'tpope/vim-commentary'
Plug 'neomake/neomake'
Plug 'sheerun/vim-polyglot'
Plug 'ervandew/supertab'
Plug 'Valloric/YouCompleteMe'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'tpope/vim-bundler'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'

call plug#end()

" lightline
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'component': {
      \   'readonly': '%{&readonly?"":""}',
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }
set noshowmode

" vim-colors-solarized
set background=dark
colorscheme solarized
let g:solarized_termcolors = 256
highlight EndOfBuffer ctermfg=black ctermbg=none

" nerdtree
map <C-n> :NERDTreeTabsToggle<CR>

" vim-polyglot
let g:ruby_fold = 1
let g:rustfmt_autosave = 1
let g:rust_fold = 1

" neomake
" autocmd! BufWritePost * Neomake

" supertab
let g:SuperTabDefaultCompletionType = '<C-n>'

" YouCompleteMe
map <C-g> :YcmCompleter GoTo<CR>
imap <C-g> <Esc>:YcmCompleter GoTo<CR>
let g:ycm_key_list_select_completion = ['<C-j>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-k>', '<Up>']
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/.ycm_extra_conf.py'

" ultisnips
let g:UltiSnipsExpandTrigger = "<Tab>"
let g:UltiSnipsJumpForwardTrigger = "<Tab>"
let g:UltiSnipsJumpBackwardTrigger = "<S-Tab>"

" Other config options
set number
set mouse=a mousemodel=popup
command W w !sudo tee % > /dev/null
noremap <Space> za
map <M-t> :below new<CR>:terminal<CR>

set foldlevel=1
set expandtab shiftwidth=4 tabstop=4
autocmd FileType ruby setlocal shiftwidth=2 tabstop=2
autocmd FileType crystal setlocal shiftwidth=2 tabstop=2
