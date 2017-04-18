if exists('g:fairedit_last_inserted')
  finish
endif

let g:prev_rep_reg = ['','']

augroup FaEd
  au!
augroup END

function! s:fairEdit(...)
  let pos = getpos('.')[1:2]
  if synIDattr(synID(line("."), col("."), 1), "name") =~? "\\vstring|comment|regex" &&
        \ synIDattr(synID(line("."), col(".")-1, 1), "name") =~? "\\vstring|comment|regex"
    if synIDattr(synID(line("."), col(".")+1, 1), "name") !~? "\\vstring|comment|regex"
      return [0,0]
    else
      let mpos = searchpairpos('\m\%#','','\m[''`"/]','nW',
            \ 'synIDattr(synID(line("."), col(".")+1, 1), "name") =~? "\\vstring|comment|regex"',line('.'))
      let mpos[1] -= 1
    endif
  elseif getline('.')[col('.')-1] =~ '[]})]'
    return [0,0]
  else
    let mpos = searchpairpos('\m[[({]','','\m[])}]','cnW',
          \ 'synIDattr(synID(line("."), col("."), 1), "name") =~? "\\vstring|comment|regex"',line('.'))
    let mpos[1] -= 1
    if !mpos[0] && a:1
      if cursor(0,col('$')) || searchpair('\m[[({]','','\m[])}]','rcbW',
            \ 'col(".") <'.pos[1].'||synIDattr(synID(line("."), col("."), 1), "name") =~? "\\vstring|comment|regex"',
            \ line('.'))
        let mpos = searchpairpos('\m'.escape(getline('.')[col('.')-1],'['),
              \ '','\m'.tr(getline('.')[col('.')-1],'[({','])}'),'nW',
              \ 'synIDattr(synID(line("."), col("."), 1), "name") =~? "\\vstring|comment|regex"')
      endif
      call call('cursor',pos)
    endif
  endif
  return mpos
endfunction

function! s:movement(...) abort
  let [arg1, s:arg2, arg3] = [get(a:000,1),get(a:000,2),get(a:000,3)]
  let key_seq = (arg1 ? a:1 : '')."\\<PLUG>Fair_".(s:arg2 ? 'M_' : '')
        \ .(arg1 ? 'dollar' : substitute(substitute(a:1,'y','&EOL',''),'^.$','\U&',''))
  if arg3 > 1
    let lclose = 0
  else
    let [lclose, cclose] = s:fairEdit(s:arg2)
  endif
  if lclose
    let inner_seq = a:1 ==# 'Nop' ? '"_d".P' : ('"'.v:register.a:1)
    call setpos("'[", [0, line('.'), col('.'), 0])
    call setpos("']", [0, lclose, cclose, 0])
    call feedkeys('v`[o`]'.inner_seq,'tn')
  else
    let inner_seq = a:1 ==# 'Nop' ? '"_D".p' : ('"'.v:register.a:1.'$')
    call feedkeys((arg3 ? arg3 : 1).inner_seq,'tn')
  endif
  if a:1 == 'c'
    au FaEd insertleave * silent! call repeat#set("\<PLUG>Fair_".(s:arg2 ? 'M_' : '').'Nop') | au! FaEd *
  else
    let rephack = '@=matchstr("",'
    let expr_nul = ')'
    call feedkeys(rephack.'repeat#set("'. key_seq . '",'.arg3.expr_nul.")\<cr>",'n')
  endif
endfunction

nnoremap <silent><PLUG>Fair_M_Nop :<C-U>call <SID>movement('Nop',0,1,v:count)<CR>
nnoremap <silent><PLUG>Fair_Nop :<C-U>call <SID>movement('Nop',0,0,v:count)<CR>

nnoremap <silent><PLUG>Fair_D :<C-U>call <SID>movement('d',0,0,v:count)<CR>
nnoremap <silent><PLUG>Fair_C :<C-U>call <SID>movement('c',0,0,v:count)<CR>
nnoremap <silent><PLUG>Fair_yEOL :<C-U>call <SID>movement('y',0,0,v:count)<CR>
onoremap <silent><PLUG>Fair_dollar <esc>:<C-U>call <SID>movement(v:operator,1,0,v:prevcount)<CR>

nnoremap <silent><PLUG>Fair_M_D :<C-U>call <SID>movement('d',0,1,v:count)<CR>
nnoremap <silent><PLUG>Fair_M_C :<C-U>call <SID>movement('c',0,1,v:count)<CR>
nnoremap <silent><PLUG>Fair_M_yEOL :<C-U>call <SID>movement('y',0,1,v:count)<CR>
onoremap <silent><PLUG>Fair_M_dollar <esc>:<C-U>call <SID>movement(v:operator,1,1,v:prevcount)<CR>
