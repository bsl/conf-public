if &cp || exists('g:loaded_wserror')
  finish
endif

if !exists('g:wserrorColor')
  let g:wserrorColor = 'ctermbg=red guibg=red'
endif

function! s:WSErrorHighlight0()
  exec 'highlight WSError' g:wserrorColor
  exec 'match WSError / \+$\|\t\+/'
  exec 'autocmd ColorScheme <buffer> highlight WSError' g:wserrorColor
  exec 'autocmd BufWinEnter <buffer> match WSError / \+$\|\t\+/'
  exec 'autocmd InsertLeave <buffer> match WSError / \+$\|\t\+/'
  exec 'autocmd InsertEnter <buffer> match WSError / \+\%#\@<!$/'
  exec 'autocmd BufWinLeave * call clearmatches()'
endfunction

function! s:WSErrorHighlight1()
  exec 'highlight WSError' g:wserrorColor
  exec 'match WSError /[ \t]\+$/'
  exec 'autocmd ColorScheme <buffer> highlight WSError' g:wserrorColor
  exec 'autocmd BufWinEnter <buffer> match WSError /[ \t]\+$/'
  exec 'autocmd InsertLeave <buffer> match WSError /[ \t]\+$/'
  exec 'autocmd InsertEnter <buffer> match WSError /[ \t]\+\%#\@<!$/'
  exec 'autocmd BufWinLeave * call clearmatches()'
endfunction

command WSErrorHighlight0 call <SID>WSErrorHighlight0()
command WSErrorHighlight1 call <SID>WSErrorHighlight1()

let g:loaded_wserror = 1
