if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

setlocal nosmartindent
setlocal indentexpr=GetHaskellIndent()
setlocal indentkeys=!^F,o,O
setlocal indentkeys+=0=where,0=in

if exists('*GetHaskellIndent')
  finish
endif

function! GetHaskellIndent()
  " current line
  let line = getline(v:lnum)

  if line =~ '\<where$'
    return indent(prevnonblank(v:lnum)) - &shiftwidth
  endif

  if line =~ '\<in$'
    let lnum = s:GetPrevLineNumMatching(v:lnum - 1, '^\s*let\>')
    return indent(lnum == 0 ? v:lnum : lnum)
  endif

  " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  " previous line
  let line = getline(v:lnum - 1)
  let ind = indent(v:lnum - 1)

  if line =~ '\(\<do\|=\)$'
    return ind + (2 * &shiftwidth)
  endif

  if line =~ '\<where$'
    return indent(prevnonblank(v:lnum - 1)) + &shiftwidth
  endif

  " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let s = match(line, '\<do\s\+\zs[^{]\|\<where\s\+\zs\w\|\<let\s\+\zs\S\|^\s*\zs|\s')
  if s > 0
    return s
  endif

  " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return ind

  "if line =~ ')$'
    "let pos = getpos('.')
    "normal k$
    "let paren_end   = getpos('.')
    "normal %
    "let paren_begin = getpos('.')
    "call setpos('.', pos)
    "if paren_begin[1] != paren_end[1]
      "return paren_begin[2] - 1
    "endif
  "endif

  "if line !~ '\<else\>'
    "let s = match(line, '\<if\>.*\&.*\zs\<then\>')
    "if s > 0
      "return s
    "endif

    "let s = match(line, '\<if\>')
    "if s > 0
      "return s + &shiftwidth
    "endif
  "endif

  "let s = match(line, '\<do\s\+\zs[^{]\|\<where\s\+\zs\w\|\<let\s\+\zs\S\|^\s*\zs|\s')
  "if s > 0
    "return s
  "endif

  "let s = match(line, '\<case\>')
  "if s > 0
    "return s + g:haskell_indent_case
  "endif

  "return match(line, '\S')
endfunction

function! s:GetPrevLineNumMatching(lnum, pattern)
  let lnum = a:lnum
  while lnum > 0
    if getline(lnum) !~ a:pattern
      break
    endif
    let lnum = prevnonblank(lnum - 1)
  endwhile
  return lnum - 1
endfunction
