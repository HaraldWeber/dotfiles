set encoding=utf-8
syntax on

autocmd! bufwritepost .vimrc source % " reload config on change
set autoread     " reload files when changed
set number       " show line numbers
set bs=2         " normal backspace
inoremap kj <Esc>`^ " Easy escape without cursor movement

" Disable backup and swap files
set nobackup
set nowritebackup
set noswapfile

" make yank copy to the global system clipboard (linux)
set clipboard=unnamedplus

" make yank copy to the global system clipboard (windows)
" set clipboard=unnamed

" bigger history
set history=1000
set undolevels=1000

" set tab sizes
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smartindent
set shiftround
set expandtab

" Reselect visual block after indent/outdent
vnoremap < <gv
vnoremap > >gv

" Show NERDTree if vim is started without an file as argument
"autocmd VimEnter * if !argc() | NERDTree | endif

" enable mouse support
set mouse=a

" solarized dark color theme
set background=dark
let g:solarized_termcolors=256
colorscheme solarized

" disable Background Color Erase (wrong colors in tmux)
set t_ut=

" enable hidden buffers
set hidden

" <Ctrl-l> redraws the screen and removes any search highlighting.
nnoremap <silent> <C-l> :nohl<CR><C-l>

" <Ctrl-c> deletes the current buffer without closing a split.
nnoremap <C-c> :bp\|bd #<CR>

" Don't break words on a line break
set linebreak

" write as root with sudo :w!!. Type fast
cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

" Search in subdirectories
set path+=**
