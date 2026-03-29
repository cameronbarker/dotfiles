" =============================================================================
" .vimrc — Neovim config template
" =============================================================================
"
" INSTALLATION
" ------------
" 1. Install Neovim:
"      macOS:   brew install neovim
"      Ubuntu:  sudo apt install neovim
"      Fedora:  sudo dnf install neovim
"
" 2. Install vim-plug (plugin manager):
"      sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
"
" 3. Create the Neovim config directory:
"      mkdir -p ~/.config/nvim
"
" 4. Point Neovim at this file — pick one option:
"
"    Option A — From the repo: ./install.sh (symlinks this file to ~/.config/nvim/init.vim)
"
"    Option B — Symlink manually:
"      ln -sf /path/to/repo/.vimrc ~/.config/nvim/init.vim
"
"    Option C — Source from init.vim (keeps your init.vim separate):
"      echo 'source /path/to/repo/.vimrc' > ~/.config/nvim/init.vim
"
" 5. Install plugins (only needed once you uncomment plugins in the Plugins section below):
"
"    Option A — from the terminal (installs and exits automatically):
"      nvim +PlugInstall +qall
"
"    Option B — from inside Neovim (run this command after opening nvim):
"      :PlugInstall
"
"    To update plugins later:  :PlugUpdate
"    To remove unused plugins: :PlugClean
"
" =============================================================================

" -----------------------------------------------------------------------------
" General
" -----------------------------------------------------------------------------
set nocompatible
set encoding=utf-8
set fileencoding=utf-8
set history=1000
set updatetime=300
set timeoutlen=500
set hidden                   " allow switching buffers without saving
set autoread                 " reload files changed outside vim
set clipboard=unnamedplus    " use system clipboard
set mouse=a                  " enable mouse support
set noerrorbells
set noswapfile
set nobackup
set undofile                 " persistent undo
set undodir=~/.vim/undodir

" -----------------------------------------------------------------------------
" UI
" -----------------------------------------------------------------------------
set number                   " line numbers
set relativenumber           " relative line numbers
set cursorline               " highlight current line
set signcolumn=yes           " always show sign column (for git, lsp)
set scrolloff=8              " keep 8 lines above/below cursor
set sidescrolloff=8
set nowrap                   " no line wrapping
set colorcolumn=100          " column ruler
set showcmd
set showmatch                " highlight matching brackets
set wildmenu                 " command completion menu
set wildmode=longest:full,full
set laststatus=2
set splitbelow               " new horizontal splits go below
set splitright               " new vertical splits go right

" -----------------------------------------------------------------------------
" Search
" -----------------------------------------------------------------------------
set incsearch                " search as you type
set hlsearch                 " highlight search results
set ignorecase               " case-insensitive search...
set smartcase                " ...unless uppercase is used

" Clear search highlight
nnoremap <Esc> :nohlsearch<CR>

" -----------------------------------------------------------------------------
" Indentation
" -----------------------------------------------------------------------------
set expandtab                " spaces instead of tabs
set tabstop=2
set shiftwidth=2
set softtabstop=2
set smartindent
set autoindent

" Per-filetype overrides
augroup filetype_indent
  autocmd!
  autocmd FileType python     setlocal tabstop=4 shiftwidth=4 softtabstop=4
  autocmd FileType go         setlocal noexpandtab tabstop=4 shiftwidth=4
  autocmd FileType markdown   setlocal wrap linebreak
augroup END

" -----------------------------------------------------------------------------
" Leader key
" -----------------------------------------------------------------------------
let mapleader = " "
let maplocalleader = " "

" -----------------------------------------------------------------------------
" Key mappings
" -----------------------------------------------------------------------------

" Save / quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>Q :qa!<CR>

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Window resizing
nnoremap <C-Up>    :resize +2<CR>
nnoremap <C-Down>  :resize -2<CR>
nnoremap <C-Left>  :vertical resize -2<CR>
nnoremap <C-Right> :vertical resize +2<CR>

" Buffer navigation
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>
nnoremap <leader>bl :buffers<CR>

" Move lines up/down in visual mode
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Keep cursor centred when jumping
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap n nzzzv
nnoremap N Nzzzv

" Paste without losing register
xnoremap <leader>p "_dP

" Copy to system clipboard
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>Y "+Y

" Delete without yanking
nnoremap <leader>d "_d
vnoremap <leader>d "_d

" Indent in visual mode and stay selected
vnoremap < <gv
vnoremap > >gv

" Quick-edit this file
nnoremap <leader>ev :edit $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

" -----------------------------------------------------------------------------
" File explorer (netrw)
" -----------------------------------------------------------------------------
let g:netrw_banner    = 0
let g:netrw_liststyle = 3    " tree view
let g:netrw_winsize   = 25

nnoremap <leader>e :Lexplore<CR>

" -----------------------------------------------------------------------------
" Plugins (vim-plug)
" Install: https://github.com/junegunn/vim-plug
" Run :PlugInstall after adding plugins
" -----------------------------------------------------------------------------
call plug#begin('~/.vim/plugged')

" Picked for Neovim from apt (0.7+) — avoids Telescope / LSP / gitsigns / lualine
" which need nvim 0.10+.

" -- Fuzzy finding (needs fzf on PATH — install.sh installs it on Debian)
Plug 'junegunn/fzf.vim'

" -- Git
Plug 'tpope/vim-fugitive'

" -- Status line
Plug 'vim-airline/vim-airline'

" -- Colour scheme (Vimscript port; catppuccin/nvim needs newer Neovim)
Plug 'catppuccin/vim', { 'as': 'catppuccin' }

call plug#end()

" fzf.vim — needs ripgrep for :Rg (optional: apt install ripgrep)
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fh :History<CR>
nnoremap <leader>fg :Rg<CR>

" -----------------------------------------------------------------------------
" Colour scheme (uncomment after installing a theme plugin)
" -----------------------------------------------------------------------------
syntax enable
set termguicolors
" catppuccin/vim: catppuccin_mocha, catppuccin_macchiato, catppuccin_frappe, catppuccin_latte
silent! colorscheme catppuccin_mocha

" -----------------------------------------------------------------------------
" Autocommands
" -----------------------------------------------------------------------------
augroup general
  autocmd!
  " Remove trailing whitespace on save
  autocmd BufWritePre * :%s/\s\+$//e
  " Return to last edit position when opening a file
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup END
