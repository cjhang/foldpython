" Python folding plugin
" Revise: 2017-02-01
" Copyright: Chen Jianhang

if exists("g:enabled_foldpython")
  finish
endif
let g:enabled_foldpython = 1

let s:blank_regex = '\v^\s*$'
let s:def_regex = '\v^\s*%(class|def)\s+\w+\(.*\)\s*:\s*'
let s:import_regex = '\v^(from|import)'
let s:decorator_regex = '\v^\s*\@'
let s:doc_begin_regex = '\v^\s*%("""|'''''')'
let s:doc_end_regex = '\v%("""|'''''')\s*$'
let s:doc_line_regex = '\v^\s*("""|'''''').+\1\s*$'

let b:cache_folds = {}

function! s:GenerateImportFold(lnum)
  let b:cache_folds[a:lnum] = 1
  let next_lnum = a:lnum + 1
  while getline(next_lnum) !~ s:blank_regex
    let b:cache_folds[next_lnum] = 1
    let next_lnum += 1
  endwhile
  return b:cache_folds[a:lnum]
endfunction

function! s:GenerateDocFold()
  return 0
endfunction

function! s:GenerateDefFold(lnum, thread)
    let b:cache_folds[a:lnum] = '>' . (a:thread + 1)
    let next_lnum = nextnonblank(a:lnum+1)
    while (next_lnum != 0) && (indent(next_lnum)>indent(a:lnum))
      if !has_key(b:cache_folds, next_lnum)
        let next_line = getline(next_lnum)
        "if next_line =~ s:decorator_regex
          "call s:GenerateDecoratorFold(next_lnum, a:thread + 1)
        if next_line =~ s:def_regex
          call s:GenerateDefFold(next_lnum, a:thread + 1)
        else
          let b:cache_folds[next_lnum] = a:thread + 1
        endif
      endif
      let next_lnum = nextnonblank(next_lnum+1)
    endwhile
    return b:cache_folds[a:lnum]
endfunction

function! s:GenerateDecoratorFold(lnum, start_level)
  return 0
endfunction

function! GetPythonFold(lnum)
  if has_key(b:cache_folds, a:lnum)
    return b:cache_folds[a:lnum]
  endif

  let this_line = getline(a:lnum)
  if this_line =~ s:blank_regex
    return -1
  elseif this_line =~ s:import_regex
    return s:GenerateImportFold(a:lnum)
  elseif this_line =~ s:def_regex
    return s:GenerateDefFold(a:lnum, 0)
  else
    return 0
  endif
endfunction

setlocal foldmethod=expr
setlocal foldexpr=GetPythonFold(v:lnum)
