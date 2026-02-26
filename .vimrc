set encoding=utf-8
syntax on

autocmd! bufwritepost .vimrc source % " reload config on change

" Auto-reload externally changed files when Vim regains focus or buffer is entered
set autoread     " reload files when changed
augroup AutoReload
    autocmd!
    autocmd FocusGained,BufEnter,CursorHold,CursorHoldI,CursorMoved,InsertEnter * checktime
augroup END

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

" Save the file if switching to another file (only named non-ephemeral buffers)
autocmd BufLeave * if !empty(bufname('%')) && bufname('%') !~# '^' . g:session_dir | silent write | endif

" -------------------------------------------------------------
" Session handling like vscode
" -------------------------------------------------------------
" Directory where ephemeral session files live
let g:session_dir = expand("$HOME/.cache/vim/unsaved")

if !isdirectory(g:session_dir)
    call mkdir(g:session_dir, "p")
endif

" -------------------------------------------------------------
" 1. On startup (no files passed): open all files in session dir
" -------------------------------------------------------------
function! s:LoadSessionFiles()
    let files = glob(g:session_dir . "/*", 0, 1)
    if empty(files)
        enew
    else
        for f in files
            execute "edit " . fnameescape(f)
        endfor
    endif
endfunction

" -------------------------------------------------------------
" 2. Helper: get next Untitled-N filename
" -------------------------------------------------------------
function! s:NextEphemeralName()
    let files = glob(g:session_dir . "/Untitled-*.txt", 0, 1)
    let max = 0
    for f in files
        let m = matchlist(f, 'Untitled-\(\d\+\)\.txt')
        if len(m) > 1
            let n = str2nr(m[1])
            if n > max | let max = n | endif
        endif
    endfor
    return g:session_dir . "/Untitled-" . (max + 1) . ".txt"
endfunction

" -------------------------------------------------------------
" 3. Save an unnamed buffer to the session dir (on demand)
" -------------------------------------------------------------
function! s:SaveEphemeral()
    if &buftype !=# '' | return | endif
    if expand('%') !=# '' | return | endif
    " Only save if the buffer actually has content
    if line('$') == 1 && getline(1) ==# '' | return | endif

    let name = s:NextEphemeralName()
    execute "silent write " . fnameescape(name)
    execute "silent file " . fnameescape(name)
endfunction

" -------------------------------------------------------------
" 4. On VimLeavePre: persist all unnamed buffers that have content
" -------------------------------------------------------------
function! s:PersistAllEphemeral()
    let cur = bufnr('%')
    for b in range(1, bufnr('$'))
        if !bufexists(b) || !buflisted(b) | continue | endif
        if getbufvar(b, '&buftype') !=# '' | continue | endif
        " Already named (either a real file or previously saved ephemeral)
        if bufname(b) !=# ''
            " If it's an ephemeral file, just re-save it
            if bufname(b) =~# '^' . g:session_dir
                execute 'buffer ' . b
                silent write
            endif
            continue
        endif
        " Unnamed buffer — check if it has content
        let lines = getbufline(b, 1, '$')
        if len(lines) == 1 && lines[0] ==# '' | continue | endif
        execute 'buffer ' . b
        call s:SaveEphemeral()
    endfor
    " Restore original buffer
    if bufexists(cur)
        execute 'buffer ' . cur
    endif
endfunction

" -------------------------------------------------------------
" 5. Delete underlying file when buffer closes
" -------------------------------------------------------------
function! s:DeleteEphemeralFile(file)
    if a:file =~# '^' . g:session_dir
        call delete(a:file)
    endif
endfunction

" --- Session Autocommands --------------------------------------
augroup EphemeralFiles
    autocmd!

    " Load unsaved session files on startup
    autocmd VimEnter * if argc() == 0 | call s:LoadSessionFiles() | endif

    " When leaving a named ephemeral buffer, silently save it
    autocmd BufLeave * if expand('%') =~# '^' . g:session_dir | silent write | endif

    " When leaving an unnamed buffer, save it if it has content
    autocmd BufLeave * call s:SaveEphemeral()

    " Before quitting, persist all unnamed buffers with content
    autocmd VimLeavePre * call s:PersistAllEphemeral()

    " Also save named ephemeral buffers before quitting
    autocmd QuitPre * if expand('%') =~# '^' . g:session_dir | silent write | endif

    " Delete underlying file when buffer is explicitly closed
    autocmd BufDelete * call s:DeleteEphemeralFile(expand('<afile>'))

augroup END
" -------------------------------------------------------------
" -------------------------------------------------------------
