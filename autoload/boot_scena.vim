"*** boot_scena.vim coded by pongo

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" 本スクリプトのディレクトリを取得
let s:boot_scriptdir = expand("<sfile>:p:h")

"" scena_modeの機能が参照するグローバル変数
"" let g:name_dic = []   NameDic()で生成
"" let g:keika = []      SetOtherDic()で生成
"" let g:hashira_dic = []  SetOtherDic()で生成
"" let g:serifu_dic = [] SetOtherDic()で生成
"" let g:symbol_dic = [] SetOtherDic()で生成


"***{{{ functions }}}***
"((( FocusBody VoomのTreeBufferから編集中Bufferへ移動させましょ
function! s:FocusBody()
  let [l:body,l:voomtree] = voom#GetTypeBodyTree()[1:2]
  let l:current = bufnr('%')
  if l:voomtree == l:current | call voom#ToTreeOrBodyWin() | endif
endfunction


"((( Ozsynx highlightゃsyntaxを設定しましょ
function! s:Ozsynx()
  call <SID>FocusBody()

  if version > 580
    highlight clear
    if exists("syntax on")
      syntax reset
    endif
  endif

  if has('gui_running')
    setlocal background=light
  endif

  "@@ styles @@    {{{1
  " fonts ---------{{{2
  if has('gui_win32')
    "set guifont=IPA明朝\ 13
    setlocal guifont=IPA明朝\ 13
  elseif has('gui_gtk2')
    "set guifont=M+1VM+IPAG\ circle\ 12
    set guifont=M+1VM+IPAG\ circle\ 12
  endif

  " highlight -----{{{2
  highlight Normal guibg=#e9e4d4 guifg=#282b4d

  highlight LineNr guibg=#355373 guifg=#ffffff
  highlight Hashira guibg=#a0cee5 guifg=#000000
  highlight SceneEnd guibg=#ff7f9f
  highlight Rubi guibg=NONE guifg=#ff0000

  highlight Serifu guibg=NONE guifg=#cc4300
  highlight SerifuKakko gui=bold guibg=NONE guifg=#cc4300

  highlight Memo guibg=#e6cde3 guifg=#640125
  highlight Peke gui=bold guibg=NONE guifg=#640125
  highlight Kakko gui=bold guibg=NONE
  highlight Dash guibg=NONE guifg=#800080

  highlight Pmenu guibg=#000080 guifg=#ff00ff
  highlight PmenuSel guibg=#000000 guifg=#ffffff
  highlight PmenuSbar guibg=#333333

  highlight ZenKakuSpe gui=underline guifg=#282b4d
  highlight HankakuSpe guibg=#e4a6bf
  highlight HankakuMoji gui=bold guibg=NONE guifg=#435AA0

  " syntax --------{{{2
  syntax match Hashira /^○.*$/
  syntax match Rubi /《[^》]*》\|｜/

  """ シーン末のmatchを全角半角スペースの後に持ってくるとい安易な方法
  syntax match ZenkakuSpe /　/
  syntax match HankakuSpe / /
  syntax match SceneEnd /^\ \ 　$/
  
  syntax match HankakuMoji /\w\+/

  syntax match SerifuKakko /「\|」/

  syntax match Memo /｛MEMO\;[^｝]*｝/
  syntax match Peke /^　　　×　　　×　　　×$/
  syntax match Kakko /（[^）]*）/ contains=Rubi
  syntax match Dash /…\|―/
  syntax match Serifu /[^「」]*\(「[^」]*」\)\@=/ contains=SerifuKakko

  "----------------}}}1
endfunction


"((( NameDic 名前辞書に記述された設定を読み込んでグローバル変数を生成しましょ
function! s:NameDic()
  call <SID>FocusBody() "bodyで実行させるためにフォーカス

  let g:name_dic = [] "グローバル変数の初期化

  let l:gpos = getpos('.')
  let l:lines = getline(search('=namdic=')+1,search('=enddic=')-1)

  let l:syntax = 0
  for l:name in l:lines
    let l:litem = []
    let l:ditem = {}

    call extend(l:litem,split(l:name,","))

    let l:ditem.word = get(l:litem,0)
    let l:ditem.menu = get(l:litem,1)
    let l:highlight = get(l:litem,2)

    if l:ditem.word != "0" "空でなければ辞書に加える
      call add(g:name_dic,l:ditem)
    endif

    if l:highlight != "0" "空でなければhighlight,syntaxに加える
      execute 'highlight TestName'.
      \ l:syntax.' gui=NONE guibg=NONE guifg='.l:highlight
      execute 'syntax match TestName'.l:syntax.' /'.l:ditem.word.
      \ '[^「」]*\(「[^」]*」\)\@=/ contains=SerifuKakko'
      let l:syntax += 1
    endif
  endfor
  call setpos('.',l:gpos)
endfunction


"((( ResetOzsynx autocmd TabEnter用の詰め合わせ
function! s:ResetOzsynx()
  if &filetype == 'scenario'
    call <SID>Ozsynx()
    call <SID>NameDic()
  endif
endfunction


"((( SetForm Jscena書式の雛形を貼りましょ
function! s:SetForm(new)
  let l:scenaform = fnamemodify(s:boot_scriptdir.'/../doc/scenaform', ":p")

  if a:new == 1 "新規にJScena形式のファイルを作成
    call append('0',"○")
    call append('1',"  　")

    let l:i = 2
    for form in readfile(l:scenaform)
        call append(l:i,form)
        let l:i += 1
    endfor

    "ファイル末尾の空行をトリミング
    execute "normal dd"
    execute "normal gg"

  elseif a:new == 0 "既存ファイルの本文末にJScena形式の雛形を加える
    if confirm("雛形をファイル末に加えますか？", "&YES\n&NO") == 1
      for l:form in readfile(l:scenaform)
        call append('$',l:form)
      endfor
    endif
  endif
endfunction


"((( Help
function! s:Help()
  let l:scenahelp = fnamemodify(s:boot_scriptdir.'/../doc/scenahelp', ":p")
  execute ":tabnew ".l:scenahelp
  setfiletype scenahelp
  setlocal readonly
  call voom#Init('scenario')
  call <SID>Ozsynx()
  call voom#ToTreeOrBodyWin()
endfunction


"((( SetOtherDic 記号類を一覧にしたファイルを読み込んで辞書変数を生成しましょ
function! s:SetOtherDic()
  let l:scenasymbol = fnamemodify(s:boot_scriptdir.'/../doc/scenasymbol', ":p")
  if !exists("s:already_SOD") "最初の一回だけ実行
    for l:dicitem in readfile(l:scenasymbol)
      if match(l:dicitem,'=START=') >= 0 "初期化のトリガー
        let l:Variablename = substitute(l:dicitem,'=START=','','g')
        let l:completeitem = []
      elseif match(l:dicitem,'=END=') >= 0 "変数の生成のトリガー
        execute ':let '.l:Variablename.'= copy(l:completeitem)'
      else "指示あるまで辞書を作りましょ
        if strlen(l:dicitem) != 0
          let l:litem = []
          let l:ditem = {}
          call extend(l:litem,split(l:dicitem,","))
          let l:ditem.word = get(l:litem,0)
          let l:ditem.menu = get(l:litem,1)
          let l:ditem.curs = get(l:litem,2)
          call add(l:completeitem,l:ditem)
        endif
      endif
    endfor
  endif
  let s:already_SOD = expand("<sfile>:e") " eオプションで関数名を切り出し（特に意味なし。やってみたかっただけ）
endfunction


"((( Unite
function! s:StartUnite()
  execute "Unite outline -buffer-name=memo -vertical -no-quit -winwidth=30 -toggle -no-focus"
endfunction

"***{{{ main }}}***
function! boot_scena#Activate(...)

"TODO
"・syntaxのネーミングを整理する

  "ファイルを開く挙動（なぜか関数にするとエラーが出るので直置き）
  let l:lasttab = tabpagenr('$') "最後尾のタブ番号(タブの数)を取得
  if a:0 == 0 && &filetype != "text" " 引数なしでカレントバッファがテキストでない場合
      execute ":tabnew"
      call <SID>SetForm(1)
  elseif a:0 == 1
    if l:lasttab == 1 && &filetype == ""
      execute ":e ".a:1
    elseif l:lasttab >= 1
      execute ":tabnew ".a:1
    endif
  endif

  filetype plugin on
  setfiletype scenario

  "@@ settings @@  {{{1
  " setlocal ------{{{2
  setlocal noautoindent
  setlocal formatoptions-=ro

  " voom/unite variables {{{2
  let g:unite_split_rule = 'botright'

  " vimrcで設定していてもmapclearしてしまうので関数内で再設定
  "let IM_CtrlMode=1
  inoremap <buffer> <C-j> <C-r>=IMState('FixMode')<CR>
  "----------------}}}1

  call pypath#Add_pythonpath()
  call voom#Init('scenario')
  call <SID>Ozsynx()
  call <SID>NameDic()
  call <SID>SetOtherDic()
  call <SID>StartUnite()

  autocmd! TabEnter *.txt :call <SID>ResetOzsynx()

  "@@ key map @@   {{{1
  " Disabel keys---{{{2
  "手癖で打ち込んでしまい、苛ついて鬱にならないように
  nnoremap <buffer> <C-u> <Esc>
  nnoremap <buffer> <C-o> <Esc>
  " Enabel keys----{{{2
  """ Move Cursor
  inoremap <buffer> <C-b> <Left>
  inoremap <buffer> <C-f> <Right>
  inoremap <buffer> <C-p> <Up>
  inoremap <buffer> <C-n> <Down>

  nnoremap <buffer> <Down> gj
  nnoremap <buffer> <Up>   gk
  "nnoremap <buffer> h <Left>zv
  nnoremap <buffer> j gj
  nnoremap <buffer> k gk
  "nnoremap <buffer> l <Right>zv

  nnoremap <buffer> ZZ <Nop>

  """ PopUpMenu Select
  inoremap <expr> <Left> pumvisible() ? "\<C-e>" : "\<Left>"
  inoremap <expr> <Down> pumvisible() ? "\<C-n>" : "\<Down>"
  inoremap <expr> <Up> pumvisible() ? "\<C-p>" : "\<Up>"
  inoremap <expr> <Right> pumvisible() ? "\<C-y>" : "\<Right>"

  """ Select Current Line & Delete
  inoremap <C-d> <Esc>V
  vnoremap <C-d> D

  """ BackSpace
  "nnoremap <BS> hx
  inoremap <C-h> <BS>

  """ normalからvisualモードで範囲選択しようとする際
  """ 行数の分だけお目に掛かるE315エラーの回避として
  nnoremap <buffer> v vvv
  nnoremap <buffer> V VVV
  nnoremap <buffer> <C-v> <C-v><C-v><C-v>


  """ 関数のマップは同系列の機能や編集の流れが同じ機能を一つのレターにまとめ
  """ <C-○>,<C-A-○>,<S-A-○>の順に割り当てることを基本とする

  """ Test function
  "inoremap <silent> <F2> <Esc>:call scena#Jtest()<CR>

  """ Setup Hashira
  nnoremap <buffer> <C-A-n> :call scena#SetupHashira()<CR>a
  inoremap <buffer> <C-A-n> <Esc>:call scena#SetupHashira()<CR>a

  """ Split Scene
  nnoremap <buffer> <S-A-n> :call scena#SplitScene()<CR>a
  inoremap <buffer> <S-A-n> <Esc>:call scena#SplitScene()<CR>a

  """ Assist Hashira
  nnoremap <buffer> <C-v><C-k> i<C-r>=scena#Assist("g:hashira_dic",0,0)<CR>
  inoremap <buffer> <C-v><C-k> <C-r>=scena#Assist("g:hashira_dic",0,0)<CR>

  """ Assist Scene
  nnoremap <buffer> <C-v><C-j> i<C-r>=scena#SceneComp()<CR>
  inoremap <buffer> <C-v><C-j> <C-r>=scena#SceneComp()<CR>

  """ Line Feed 第1引数:特定の文字列、第2引数:カーソル移動先の桁（ここでは文字列の指定がないので"1"）
  nnoremap <buffer> <C-A-m> :call scena#LineFeed('',1)<CR>i
  inoremap <buffer> <C-A-m> <Esc>:call scena#LineFeed('',1)<CR>i

  """ Assist Serifu 第1:変数名、第2:カギ括弧の有無、第3:改行の有無
  """ <C-i>はvimの標準で=<tab>に割り当てられているためtabでも開いちゃいます。仕様ということで
  nnoremap <buffer> <C-i> i<C-r>=scena#Assist("g:name_dic",1,1)<CR>
  inoremap <buffer> <C-i> <C-r>=scena#Assist("g:name_dic",1,1)<CR>

  """ Assist Namae
  nnoremap <buffer> <C-A-i> i<C-r>=scena#Assist("g:name_dic",0,0)<CR>
  inoremap <buffer> <C-A-i> <C-r>=scena#Assist("g:name_dic",0,0)<CR>

  """ Serifu tag
  nnoremap <buffer> <C-v><C-i> i<C-r>=scena#Serifutag(g:serifu_dic)<CR>
  inoremap <buffer> <C-v><C-i> <C-r>=scena#Serifutag(g:serifu_dic)<CR>

  """ MaruKaKKo 第1:visualモードか否か、第2:ルビ括弧か否か
  vnoremap <buffer> <C-o> :call scena#RubiKakko(1,0)<CR>i
  "nnoremap <buffer> <C-o> :call scena#RubiKakko(0,0)<CR>
  inoremap <buffer> <C-o> <Esc>:call scena#RubiKakko(0,0)<CR>i

  """ JikanKeika
  " 辞書にアイテムが一つなのでcompleteが挿入後機能状態のままなので<Esc>でリセット
  nnoremap <buffer> <C-]> i<C-r>=scena#Assist("g:keika",0,1)<CR><Esc>a
  inoremap <buffer> <C-]> <C-r>=scena#Assist("g:keika",0,1)<CR><Esc>a

  """ Rubi
  vnoremap <buffer> <C-u> :call scena#RubiKakko(1,1)<CR>i
  "nnoremap <buffer> <C-u> :call scena#RubiKakko(0,1)<CR>
  inoremap <buffer> <C-u> <Esc>:call scena#RubiKakko(0,1)<CR>i

  """ Assist Symbol
  nnoremap <buffer> <C-v><C-u> i<C-r>=scena#Assist("g:symbol_dic",0,0)<CR>
  inoremap <buffer> <C-v><C-u> <C-r>=scena#Assist("g:symbol_dic",0,0)<CR>

  """ gomibox
  vnoremap <buffer> <C-g> x:call scena#Gomibox()<CR>

  """ Help
  nnoremap <buffer> <F1> :call <SID>Help()<CR>

  """ SetForm
  nnoremap <buffer> <F9> :call <SID>SetForm(0)<CR>

  """ Reload NameDic
  nnoremap <buffer> <F10> :call <SID>NameDic()<CR>
  inoremap <buffer> <F10> <Esc>:call <SID>NameDic()<CR>

  """ JpCountPages
  nnoremap <buffer> <F11> :call scena#JCP()<CR>
  inoremap <buffer> <F11> <Esc>:call scena#JCP()<CR>

  """ Journal
  nnoremap <buffer> <F12> :call scena#Journal()<CR>
  inoremap <buffer> <F12> <Esc>:call scena#Journal()<CR>

  """ Unite Search
  nnoremap <buffer> /  :<C-u>Unite -buffer-name=search
    \ -horizontal
    \ line:forward -start-insert -no-quit<CR>

  """ Show Unite Outline
  nnoremap <buffer> <C-q> :call <SID>StartUnite()<CR>
  inoremap <buffer> <C-q> <Esc>:call <SID>StartUnite()<CR>i


  """ scenario_modeでは、このmap以外は削除の御呪い
  """ 自前vimrcを有効にするにはvimを再起動、或いは別起動しましょ
  mapclear
  imapclear


    "----------------}}}1
  endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

"*** boot_scena.vim ends here *** {{{
" vim:fdm=marker:fdl=0:
" vim:foldtext=getline(v\:foldstart).'...'.(v\:foldend-v\:foldstart):
