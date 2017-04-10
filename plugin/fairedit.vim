function! g:SmartK()
  if synIDattr(synID(line("."), col("."), 1), "name") =~? "\\vstring|comment|regex" &&
        \ synIDattr(synID(line("."), col(".")-1, 1), "name") =~? "\\vstring|comment|regex"
    let str = 1
    if synIDattr(synID(line("."), col(".")+1, 1), "name") !~? "\\vstring|comment|regex"
      let premove = 'l'
      unlet str
    else
      let mpos = searchpairpos('\%#','','[''`"/]','nW',
            \ 'synIDattr(synID(line("."), col(".")+1, 1), "name") =~? "\\vstring|comment|regex"',line('.'))
    endif
  endif
  if !exists('str')
    let mpos= searchpairpos('[[({]','','[])}]','nW',
          \ 'synIDattr(synID(line("."), col("."), 1), "name") =~? "\\vstring|comment|regex"',line('.'))
  endif
  if get(l:,'mpos',[0])[0]
    return get(l:,'premove','').(mpos[1]-col('.')+(exists('l:premove') ? -1 : 0))."dl"
  else
    return get(l:,'premove','')."D"
  endif
endfunction
nnoremap <expr> D g:SmartK()
