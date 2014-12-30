"*** scena.vim coded by pongo
"*** functions for scenario_mode

scriptencoding utf-8

if &filetype != 'scenario'
  finish
endif

let s:save_cpo = &cpo
set cpo&vim


let [s:body, s:voomtree] = voom#GetTypeBodyTree()[1:2]
autocmd! TabEnter *.txt let[s:body, s:voomtree] = voom#GetTypeBodyTree()[1:2]


"((( Test
"function! scena#Jtest()
"  "UTF8全角一文字は長さ'3'、半角は長さ'1'
"  "カーソルの移動距離は全角一文字は'2'、半角は'1'
"  let l:strlen = getline('.')
"  call append('.',strlen(l:strlen))
"endfunction


"((( Setup Hashira
function! scena#SetupHashira()
  let l:current = bufnr('%')
  if l:current == s:body
    "voom#TreeSelect(0)を使いたいんだけど
    execute "silent normal \<CR>"
    if bufnr('%') == s:body
      call voom#ToTreeOrBodyWin()
    endif
    call voom#OopInsert('')
  elseif l:current == s:voomtree
    call voom#OopInsert('')
  endif
  execute "silent normal zz"
endfunction


"((( Split Scene
function! scena#SplitScene()
  "柱、シーン末、見出しには反応させない。行頭はスライド、行中は後行へ
  "append()って指定行の下に加えるってことなのね
  let [l:gyou, l:keta] = getpos('.')[1:2]
  let l:linestr = getline('.')
  if match(l:linestr,'○.*\|【[^】]*】\|\ \ 　') < 0
    if !strlen(l:linestr) || l:keta == 1
      call append(l:gyou - 1, "○")
      call append(l:gyou - 1, "  　")
      call cursor(l:gyou + 1, 1)
    elseif l:keta > 1
      call append(l:gyou, "○")
      call append(l:gyou, "  　")
      call cursor(l:gyou + 2, 1)
    endif
  endif
  call voom#ToTreeOrBodyWin() "voomtreeに反映させるために行って来いしましょ
  call voom#ToTreeOrBodyWin()
endfunction


"((( Assist Scene
function! scena#SceneComp()
  if bufnr('%') != s:voomtree
    call voom#ToTreeOrBodyWin()
  endif

  let l:senelist = []
  let l:lines = getline(2,line("$"))

  for l:item in l:lines
    call add(l:senelist,substitute(l:item,'\s\|=\||\|○\|（[^）]*）\|【[^】]*】','','g'))
  endfor

  call filter(l:senelist, 'v:val =~ "\."')
  call voom#ToTreeOrBodyWin()
  call complete(col('.'),uniq(l:senelist))
  return ''
endfunction


"((( Line Feed
function! scena#LineFeed(chara,shift)
  let [l:gyou, l:keta] = getpos('.')[1:2]
  let l:linestr = getline('.')
  if match(l:linestr,'○.*\|【[^】]*】') == 0 "柱
    call append(l:gyou, a:chara)
    call cursor(l:gyou + 1, a:shift)
  elseif match(l:linestr,'\ \ 　') == 0 "シーン末
    call append(l:gyou - 1, a:chara)
    call cursor(l:gyou, a:shift)
  elseif !strlen(l:linestr) "空行
    call append(l:gyou, a:chara)
    execute 'normal dd'
  "  call append(l:gyou, a:chara)
  "  call cursor(l:gyou + 1, a:shift)
  elseif strlen(l:linestr) <= 3 && l:keta == 1 "行頭、或いは行頭一文字でinsertモードからnormalに切り替わる際の問題
    call append(l:gyou, a:chara)
    call cursor(l:gyou + 1, a:shift)
  elseif l:keta == 1 "文字列あり行頭
    call append(l:gyou - 1, a:chara)
    call cursor(l:gyou, a:shift)
  elseif l:keta > 1 "文字列あり行中
    call append(l:gyou, a:chara)
    call cursor(l:gyou + 1, a:shift)
  endif
endfunction


