function! s:fairEdit(register,...)
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
    exe "norm! " . get(l:,'premove','').(mpos[1]-col('.')-exists('premove')).'"'.a:register.a:1.'l'
  else
    exe "norm! " . get(l:,'premove','').'"'.a:register.toupper(a:1)
  endif
endfunction

nnoremap <silent> <Plug>FairC
      \   :<C-U>execute 'silent! call repeat#setreg("\<lt>Plug>FairC", v:register)'<Bar>
      \   call <SID>fairEdit(v:register,'c')<Bar>startinsert<bar>call cursor(0,col('.')+1)<Bar>
      \   silent! call repeat#set("\<lt>Plug>FairC")<CR>
nmap C <Plug>FairC

nnoremap <silent> <Plug>FairD
      \   :<C-U>execute 'silent! call repeat#setreg("\<lt>Plug>FairD", v:register)'<Bar>
      \   call <SID>fairEdit(v:register,'d')<Bar>
      \   silent! call repeat#set("\<lt>Plug>FairD")<CR>
nmap D <Plug>FairD

if maparg('Y','n') =~# '^y\$$'
  nnoremap <silent> <Plug>FairyEOL
        \   :<C-U>execute 'silent! call repeat#setreg("\<lt>Plug>FairyEOL", v:register)'<Bar>
        \   call <SID>fairEdit(v:register,'y')<Bar>
        \   silent! call repeat#set("\<lt>Plug>FairyEOL")<CR>
  nmap Y <Plug>FairyEOL
endif
