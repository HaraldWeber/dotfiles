
"use the cygwin shell only in windows/cygwin
if has("gui_win32")
    set shell=C:/cygwin/bin/bash
    set shellcmdflag=--login\ -c
    set shellxquote=\"
endif

set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar

" set fonts
if has("gui_running")
  if has("gui_gtk2")
    set guifont=Inconsolata\ 11
  elseif has("gui_macvim")
    set guifont=Menlo\ Regular:h12
  elseif has("gui_win32")
    set guifont=Consolas:h10:cANSI
  endif
endif
