if exists('g:fairedit_last_inserted')
  finish
endif

let g:fairedit_last_inserted = ''
let g:prev_rep_reg = ['','']

function! s:fairEdit(register,...)
  if a:1 =~ '[<>!=]'
    return
  elseif a:1 == 'c'
    let g:fairedit_last_inserted = @.
  endif
  if synIDattr(synID(line("."), col("."), 1), "name") =~? "\\vstring|comment|regex" &&
        \ synIDattr(synID(line("."), col(".")-1, 1), "name") =~? "\\vstring|comment|regex"
    if synIDattr(synID(line("."), col(".")+1, 1), "name") !~? "\\vstring|comment|regex"
      return
    else
      let mpos = searchpairpos('\m\%#','','\m[''`"/]','nW',
            \ 'synIDattr(synID(line("."), col(".")+1, 1), "name") =~? "\\vstring|comment|regex"',line('.'))
    endif
  elseif getline('.')[col('.')-1] =~ '[]})]'
    return
  else
    let mpos = searchpairpos('\m[[({]','','\m[])}]','cnW',
          \ 'synIDattr(synID(line("."), col("."), 1), "name") =~? "\\vstring|comment|regex"',line('.'))
    if !mpos[0] && len(a:000) == 3
      let pos = getpos('.')[1:2]
      if getline('.')[col('.')-1] =~ '[[{(]' || cursor(0,col('$')) || searchpairpos('\m[[({]','','\m[])}]','rcbW',
            \ 'col(".") <'.pos[1].'||synIDattr(synID(line("."), col("."), 1), "name") =~? "\\vstring|comment|regex"',
            \ line('.'))[0]
        let endpos = searchpairpos('\m'.escape(getline('.')[col('.')-1],'['),
              \ '','\m'.tr(getline('.')[col('.')-1],'[({','])}'),'nW',
              \ 'synIDattr(synID(line("."), col("."), 1), "name") =~? "\\vstring|comment|regex"')
        call call('cursor',pos)
      else
        call call('cursor',pos)
      endif
    endif
  endif
  if get(l:,'endpos',[0])[0]
    exe "norm! ".'"'.a:register.a:1.'v'.(line2byte(endpos[0]) + endpos[1]-1).'go'
  elseif get(l:,'mpos',[0])[0]
    exe "norm! " . (mpos[1]-col('.')).'"'.a:register.a:1.'l'
  elseif len(a:000) >= 2 && a:2
    exe "norm! <lt>esc>\"".a:register.a:1.'$'
  else
    exe "norm! " . '"'.a:register.a:1.'$'
  endif
  if a:1 == 'c'
    startinsert|call cursor(0,col('.')+1)
  endif
  return 1
endfunction

" TODO: map factory

nnoremap <silent> <Plug>Fair_M_D
      \   :<C-U>let prev_rep_reg = deepcopy(get(g:,'repeat_reg',['','']))<bar>
      \   execute 'silent! call repeat#setreg("\<lt>Plug>Fair_M_D", v:register)'<Bar>
      \   if <SID>fairEdit(v:register,'d',0,1)<Bar>
      \     silent! call repeat#set("\<lt>Plug>Fair_M_D")<bar>
      \   else<bar>
      \     let g:repeat_reg = prev_rep_reg<bar>
      \   endif<CR>

nnoremap <silent> <Plug>Fair_M_C
      \   :<C-U>let prev_rep_reg = deepcopy(get(g:,'repeat_reg',['','']))<bar>
      \   execute 'silent! call repeat#setreg("\<lt>Plug>Fair_M_C", v:register)'<Bar>
      \   if <SID>fairEdit(v:register,'c',0,1)<Bar>
      \     silent! call repeat#set('"'.v:register."\<lt>Plug>Fair_M_C\<lt>C-r>=fairedit_last_inserted\<lt>CR>\<lt>esc>")<bar>
      \   else<bar>
      \     let g:repeat_reg = prev_rep_reg<bar>
      \   endif<CR>

