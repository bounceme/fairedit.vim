if exists('g:fairedit_last_inserted')
  finish
endif

let g:fairedit_last_inserted = ''
let g:prev_rep_reg = ['','']

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
  let [arg1, arg2] = [get(a:000,1),get(a:000,2)]
  if v:count
    let lclose = 0
  else
    let [lclose, cclose] = s:fairEdit(arg2)
  endif
  if lclose
    call setpos("'[", [0, line('.'), col('.'), 0])
    call setpos("']", [0, lclose, cclose, 0])
    return (arg1? "\<esc>" : '')."v`[o`]\"".v:register.a:1
  else
    return (arg1 ? '' : v:count1.'"'.v:register.a:1) .'$'
  endif
endfunction


nnoremap <expr><PLUG>Fair_D <SID>movement('d',0)
nnoremap <expr><PLUG>Fair_C <SID>movement('c',0)
nnoremap <expr><PLUG>Fair_yEOL <SID>movement('y',0)
onoremap <expr><PLUG>Fair_dollar <SID>movement(v:operator,1)

nnoremap <expr><PLUG>Fair_M_D <SID>movement('d',0,1)
nnoremap <expr><PLUG>Fair_M_C <SID>movement('c',0,1)
nnoremap <expr><PLUG>Fair_M_yEOL <SID>movement('y',0,1)
onoremap <expr><PLUG>Fair_M_dollar <SID>movement(v:operator,1,1)
