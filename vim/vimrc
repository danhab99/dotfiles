set wildmenu
set showcmd
set hlsearch
set ignorecase
set smartcase
set backspace=indent,eol,start
set autoindent
set ruler
set confirm
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
" set ttymouse=xterm2
set scrolloff=15
set clipboard=unnamedplus
set iskeyword-=_
set updatetime=1000
set breakindent
set smartindent

let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

call plug#begin('~/.vim/plugged')
" Plug 'APZelos/blamer.nvim'
" Plug 'SirVer/ultisnips'
" Plug 'ekalinin/Dockerfile.vim'
" Plug 'embear/vim-localvimrc'
" Plug 'honza/vim-snippets'
" Plug 'jparise/vim-graphql'
" Plug 'maxmellon/vim-jsx-pretty'
" Plug 'mfussenegger/nvim-jdtls'
Plug 'sheerun/vim-polyglot'
" Plug 'vim-scripts/sudo.vim'
" Plug 'ycm-core/YouCompleteMe', { 'do': './install.py --all' }
" Plug 'ziglang/zig.vim'
Plug 'alvan/vim-closetag'
Plug 'ap/vim-css-color'
Plug 'apzelos/blamer.nvim'
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'godoctor/godoctor.vim'
Plug 'https://github.com/airblade/vim-gitgutter'
Plug 'https://github.com/ernstwi/vim-secret'
Plug 'https://github.com/itchyny/lightline.vim'
Plug 'https://github.com/scrooloose/nerdtree'
Plug 'https://github.com/terryma/vim-multiple-cursors'
Plug 'https://github.com/tpope/vim-surround'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'matze/vim-move'
Plug 'mbbill/undotree'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'pbrisbin/vim-mkdir'
Plug 'prisma/vim-prisma' 
Plug 'sbdchd/neoformat'
Plug 'ternjs/tern_for_vim', { 'do' : 'npm install', 'for': 'javascript' }
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive' 
Plug 'vim-scripts/SyntaxAttr.vim'
Plug 'wellle/context.vim'

call plug#end()

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" Plugin 'christoomey/vim-titlecase'
" Plugin 'ericcurtin/VimBlame.vim'
" Plugin 'hashivim/vim-terraform'
" Plugin 'leafgarland/typescript-vim'
Plugin 'HerringtonDarkholme/yats.vim'
Plugin 'alvan/vim-closetag'
Plugin 'ebnf.vim'
Plugin 'joshdick/onedark.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'majutsushi/tagbar'
Plugin 'puremourning/vimspector'
Plugin 'starcraftman/vim-eclim'

call vundle#end()

syntax on 

" colorscheme desert256
colorscheme onedark
let g:onedark_termcolors=256

let g:go_highlight_array_whitespace_error = 1
let g:go_highlight_chan_whitespace_error = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_space_tab_error = 1
let g:go_highlight_trailing_whitespace_error = 1
let g:go_highlight_operators = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_string_spellcheck = 1
let g:go_highlight_format_strings = 1
let g:go_highlight_variable_declarations = 1
let g:go_highlight_variable_assignments = 1
let g:go_highlight_diagnostic_errors = 1
let g:go_highlight_diagnostic_warnings = 1
let g:go_fold_enable = ['block', 'import', 'varconst', 'package_comment']

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
let g:tagbar_sort=0

augroup fmt
  " autocmd!
  " autocmd BufWritePre *.js,*.ts*,*.py,*.go,*.html,*.css Neoformat
  " autocmd BufWritePre *.ts* Neoformat prettier
  " autocmd BufWritePre *.java Neoformat astyle
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
nmap <C-f> :Neoformat<CR>
imap <C-f> <Esc>:Neoformat<CR>i
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
nmap <C-r> :source ~/.vimrc<CR>:CocRestart<CR>
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

nmap <leader>gt <Plug>Titlecase
vmap <leader>gt <Plug>Titlecase
nmap <leader>gT <Plug>TitlecaseLine
nmap <leader>t :TagbarToggle<CR>
nmap <leader>d :CocDiagnostic<CR>
nmap <leader>r :GoRename<CR>

nmap <C-q> :wqa<CR>