nnoremap <silent> <Plug>Fair_M_yEOL
      \   :<C-U>let prev_rep_reg = deepcopy(get(g:,'repeat_reg',['','']))<bar>
      \   execute 'silent! call repeat#setreg("\<lt>Plug>Fair_M_yEOL", v:register)'<Bar>
      \   if <SID>fairEdit(v:register,'y',0,1)<Bar>
      \     silent! call repeat#set("\<lt>Plug>Fair_M_yEOL")<bar>
      \   else<bar>
      \     let g:repeat_reg = prev_rep_reg<bar>
      \   endif<CR>

onoremap <silent> <Plug>Fair_M_dollar
      \   :<C-U>let prev_rep_reg = deepcopy(get(g:,'repeat_reg',['','']))<bar>
      \   execute 'silent! call repeat#setreg("\<lt>Plug>Fair_M_dollar", v:register)'<Bar>
      \   if <SID>fairEdit(v:register,v:operator,1,1)<Bar>
      \     silent! call repeat#set((v:operator ==? 'c' ?
      \       '"'.v:register."\<lt>Plug>Fair_M_C\<lt>C-r>=fairedit_last_inserted\<lt>CR>\<lt>esc>" :
      \       v:operator."\<lt>Plug>Fair_M_dollar"))<bar>
      \   else<bar>
      \     let g:repeat_reg = prev_rep_reg<bar>
      \   endif<bar>stopinsert<CR>

onoremap <silent> <Plug>Fair_dollar
      \   :<C-U>let prev_rep_reg = deepcopy(get(g:,'repeat_reg',['','']))<bar>
      \   execute 'silent! call repeat#setreg("\<lt>Plug>Fair_dollar", v:register)'<Bar>
      \   if <SID>fairEdit(v:register,v:operator,1)<Bar>
      \     silent! call repeat#set((v:operator ==? 'c' ?
      \       '"'.v:register."\<lt>Plug>Fair_C\<lt>C-r>=fairedit_last_inserted\<lt>CR>\<lt>esc>" :
      \       v:operator."\<lt>Plug>Fair_dollar"))<bar>
      \   else<bar>
      \     let g:repeat_reg = prev_rep_reg<bar>
      \   endif<bar>stopinsert<CR>

nnoremap <silent> <Plug>Fair_C
      \   :<C-U>let prev_rep_reg = deepcopy(get(g:,'repeat_reg',['','']))<bar>
      \   execute 'silent! call repeat#setreg("\<lt>Plug>Fair_C", v:register)'<Bar>
      \   if <SID>fairEdit(v:register,'c')<Bar>
      \     silent! call repeat#set('"'.v:register."\<lt>Plug>Fair_C\<lt>C-r>=fairedit_last_inserted\<lt>CR>\<lt>esc>")<bar>
      \   else<bar>
      \     let g:repeat_reg = prev_rep_reg<bar>
      \   endif<CR>

nnoremap <silent> <Plug>Fair_D
      \   :<C-U>let prev_rep_reg = deepcopy(get(g:,'repeat_reg',['','']))<bar>
      \   execute 'silent! call repeat#setreg("\<lt>Plug>Fair_D", v:register)'<Bar>
      \   if <SID>fairEdit(v:register,'d')<Bar>
      \     silent! call repeat#set("\<lt>Plug>Fair_D")<bar>
      \   else<bar>
      \     let g:repeat_reg = prev_rep_reg<bar>
      \   endif<CR>

nnoremap <silent> <Plug>Fair_yEOL
      \   :<C-U>let prev_rep_reg = deepcopy(get(g:,'repeat_reg',['','']))<bar>
      \   execute 'silent! call repeat#setreg("\<lt>Plug>Fair_yEOL", v:register)'<Bar>
      \   if <SID>fairEdit(v:register,'y')<Bar>
      \     silent! call repeat#set("\<lt>Plug>Fair_yEOL")<bar>
      \   else<bar>
      \     let g:repeat_reg = prev_rep_reg<bar>
      \   endif<CR>
