set wildmenu
set showcmd
set hlsearch
set ignorecase
set smartcase
set backspace=indent,eol,start
set autoindent
set ruler
set confirm
set mouse=a
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
set number
set incsearch
set clipboard=unnamedplus
set smarttab
set mouse=v
set completeopt-=preview
set laststatus=2

call plug#begin('~/.vim/plugged')
Plug 'https://github.com/junegunn/fzf.vim'
Plug 'https://github.com/itchyny/lightline.vim'
Plug 'https://github.com/terryma/vim-multiple-cursors'
Plug 'https://github.com/tpope/vim-surround'
Plug 'https://github.com/scrooloose/nerdtree'
Plug 'https://github.com/airblade/vim-gitgutter'
Plug 'ternjs/tern_for_vim', { 'do' : 'npm install', 'for': 'javascript' }
Plug 'ycm-core/YouCompleteMe', { 'do': './install.py --all' }
Plug 'https://github.com/ernstwi/vim-secret'
Plug 'preservim/nerdcommenter'
Plug 'sbdchd/neoformat'
Plug 'ziglang/zig.vim'

call plug#end()

colorscheme slate

let NERDTreeQuitOnOpen=1

autocmd BufWritePost * Neoformat prettier

hi SignColumn ctermbg=none
hi SpellBad term=reverse ctermbg=52 gui=undercurl guisp=Red
"hi Visual ctermbg=White term=reverse
hi Normal guibg=NONE ctermbg=NONE

let g:ycm_semantic_triggers = {
   \   'css': [ 're!^\s{2}', 're!:\s+' ],
   \ }

nmap <F6> :NERDTreeToggle<CR>
nmap O O<Esc>o
imap jj <Esc>
imap qq :q
nnoremap <leader>p :psearch <C-R><C-W><CR>
nnoremap <silent> <Leader>+ :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> <Leader>- :exe "resize " . (winheight(0) * 2/3)<CR>

autocmd InsertLeave * Neoformat
