if exists('g:fairedit_last_inserted')
  finish
endif

let g:fairedit_last_inserted = ''
let g:prev_rep_reg = ['','']

function! s:fairEdit()
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
    if !mpos[0]
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
  let [lclose, cclose] = s:fairEdit()
  if lclose
    call setpos("'[", [0, line('.'), col('.'), 0])
    call setpos("']", [0, lclose, cclose, 0])
    return "v`[o`]".a:1
  else
    return (get(a:000,1)? '':a:1) .'$'
  endif
endfunction

nnoremap <expr><PLUG>Fair_M_D <SID>movement('d')
nnoremap <expr><PLUG>Fair_M_C <SID>movement('c')
nnoremap <expr><PLUG>Fair_M_Y <SID>movement('y')
onoremap <expr><PLUG>Fair_M_dollar "\<esc>".<SID>movement(v:operator,1)
