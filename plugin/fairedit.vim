function! s:SmartK(register)
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
    exe "norm! " . get(l:,'premove','').(mpos[1]-col('.')+(exists('l:premove') ? -1 : 0)).'"'.a:register.'dl'
  else
    exe "norm! " . get(l:,'premove','').'"'.a:register."D"
  endif
endfunction

nnoremap <silent> <Plug>FairD
      \   :<C-U>execute 'silent! call repeat#setreg("\<lt>Plug>FairD", v:register)'<Bar>
      \   call <SID>SmartK(v:register)<Bar>
      \   silent! call repeat#set("\<lt>Plug>FairD")<CR>

nmap D <Plug>FairD
