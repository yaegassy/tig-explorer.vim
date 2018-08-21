"=============================================================================
" File: tig_explorer.vim
" Author: iberianpig
" Created: 2017-04-03
"=============================================================================

scriptencoding utf-8

if !exists('g:loaded_tig_explorer')
  finish
endif
let g:loaded_tig_explorer = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:tig_explorer_orig_tigrc')
  " TODO: " set '$XDG_CONFIG_HOME/tig/config, ~/.config/tig/config, ~/.tigrc', /etc/tigrc
  let g:tig_explorer_orig_tigrc='~/.tigrc'
endif

let s:tmp_tigrc = tempname()
let s:path_file = tempname()
let s:before_exec_tig  = expand('<sfile>:p:h:h') . '/script/setup_tmp_tigrc.sh'
      \ . ' ' . g:tig_explorer_orig_tigrc
      \ . ' ' . s:tmp_tigrc
      \ . ' ' . s:path_file
let s:tig_command = 'TIGRC_USER=' . s:tmp_tigrc . ' tig '

function! s:project_root_dir()
  let current_dir = expand('%:p:h')
  let relative_git_dir = finddir('.git', current_dir . ';') 
  let root_dir = fnamemodify(relative_git_dir, ':h')
  if !isdirectory(root_dir)
    return current_dir
  endif
  return root_dir
endfunction

function! s:open_file() abort
  if filereadable(s:path_file)
    exec system('cat ' . s:path_file)
    call system('rm ' . s:path_file)
  endif
  redraw!
endfunction

function! tig_explorer#call(str) abort
  if !executable('tig')
    echoerr 'You need to install tig.'
    return
  endif
  exec 'silent !' . s:before_exec_tig
  exec 'silent !' . s:tig_command . a:str
  :call s:open_file()
endfunction

function! tig_explorer#open(path)
  if !executable('tig')
    echoerr 'You need to install tig.'
    return
  endif
  exec 'silent !' . s:before_exec_tig
  exec 'silent !' . s:tig_command . a:path
  :call s:open_file()
endfunction

function! tig_explorer#open_current_file() abort
  let current_path = expand('%:p')
  :call tig_explorer#open(current_path)
endfunction

function! tig_explorer#open_project_root_dir() abort
  let root_dir = s:project_root_dir()
  :call tig_explorer#open(root_dir)
endfunction

function! tig_explorer#grep(str) abort
  if !executable('tig')
    echoerr 'You need to install tig.'
    return
  endif
  if a:str == ""
    let word = input("Pattern: ")
  else
    let word = a:str
  endif
  let g:tig_explorer_last_grep_keyword = word
  exec 'silent !' . s:before_exec_tig
  exec 'silent !' . s:tig_command . 'grep ' . shellescape(word, 1)
  :call s:open_file()
endfunction

function! tig_explorer#grep_resume() abort
  let keyword = get(g:, 'tig_explorer_last_grep_keyword', "")
  :call tig_explorer#grep(keyword)
endfunction

function! tig_explorer#blame() abort
  if !executable('tig')
    echoerr 'You need to install tig.'
    return
  endif
  exec 'silent !' . s:before_exec_tig
  exec 'silent !' . s:tig_command . 'blame +' . line('.') . ' ' . expand('%:p')
  :call s:open_file()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
