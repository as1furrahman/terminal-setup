" ~/.vimrc
" Vim Configuration (Sensible Defaults)
" Part of: Cross-Distro Terminal Setup

" ============================================================================
" General Settings
" ============================================================================
set nocompatible              " Disable Vi compatibility
filetype plugin indent on     " Enable filetype detection
syntax enable                 " Enable syntax highlighting

" Encoding
set encoding=utf-8
set fileencoding=utf-8

" ============================================================================
" UI Settings
" ============================================================================
set number                    " Show line numbers
set relativenumber            " Relative line numbers
set cursorline                " Highlight current line
set showmatch                 " Highlight matching brackets
set showcmd                   " Show command in status line
set showmode                  " Show current mode
set ruler                     " Show cursor position
set wildmenu                  " Enhanced command-line completion
set wildmode=list:longest     " Complete files like shell
set laststatus=2              " Always show status line
set signcolumn=yes            " Always show sign column

" Scrolling
set scrolloff=8               " Keep 8 lines above/below cursor
set sidescrolloff=8           " Keep 8 columns left/right of cursor

" ============================================================================
" Indentation
" ============================================================================
set autoindent                " Copy indent from current line
set smartindent               " Smart autoindenting
set expandtab                 " Use spaces instead of tabs
set tabstop=4                 " Tab = 4 spaces
set shiftwidth=4              " Indent = 4 spaces
set softtabstop=4             " Backspace through spaces

" ============================================================================
" Search
" ============================================================================
set incsearch                 " Incremental search
set hlsearch                  " Highlight search results
set ignorecase                " Case insensitive search
set smartcase                 " Case sensitive if uppercase used

" ============================================================================
" Performance & Files
" ============================================================================
set hidden                    " Allow hidden buffers
set nobackup                  " No backup files
set nowritebackup             " No backup while writing
set noswapfile                " No swap files
set updatetime=300            " Faster completion
set timeoutlen=500            " Faster key sequences

" ============================================================================
" Mouse & Clipboard
" ============================================================================
set mouse=a                   " Enable mouse in all modes
set clipboard=unnamedplus     " Use system clipboard

" ============================================================================
" Splits
" ============================================================================
set splitright                " New vertical splits to the right
set splitbelow                " New horizontal splits below

" ============================================================================
" Key Mappings
" ============================================================================
" Set leader key to space
let mapleader = " "

" Quick save
nnoremap <leader>w :w<CR>

" Quick quit
nnoremap <leader>q :q<CR>

" Clear search highlight
nnoremap <Esc> :nohlsearch<CR>

" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Move lines up/down in visual mode
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Stay in visual mode after indenting
vnoremap < <gv
vnoremap > >gv

" Buffer navigation
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>

" ============================================================================
" Netrw (Built-in file explorer)
" ============================================================================
let g:netrw_banner = 0        " Hide banner
let g:netrw_liststyle = 3     " Tree view
let g:netrw_browse_split = 4  " Open in previous window
let g:netrw_winsize = 25      " 25% width

" Toggle netrw
nnoremap <leader>e :Lexplore<CR>

" ============================================================================
" Auto Commands
" ============================================================================
augroup MyAutoCommands
    autocmd!
    " Remove trailing whitespace on save
    autocmd BufWritePre * :%s/\s\+$//e
    " Return to last edit position
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup END

" ============================================================================
" Status Line (basic)
" ============================================================================
set statusline=%f               " File path
set statusline+=\ %m            " Modified flag
set statusline+=\ %r            " Readonly flag
set statusline+=%=              " Right align
set statusline+=\ %y            " File type
set statusline+=\ %l:%c         " Line:Column
set statusline+=\ %p%%          " Percentage through file
