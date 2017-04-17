if exists('g:fairedit_last_inserted')
  finish
endif

let g:fairedit_last_inserted = ''
let g:prev_rep_reg = ['','']

function! s:fairEdit(register,...)
  if a:1 == 'c' && get(a:000,1)
    call feedkeys('','x')
    call feedkeys("\<C-C>","n")
  endif
  if a:1 =~ '[<>!=zq]'
    return feedkeys('$','n')
  elseif a:1 == 'c'
    let g:fairedit_last_inserted = @.
  endif
  let pos = getpos('.')[1:2]
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
      if cursor(0,col('$')) || searchpair('\m[[({]','','\m[])}]','rcbW',
            \ 'col(".") <'.pos[1].'||synIDattr(synID(line("."), col("."), 1), "name") =~? "\\vstring|comment|regex"',
            \ line('.'))
        let endpos = searchpairpos('\m'.escape(getline('.')[col('.')-1],'['),
              \ '','\m'.tr(getline('.')[col('.')-1],'[({','])}'),'nW',
              \ 'synIDattr(synID(line("."), col("."), 1), "name") =~? "\\vstring|comment|regex"')
      endif
      call call('cursor',pos)
    endif
  endif
  if a:1 == 'c' && !search('\m\S','bnW',line('.')) && search('\m\S','cW',line('.'))
    let pos = getpos('.')[1:2]
  endif
  if get(l:,'endpos',[0])[0]
    exe "norm! \"".a:register.tr(a:1,'c','d').'v'.(line2byte(endpos[0]) + endpos[1]-1).'go'
  elseif get(l:,'mpos',[0])[0]
    exe "norm! \"".a:register.tr(a:1,'c','d').(mpos[1]-col('.')).'l'
  else
    exe "norm! \"".a:register.tr(a:1,'c','d').'$'
  endif
  if a:1 == 'c'
    if !get(a:000,1)
      call feedkeys('','x')
    else
      call feedkeys('i','n')
    endif
    startinsert|call call('cursor',pos)
  endif
  return 1
endfunction

function! s:mapmaker(type,name,args,repcmd,...)
  return a:type.'noremap <silent> <Plug>'.a:name.' '
        \   .':<C-U>call feedkeys("\<lt>esc>","n")<bar>let g:prev_rep_reg = deepcopy(get(g:,"repeat_reg",["",""]))<bar>'
        \   .'silent! call repeat#setreg("\<lt>Plug>'.a:name.'", v:register)<Bar>'
        \   .'if <SID>fairEdit(v:register,'.a:args.')<Bar>'
        \   .'  silent! call repeat#set('.a:repcmd.')<bar>'
        \   .'else<bar>'
        \   .'  let g:repeat_reg = g:prev_rep_reg<bar>'
        \   .'endif<CR>'
endfunction

exe s:mapmaker('n','Fair_M_D',"'d',0,1",'"\<lt>Plug>Fair_M_D"')
exe s:mapmaker('n','Fair_M_C',"'c',0,1",'"\"".v:register."\<lt>Plug>Fair_M_C\<lt>C-r>=fairedit_last_inserted\<lt>CR>\<lt>esc>"')
exe s:mapmaker('n','Fair_M_yEOL',"'y',0,1",'"\<lt>Plug>Fair_M_yEOL"')
exe s:mapmaker('o','Fair_M_dollar',"v:operator,1,1",'(v:operator ==? "c" ?'.
      \       '"\"".v:register."\<lt>Plug>Fair_M_C\<lt>C-r>=fairedit_last_inserted\<lt>CR>\<lt>esc>" :'.
      \       'v:operator."\<lt>Plug>Fair_M_dollar")')

exe s:mapmaker('n','Fair_D',"'d',0",'"\<lt>Plug>Fair_D"')
exe s:mapmaker('n','Fair_C',"'c',0",'"\"".v:register."\<lt>Plug>Fair_C\<lt>C-r>=fairedit_last_inserted\<lt>CR>\<lt>esc>"')
exe s:mapmaker('n','Fair_yEOL',"'y',0",'"\<lt>Plug>Fair_yEOL"')
exe s:mapmaker('o','Fair_dollar',"v:operator,1",'(v:operator ==? "c" ?'.
      \       '"\"".v:register."\<lt>Plug>Fair_C\<lt>C-r>=fairedit_last_inserted\<lt>CR>\<lt>esc>" :'.
      \       'v:operator."\<lt>Plug>Fair_dollar")')
