"*** pypath.vim coded by pongo
"*** for searching voom_mode_scenario.py

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

"let s:path = substitute(expand('<sfile>:p'),'pypath.vim','','g')
let s:path = expand("<sfile>:p:h").'/voom'

function! pypath#Add_pythonpath()
python << EOM
import vim,sys
#sys.path.append(vim.eval('s:path') + 'voom')
sys.path.append(vim.eval('s:path'))
EOM
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

"*** pypath.vim ends here ***
