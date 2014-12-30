
scriptencoding utf-8

function! outline#scenario#outline_info()
  return s:outline_info
endfunction

let s:outline_info = {
      \ 'heading': '｛MEMO;[^｝]*｝\|【[^】]*】',
      \
      \ 'heading_groups': {
      \   'type'     : ['class'],
      \   'function' : ['function'],
      \ },
      \
      \ }

function! s:outline_info.create_heading(which, heading_line, matched_line, context)
  let heading = {
      \ 'word' : a:heading_line,
      \ 'level': 1,
      \ 'type' : 'generic',
      \ }

  let heading.word = substitute(heading.word, ' \|　\|｝', '', 'g')
  let heading.word = substitute(heading.word, '｛MEMO;', '※', 'g')
  let heading.word = strpart(heading.word, 0, 33)

  return heading
endfunction

"*** scenario.vim ends here ***
