syn on

set mouse=a

" select case-insenitive search (not default)
set ignorecase

" show cursor line and column in the status line
set ruler

" show matching brackets
set showmatch

" display mode INSERT/REPLACE/...
set showmode

" Required to be able to use keypad keys and map missed escape sequences
set esckeys

" get easier to use and more user friendly vim defaults
" CAUTION: This option breaks some vi compatibility. 
"          Switch it off if you prefer real vi compatibility
set nocompatible

augroup python
    au!
    au FileType python set ts=4 sw=4 expandtab autoindent smarttab
"    au FileType python source /usr/share/vim/vimfiles/ftplugin/python/python_fn.vim
augroup END

filetype plugin on
set grepprg=grep\ -nH\ $*
