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
set belloff=all
set t_Co=256
"set t_AB=^[[48;5;%dm
"set t_AF=^[[38;5;%dm
set ttymouse=xterm2

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
Plug 'sbdchd/neoformat'
Plug 'ziglang/zig.vim'
Plug 'alvan/vim-closetag'
Plug 'ekalinin/Dockerfile.vim'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'SirVer/ultisnips'
Plug 'mlaursen/vim-react-snippets'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'leafgarland/typescript-vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'apzelos/blamer.nvim'
Plug 'vim-scripts/sudo.vim'

call plug#end()

call vundle#begin()
Plugin 'alvan/vim-closetag'
Plugin 'joshdick/onedark.vim'

call vundle#end()

colorscheme desert256
" colorscheme onedark

let NERDTreeQuitOnOpen=1

let g:closetag_regions = {
    \ 'typescript.tsx': 'jsxRegion,tsxRegion',
    \ 'javascript.jsx': 'jsxRegion',
    \ 'typescriptreact': 'jsxRegion,tsxRegion',
    \ 'javascriptreact': 'jsxRegion',
    \ }

let g:closetag_filenames = "*.html,*.xhtml,*.phtml,*.php,*.jsx,*.tsx"

let g:ycm_semantic_triggers = {
   \   'css': [ 're!^\s{2}', 're!:\s+' ],
   \ }
let g:UltiSnipsExpandTrigger="<leader><space>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

"autocmd BufWritePost * scilent! Neoformat prettier
autocmd BufWritePre * silent! Neoformat prettier

hi SignColumn guibg=darkgrey ctermbg=NONE
hi SpellBad term=reverse ctermbg=52 gui=undercurl guisp=Red
"hi Visual ctermbg=White term=reverse
hi Normal guibg=NONE ctermbg=NONE

nmap <F6> :NERDTreeToggle<CR>
nmap O O<Esc>o
imap jj <Esc>
nnoremap <leader>p :psearch <C-R><C-W><CR>
nnoremap <silent> <Leader>+ :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> <Leader>- :exe "resize " . (winheight(0) * 2/3)<CR>
nnoremap <space> :noh<CR>:w<CR>

