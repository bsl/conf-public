let hs_allow_hash_operator  = 1
let hs_highlight_delimiters = 1
let hs_highlight_boolean    = 1

" align imports
vmap <silent> <Leader>ai :sort<CR>:AlignPush<CR>:AlignCtrl l:p1P0<CR>gv:Align (<CR>:AlignPop<CR>
