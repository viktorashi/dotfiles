silent! packadd vim-obsession

if exists('g:ai_os_obsession_loaded')
  finish
endif
let g:ai_os_obsession_loaded = 1

function! s:in_git_repo() abort
  return !empty(findfile('.git', '.;')) || !empty(finddir('.git', '.;'))
endfunction

function! s:start_obsession() abort
  if !s:in_git_repo()
    return
  endif

  silent! Obsession Session.vim
endfunction

call s:start_obsession()
