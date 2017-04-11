if exists('g:fairedit_last_inserted')
  finish
endif

let g:fairedit_last_inserted = ''

function! s:fairEdit(register,...)
  if a:1 =~ '[<>!=]'
    return
  endif
  if a:1 == 'c'
    let g:fairedit_last_inserted = @.
  endif
  if synIDattr(synID(line("."), col("."), 1), "name") =~? "\\vstring|comment|regex" &&
        \ synIDattr(synID(line("."), col(".")-1, 1), "name") =~? "\\vstring|comment|regex"
    let str = 1
    if synIDattr(synID(line("."), col(".")+1, 1), "name") !~? "\\vstring|comment|regex"
      return
    else
      let mpos = searchpairpos('\m\%#','','\m[''`"/]','nW',
            \ 'synIDattr(synID(line("."), col(".")+1, 1), "name") =~? "\\vstring|comment|regex"',line('.'))
    endif
  elseif getline('.')[col('.')-1] =~ '[]})]'
    return
  endif
  if !exists('str')
    let mpos= searchpairpos('\m[[({]','','\m[])}]','cnW',
          \ 'synIDattr(synID(line("."), col("."), 1), "name") =~? "\\vstring|comment|regex"',line('.'))
  endif
  if get(l:,'mpos',[0])[0]
    exe "norm! " . (mpos[1]-col('.')).'"'.a:register.a:1.'l'
  else
    exe "norm! " . '"'.a:register.a:1.'$'
  endif
  if a:1 == 'c'
    startinsert|call cursor(0,col('.')+1)
  endif
  return 1
endfunction

onoremap <silent> <Plug>Fair_dollar
      \   :<C-U>execute 'silent! call repeat#setreg("\<lt>Plug>Fair_dollar", v:register)'<Bar>
      \   if <SID>fairEdit(v:register,v:operator)<Bar>
      \   silent! call repeat#set((v:operator ==? 'c' ?
      \   '"'.v:register."\<lt>Plug>Fair_C\<lt>C-r>=fairedit_last_inserted\<lt>CR>\<lt>esc>" :
      \   v:operator."\<lt>Plug>Fair_dollar"))<bar>endif<bar>stopinsert<CR>

nnoremap <silent> <Plug>Fair_C
      \   :<C-U>execute 'silent! call repeat#setreg("\<lt>Plug>Fair_C", v:register)'<Bar>
      \   if <SID>fairEdit(v:register,'c')<Bar>
      \   silent! call repeat#set('"'.v:register."\<lt>Plug>Fair_C\<lt>C-r>=fairedit_last_inserted\<lt>CR>\<lt>esc>")<bar>endif<CR>

nnoremap <silent> <Plug>Fair_D
      \   :<C-U>execute 'silent! call repeat#setreg("\<lt>Plug>Fair_D", v:register)'<Bar>
      \   if <SID>fairEdit(v:register,'d')<Bar>
      \   silent! call repeat#set("\<lt>Plug>Fair_D")<bar>endif<CR>

nnoremap <silent> <Plug>Fair_yEOL
      \   :<C-U>execute 'silent! call repeat#setreg("\<lt>Plug>Fair_yEOL", v:register)'<Bar>
      \   if <SID>fairEdit(v:register,'y')<Bar>
      \   silent! call repeat#set("\<lt>Plug>Fair_yEOL")<bar>endif<CR>
