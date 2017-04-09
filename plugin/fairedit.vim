function! g:SmartK()
  if synIDattr(synID(line("."), col("."), 1), "name") =~? "\\vstring|comment|regex"
    let mpos= searchpairpos('\%#','','[''`"/]','nW',
          \ 'synIDattr(synID(line("."), col(".")+1, 1), "name") =~? "\\vstring|comment|regex"',line('.'))
  else
    let mpos= searchpairpos('[[({]','','[])}]','nW',
          \ 'synIDattr(synID(line("."), col("."), 1), "name") =~? "\\vstring|comment|regex"',line('.'))
  endif
  if mpos[0]
    return (mpos[1]-col('.'))."dl"
  else
    return "D"
  endif
endfunction
nnoremap <expr> D g:SmartK()
