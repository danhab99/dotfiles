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
set smarttab
set completeopt-=preview
set laststatus=2
set belloff=all
set t_Co=256
"set t_AB=^[[48;5;%dm
"set t_AF=^[[38;5;%dm
set ttymouse=xterm2
set scrolloff=15
set clipboard=unnamedplus
set iskeyword-=_
set updatetime=1000

call plug#begin('~/.vim/plugged')
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'https://github.com/itchyny/lightline.vim'
Plug 'https://github.com/terryma/vim-multiple-cursors'
Plug 'https://github.com/tpope/vim-surround'
Plug 'https://github.com/scrooloose/nerdtree'
Plug 'https://github.com/airblade/vim-gitgutter'
Plug 'ternjs/tern_for_vim', { 'do' : 'npm install', 'for': 'javascript' }
" Plug 'ycm-core/YouCompleteMe', { 'do': './install.py --all' }
Plug 'https://github.com/ernstwi/vim-secret'
Plug 'sbdchd/neoformat'
Plug 'ziglang/zig.vim'
Plug 'alvan/vim-closetag'
Plug 'ekalinin/Dockerfile.vim'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'SirVer/ultisnips'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive' 
Plug 'apzelos/blamer.nvim'
Plug 'vim-scripts/sudo.vim'
Plug 'sheerun/vim-polyglot'
Plug 'vim-scripts/SyntaxAttr.vim'
Plug 'mbbill/undotree'
Plug 'pbrisbin/vim-mkdir'
Plug 'matze/vim-move'
Plug 'pantharshit00/vim-prisma'
Plug 'jparise/vim-graphql'
Plug 'APZelos/blamer.nvim'
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'godoctor/godoctor.vim'
Plug 'junegunn/goyo.vim'
Plug 'embear/vim-localvimrc'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'alvan/vim-closetag'
Plugin 'joshdick/onedark.vim'
Plugin 'ericcurtin/VimBlame.vim'
Plugin 'HerringtonDarkholme/yats.vim'
Plugin 'leafgarland/typescript-vim'
Plugin 'kien/ctrlp.vim'
Plugin 'puremourning/vimspector'

Bundle 'nikvdp/ejs-syntax'

call vundle#end()

syntax on 

" colorscheme desert256
colorscheme onedark

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
let g:python_recommended_style = 0
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_custom_ignore = '\v[\/](node_modules)$'
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }
let g:ycm_always_populate_location_list = 1
let g:vimspector_enable_mappings = 'HUMAN'
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

augroup fmt
  autocmd!
  " autocmd BufWritePre *.js,*.ts*,*.py,*.go,*.html,*.css Neoformat
  autocmd BufWritePre *.ts* Neoformat prettier
  " autocmd BufWritePre *.java Neoformat uncrustify
augroup END
" autocmd BufEnter * lcd %:p:h
au BufNewFile,BufRead *.ejs set filetype=html
autocmd CursorHold * silent call CocActionAsync('doHover')

hi SignColumn guibg=darkgrey ctermbg=NONE
hi SpellBad term=reverse ctermbg=52 gui=undercurl guisp=Red
"hi Visual ctermbg=White term=reverse
hi Normal guibg=NONE ctermbg=NONE
hi VGrepFileName ctermfg=green
hi VGrepLine ctermfg=red

nmap <C-o> :NERDTreeToggle<CR>
nmap <C-u> :UndotreeToggle<CR>
nmap <C-f> :Neoformat prettier<CR>
nmap O O<Esc>o
imap jj <Esc>
imap kk <Esc>
nnoremap <leader>p :psearch <C-R><C-W><CR>
nnoremap <silent> <Leader>+ :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> <Leader>- :exe "resize " . (winheight(0) * 2/3)<CR>
nnoremap <space> :noh<CR>:w<CR>
map -a :call SyntaxAttr()<CR>
nmap <C-t> :tab sp<CR>
nmap <C-z> mq:wqa<CR>
nmap <C-r> :source ~/.vimrc<CR>:YcmRestartServer<CR>
nmap <C-s> :Rg<CR>
nmap <C-h> <C-^>
nmap yc yygccp
nnoremap gg mggg
nnoremap G mgG
nnoremap gm <C-w>wj<CR>
nnoremap i mii
nnoremap I miI
nnoremap a mia
nnoremap A miA
nnoremap o mio
nmap ym myyy'mp
imap <leader>pe if err != nil { panic (err) }<CR>
nmap <leader>m :set mouse=<CR>
nmap <leader>M :set mouse=a<CR>
inoremap <silent><expr> <c-space> coc#refresh()

"" COC
" Use <c-space> to trigger completion
inoremap <silent><expr> <c-@> coc#refresh()
inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> <leader>h :call CocActionAsync('doHover')<cr>
