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
set expandtab
set number
set incsearch

call plug#begin('~/.vim/plugged')
Plug 'https://github.com/junegunn/fzf.vim'
Plug 'https://github.com/itchyny/lightline.vim'
Plug 'https://github.com/terryma/vim-multiple-cursors'
Plug 'https://github.com/tpope/vim-surround'
Plug 'https://github.com/scrooloose/nerdtree'
Plug 'https://github.com/airblade/vim-gitgutter'
Plug 'ternjs/tern_for_vim', { 'do' : 'npm install' }
Plug 'https://github.com/ycm-core/YouCompleteMe.git'
Plug 'oblitum/youcompleteme'

call plug#end()


nmap <F6> :NERDTreeToggle<CR>