"((( Assist Serif/name/symbol/keika
function! scena#Assist(dic,kakko,lf)
  let l:kakko = ['','「」']
  if a:lf == 1
    call scena#LineFeed(l:kakko[a:kakko],1)
  endif
  call complete(col('.'),eval(a:dic))
  return ''
endfunction


"((( Serifu tag
function! scena#Serifutag(serifutag)
  let l:gyou = line('.')
  let l:p = match(getline('.'),'「')
  if l:p != -1
    call cursor(l:gyou,l:p+1)
    call complete(col('.'),a:serifutag)
    return ''
  endif
  "0が戻って挿入されないように空を返す
  return ''
endfunction


"((( Rubi&KaKKo
function! scena#RubiKakko(visual,rubi)
  let l:nkakko = ['（）','《》']
  let l:vkakko = [{'start':'（','end':'）','cursor':'1'},{'start':'｜','end':'《》','cursor':'0'}]
  let l:cursor = getpos('.')[2]

  if a:visual == 0
    execute 'normal vly'
    if @@ == l:nkakko[a:rubi]
      execute 'normal xx'
    else
      "行頭、或いは行頭一文字にカーソルがある場合では、モードがinsertからnormalに切り替わると
      "桁情報が同じ１になってしまうので動作を調整するのは難しい。一応仕様ということで
      if l:cursor != 1
        execute 'normal a'.l:nkakko[a:rubi]
      elseif l:cursor == 1
        execute 'normal i'.l:nkakko[a:rubi]
      endif
    endif
  elseif a:visual == 1
    "通常の範囲選択とは異なるが調整はしないでおく
    let [l:lnum1,l:col1] = getpos("'<")[1:2]
    let [l:lnum2,l:col2] = getpos("'>")[1:2]
    if l:lnum1 == l:lnum2
      call cursor(l:lnum1,l:col1)
      execute 'normal i'.l:vkakko[a:rubi].start
      call cursor(l:lnum2,l:col2+2)
      execute 'normal a'.l:vkakko[a:rubi].end
      if l:vkakko[a:rubi].cursor == 1
        execute 'normal l'
      endif
    endif
  endif
endfunction


"((( journal
function! scena#Journal()
  let l:nishi = search('【作業日誌】', '', line('W$'))
  let l:gline = getline(l:nishi+1)
  let l:date = strftime("[%Y/%m/%d(%a)]")
    if l:gline == ""
    elseif l:gline != l:date
      call append(l:nishi+0,l:date)
      call append(l:nishi+1,"・")
      if getline(l:nishi+3) != "  　"
        call append(l:nishi+2,"  　")
      end
      call cursor(l:nishi+2,4)
    elseif l:gline == l:date
      call append(l:nishi+1,"・")
      call cursor(l:nishi+2,4)
   endif
 return ''
endfunction


"((( Gomibox
function! scena#Gomibox()
  let l:tmp = @@
  let l:tmp = substitute(l:tmp, '○', '●', 'g')
  let l:tmp = substitute(l:tmp, '\ \ 　', '', 'g')

  let l:gpos = getpos('.')
  let l:gomi = search('^【倉庫】$', '', line('W$'))

  call append(l:gomi,strftime("[%Y/%m/%d(%a) %H:%M:%S]"))

  let l:tmplist = split(l:tmp, "\n")
  let l:appe = l:gomi+1
  for l:item in l:tmplist
    if strlen(l:item) > 0
      call append(l:appe,l:item)
      let l:appe = l:appe + 1
    endif
  endfor
  call append(l:appe,"  　")
  let l:tmp = ""
  let l:tmplist = []
  call setpos('.',l:gpos)
endfunction


"((( JpCountPages
""" JpCountPageさんを呼び出しましょ
function! scena#JCP()
  let l:bodyline = search('【タイトル】', 'n', line('W$'))
  let l:bodyline = l:bodyline - 2
  execute ":1,".l:bodyline."JpCountPages 20 20"
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

"*** scena.vim ends here *** {{{
" vim:fdm=marker:fdl=0:
" vim:foldtext=getline(v\:foldstart).'...'.(v\:foldend-v\:foldstart):
