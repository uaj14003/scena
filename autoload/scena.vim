"*** scena.vim coded by pongo
"*** functions for scenario_mode

scriptencoding utf-8

if &filetype != 'scenario'
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

let s:scena_scriptdir = expand("<sfile>:p:h")

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
    """ voom#TreeSelect(0)を使いたいんだけど
    """ このexecutはctrlキーを\で明示しているのでシングルクォートはダメ
    execute "silent normal \<CR>"
    if bufnr('%') == s:body
      call voom#ToTreeOrBodyWin()
    endif
    call voom#OopInsert('')
  elseif l:current == s:voomtree
    call voom#OopInsert('')
  endif
  execute 'silent normal zz'
endfunction


"((( Split Scene
function! scena#SplitScene()
  """ 柱、シーン末、見出しには反応させない。行頭はスライド、行中は後行へ
  """ append()って指定行の下に加えるってことなのね
  let [l:gyou, l:keta] = getpos('.')[1:2]
  let l:linestr = getline('.')
  if match(l:linestr,'○.*\|【[^】]*】\|\ \ 　') < 0
    if !strlen(l:linestr) || l:keta == 1
      call append(l:gyou - 1, '○')
      call append(l:gyou - 1, '  　')
      call cursor(l:gyou + 1, 1)
    elseif l:keta > 1
      call append(l:gyou, '○')
      call append(l:gyou, '  　')
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
  let l:lines = getline(2,line('$'))

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
  """ 0が戻って挿入されないように空を返す
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
      """ 行頭、或いは行頭一文字にカーソルがある場合では、モードがinsertからnormalに切り替わると
      """ 桁情報が同じ１になってしまうので動作を調整するのは難しい。一応仕様ということで
      if l:cursor != 1
        execute 'normal a'.l:nkakko[a:rubi]
      elseif l:cursor == 1
        execute 'normal i'.l:nkakko[a:rubi]
      endif
    endif
  elseif a:visual == 1
    """ 通常の範囲選択とは異なるが調整はしないでおく
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
    if l:gline != l:date
      call append(l:nishi+0,l:date)
      call append(l:nishi+1,'・')
      call cursor(l:nishi+2,4)
    elseif l:gline == l:date
      call append(l:nishi+1,'・')
      call cursor(l:nishi+2,4)
   endif
 return ''
endfunction


"((( Gomibox
function! scena#Gomibox()
  let l:tmp = @@
  let l:tmp = substitute(l:tmp, '○', '●', 'g')
  let l:tmp = substitute(l:tmp, '  　', '', 'g')

  "let l:gpos = getpos('.')
  let l:gomi = search('^【倉庫】$', 'n', line('W$'))

  call append(l:gomi,strftime("[%Y/%m/%d(%a) %H:%M:%S]"))

  let l:tmplist = split(l:tmp, '\n')
  let l:appe = l:gomi+1
  for l:item in l:tmplist
    if strlen(l:item) > 0
      call append(l:appe,l:item)
      let l:appe = l:appe + 1
    endif
  endfor
  let l:tmp = ''
  let l:tmplist = []
  "call setpos('.',l:gpos)
endfunction


"((( Sortの調整用関数 vimhelpからまるまる転載
function! s:MyCompare(i1, i2)
   return a:i1 == a:i2 ? 0 : a:i1 > a:i2 ? 1 : -1
endfunc


"((( MidashiDic  JScena書式の見出しと行番号の辞書と行番号がsortされたリスト
""" s:keydic辞書{見出し:行番号}及びs:valsortリスト[sortされた行番号]を生成する
function! s:MidashiDic()
  "let l:scenaform = fnamemodify(s:scena_scriptdir.'/../doc/scenaform', ":p")
  let s:keydic = {}
  let s:valsort = []

  """ scenaformから標準とする見出しを読み込んでkeydicを生成する
  "for l:form in readfile(l:scenaform)
  "  if match(l:form,'【[^】]*】') >= 0
  "    let l:line = search(l:form,'n',line('W$'))
  "    let l:keydic[l:form] = l:line
  "  endif
  "endfor

  """ 隅付き括弧とmatchする行を見出しとしてkeydicを生成する
  let l:line = 1 " ファイルの行頭１行目からカウント
  for l:form in getline(1,line('$'))
    if match(l:form,'^【[^】]*】$') >= 0
      let s:keydic[l:form] = l:line
    endif
    let l:line += 1
  endfor

  let s:valsort = sort(values(s:keydic),"<SID>MyCompare")
  """ ファイル末に架空の見出し分があるものとしてリストに加える
  call add(s:valsort,line('$')+1)
endfunc


"((( JpCountPages  JpCountPageさんを呼び出しましょ
""" 書式に見出しの追加や順序変更があった場合の対策
""" 見出しである【あらすじ】【プロット】を題字として頁数に含ませているのは仕様
""" Cancelでダミーの行数をJpCountPageに計算してもらってるのも仕様
function! scena#JCP()

  let l:arasuji = '【あらすじ】'
  let l:plot = '【プロット】'

  call <SID>MidashiDic() " s:valsort,s:keydicを生成
  let l:a = match(s:valsort,s:keydic[l:arasuji])
  let l:b = match(s:valsort,s:keydic[l:plot])


  let l:select = confirm("400字詰め概算枚数","&1 本文\n&2 ".l:arasuji."\n&3 ".l:plot."\n&Cancel")
  if l:select == '1'
      let l:startline = 1
      let l:endline = min(s:valsort)-2 "見出しとシーン末の空行分の2行を引く
    elseif l:select == '2'
      let l:startline = s:valsort[l:a]
      let l:endline = s:valsort[l:a+1]-2 "次の要素(+1)である行数から2を引く
    elseif l:select == '3'
      let l:startline = s:valsort[l:b]
      let l:endline = s:valsort[l:b+1]-2
    else
     let l:startline = 1
     let l:endline = 1
  endif

  execute ':'.l:startline.','.l:endline.'JpCountPages 20 20'
endfunction


"((( ViewPlot  プロットを別ファイルにして管理している場合の呼び出し
""" vimrcにlet $PLOTFILES = $HOME."/niyaniya/"の様に、プロットを管理するディレクトリを設定したうえで
""" JScena書式の【プロット】下に、$PLOTFILES/hogeplot.txtなどとプロットファイルを指定しておく
function! scena#ViewPlot()
  if exists('$PLOTFILES')
    let l:plotfiles = []
    call <SID>MidashiDic()
    let l:plotnr = s:keydic['【プロット】']
    let l:matchnr = match(s:valsort,l:plotnr)
    let l:matchend = s:valsort[l:matchnr+1]

    for l:linecha in getline(l:plotnr,l:matchend)
      if match(l:linecha,'$PLOTFILES') >= 0
        call add(l:plotfiles,l:linecha)
      endif
    endfor

    let l:listlen = len(l:plotfiles)

    if l:listlen == 1
      execute ':sp '.l:plotfiles[0]
      setfiletype plot
    elseif l:listlen > 1
      let l:shifttab = 0
      for l:path in l:plotfiles
        execute ':tabnew '.l:path
        setfiletype plot
        let l:shifttab += 1
      endfor
      execute ':tabprevious'.l:shifttab
    endif
  endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo

"*** scena.vim ends here *** {{{
" vim:fdm=marker:fdl=0:
" vim:foldtext=getline(v\:foldstart).'...'.(v\:foldend-v\:foldstart):
