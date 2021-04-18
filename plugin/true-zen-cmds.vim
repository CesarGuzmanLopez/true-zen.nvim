

" GPL-3.0 License

" prevent the plugin from loading twice
if exists('g:loaded_TrueZen') | finish | endif

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to defaults

" source lua/services/resume/init.vim

" mapping {{{
command! TZBottom lua require'tz_main'.main(0, 0)
command! TZTop lua require'tz_main'.main(1, 0)
command! TZLeft lua require'tz_main'.main(2, 0)

command! TZMinimalist lua require'tz_main'.main(3, 0)
command! TZMinimalistT lua require'tz_main'.main(3, 1)
command! TZMinimalistF lua require'tz_main'.main(3, 2)

" command! TZStatuslineT lua require'true-zen'.main(0, 1)
" command! TZStatuslineF lua require'true-zen'.main(0, 2)
" }}}

let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

" set to true the var that controls the plugin's loading
let g:loaded_TrueZen = 1