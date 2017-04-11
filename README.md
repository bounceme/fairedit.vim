# fairedit.vim

An adequate implementation of some of the paredit.el commands.

So far, only `paredit-kill` like. The functionality is exposed with mappings for flexibility, see `:h map.txt`.


```vim
" any operator ex. g~$ , c$ , d$ etc
omap $ <Plug>Fair_dollar

"or with the one key variants ex. C,D,Y/y$
nmap C <Plug>Fair_C
nmap D <Plug>Fair_D
if maparg('Y','n') ==# 'y$'
  nmap Y <Plug>Fair_yEOL
endif
```
