if exists('g:fairedit_last_inserted')
  finish
endif

let g:fairedit_last_inserted = ''

function! s:fairEdit(register,...)
  if a:1 =~ '[<>!=]'
    return
  endif
  if synIDattr(synID(line("."), col("."), 1), "name") =~? "\\vstring|comment|regex" &&
        \ synIDattr(synID(line("."), col(".")-1, 1), "name") =~? "\\vstring|comment|regex"
    let str = 1
    if synIDattr(synID(line("."), col(".")+1, 1), "name") !~? "\\vstring|comment|regex"
      let premove = 'l'
      unlet str
    else
      let mpos = searchpairpos('\m\%#','','\m[''`"/]','nW',
            \ 'synIDattr(synID(line("."), col(".")+1, 1), "name") =~? "\\vstring|comment|regex"',line('.'))
    endif
  endif
  if !exists('str')
    let mpos= searchpairpos('\m[[({]','','\m[])}]','nW',
          \ 'synIDattr(synID(line("."), col("."), 1), "name") =~? "\\vstring|comment|regex"',line('.'))
  endif
  if a:1 == 'c'
    let g:fairedit_last_inserted = @.
  endif
  if get(l:,'mpos',[0])[0]
    exe "norm! " . get(l:,'premove','').(mpos[1]-col('.')-exists('premove')).'"'.a:register.a:1.'l'
  else
    exe "norm! " . get(l:,'premove','').'"'.a:register.a:1.'$'
  endif
  if a:1 == 'c'
    startinsert|call cursor(0,col('.')+1)
  endif
endfunction

onoremap <silent> <Plug>Fairdollar
      \   :<C-U>execute 'silent! call repeat#setreg("\<lt>Plug>Fairdollar", v:register)'<Bar>
      \   call <SID>fairEdit(v:register,v:operator)<Bar>
      \   silent! call repeat#set((v:operator ==? 'c' ?
      \   '"'.v:register."\<lt>Plug>FairC\<lt>C-r>=fairedit_last_inserted\<lt>CR>\<lt>esc>" :
      \   v:operator."\<lt>Plug>Fairdollar"))<bar>stopinsert<CR>

nnoremap <silent> <Plug>FairC
      \   :<C-U>execute 'silent! call repeat#setreg("\<lt>Plug>FairC", v:register)'<Bar>
      \   call <SID>fairEdit(v:register,'c')<Bar>
      \   silent! call repeat#set('"'.v:register."\<lt>Plug>FairC\<lt>C-r>=fairedit_last_inserted\<lt>CR>\<lt>esc>")<CR>

nnoremap <silent> <Plug>FairD
      \   :<C-U>execute 'silent! call repeat#setreg("\<lt>Plug>FairD", v:register)'<Bar>
      \   call <SID>fairEdit(v:register,'d')<Bar>
      \   silent! call repeat#set("\<lt>Plug>FairD")<CR>

nnoremap <silent> <Plug>FairyEOL
      \   :<C-U>execute 'silent! call repeat#setreg("\<lt>Plug>FairyEOL", v:register)'<Bar>
      \   call <SID>fairEdit(v:register,'y')<Bar>
      \   silent! call repeat#set("\<lt>Plug>FairyEOL")<CR>
