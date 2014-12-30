"*** scenario_mode.vim coded by pongo
"*** for me who am a sluggard

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

command! -bang -complete=file -nargs=? Scena :call boot_scena#Activate(<f-args>)
command! -bang -complete=file -nargs=? Scenario :call boot_scena#Activate(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo

"*** scenario_mode.vim ends here ***
