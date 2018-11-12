map /  <Plug>(incsearch-forward)
map s <Plug>(easymotion-overwin-f2)
nnoremap <ESC><ESC> :nohlsearch<CR>
nnoremap h :bp<CR>
nnoremap l :bn<CR>
nnoremap j gj
nnoremap k gk
" set list listchars=tab:\>\-

"文字コードをUFT-8に設定
set fenc=utf-8
" バックアップファイルを作らない
set nobackup
" スワップファイルを作らない
set noswapfile
" 編集中のファイルが変更されたら自動で読み直す
set autoread
" バッファが編集中でもその他のファイルを開けるように
set hidden
set showcmd
set number
set cursorline
set cursorcolumn
set smartindent
set visualbell
set showmatch
" ステータスラインを常に表示
set laststatus=1
" コマンドラインの補完
set wildmode=list:longest
" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
" 検索時に最後まで行ったら最初に戻る
set wrapscan
" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase
" 括弧の対応関係を一瞬表示する
set showmatch
" Vimの「%」を拡張する
source $VIMRUNTIME/macros/matchit.vim
" タブをスペース4つに変換
set tabstop=2
set autoindent
set expandtab
set shiftwidth=2
" クリップボードにコピーできるようにする
set clipboard+=unnamed
" バックスペースキーが使えるようにする
set backspace=2

" クリップボードからペーストする時だけインデントしないようにする。
if &term =~ "xterm"
  let &t_SI .= "\e[?2004h"
  let &t_EI .= "\e[?2004l"
  let &pastetoggle = "\e[201~"

  function XTermPasteBegin(ret)
    set paste
    return a:ret
  endfunction

  inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
endif

" マウスでカーソル移動やスクロール移動が出来るようになります。
if has('mouse')
  set mouse=a
  if has('mouse_sgr')
    set ttymouse=sgr
  elseif v:version > 703 || v:version is 703 && has('patch632')
    set ttymouse=sgr
  else
    set ttymouse=xterm2
  endif
endif

" neobundle settings {{{
if has('vim_starting')
  set nocompatible
  " neobundle をインストールしていない場合は自動インストール
  if !isdirectory(expand("~/.vim/bundle/neobundle.vim/"))
  echo "install neobundle..."
  " vim からコマンド呼び出しているだけ neobundle.vim のクローン
  :call system("git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim")
  endif
  " runtimepath の追加は必須
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif
call neobundle#begin(expand('~/.vim/bundle'))
let g:neobundle_default_git_protocol='https'

" neobundle#begin - neobundle#end の間に導入するプラグインを記載します。
NeoBundleFetch 'Shougo/neobundle.vim'

if has('lua') " lua機能が有効になっている場合
  " コードの自動補完
  NeoBundle 'Shougo/neocomplete.vim'
  " スニペットの補完機能
  NeoBundle "Shougo/neosnippet"
  " スニペット集
  NeoBundle 'Shougo/neosnippet-snippets'
endif

if neobundle#is_installed('neocomplete.vim')
  " Vim起動時にneocompleteを有効にする
  let g:neocomplete#enable_at_startup = 1
  " smartcase有効化. 大文字が入力されるまで大文字小文字の区別を無視する
  let g:neocomplete#enable_smart_case = 1
  " 3文字以上の単語に対して補完を有効にする
  let g:neocomplete#min_keyword_length = 3
  " 区切り文字まで補完する
  let g:neocomplete#enable_auto_delimiter = 1
  " 1文字目の入力から補完のポップアップを表示
  let g:neocomplete#auto_completion_start_length = 1
  " バックスペースで補完のポップアップを閉じる
  inoremap <expr><BS> neocomplete#smart_close_popup()."<C-h>"

  " エンターキーで補完候補の確定. スニペットの展開もエンターキーで確定
  imap <expr><CR> neosnippet#expandable() ? "<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "<C-y>" : "<CR>"
  " タブキーで補完候補の選択. スニペット内のジャンプもタブキーでジャンプ
  imap <expr><TAB> pumvisible() ? "<C-n>" : neosnippet#jumpable() ? "<Plug>(neosnippet_expand_or_jump)" : "<TAB>"
endif

" 多機能セレクタ
NeoBundle 'ctrlpvim/ctrlp.vim'
" CtrlPの拡張プラグイン. 関数検索
NeoBundle 'tacahiroy/ctrlp-funky'
" CtrlPの拡張プラグイン. コマンド履歴検索
NeoBundle 'suy/vim-ctrlp-commandline'

"----------------------------------------------------------
" CtrlPの設定
"----------------------------------------------------------
let g:ctrlp_match_window = 'order:ttb,min:20,max:20,results:100' " マッチウインドウの設定. 「下部に表示, 大きさ20行で固定, 検索結果100件」
let g:ctrlp_show_hidden = 1 " .(ドット)から始まるファイルも検索対象にする
let g:ctrlp_types = ['fil'] "ファイル検索のみ使用
let g:ctrlp_extensions = ['funky', 'commandline'] " CtrlPの拡張として「funky」と「commandline」を使用

" CtrlPCommandLineの有効化
command! CtrlPCommandLine call ctrlp#init(ctrlp#commandline#id())

" CtrlPFunkyの有効化
let g:ctrlp_funky_matchtype = 'path'

NeoBundle 'bronson/vim-trailing-whitespace'
NeoBundle 'fatih/vim-go'
NeoBundle 'haya14busa/incsearch.vim'
NeoBundle 'easymotion/vim-easymotion'
NeoBundle 'tomasr/molokai'
NeoBundle 'cocopon/iceberg.vim'
NeoBundle 'vim-airline/vim-airline'
NeoBundle 'vim-airline/vim-airline-themes'
NeoBundle 'mattn/benchvimrc-vim'
" vimrc に記述されたプラグインでインストールされていないものがないかチェックする
NeoBundleCheck
call neobundle#end()
filetype plugin indent on
set t_Co=256
set spell
set background=dark
syntax on
let g:go_version_warning = 0
let g:molokai_original = 1
let g:rehash256 = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
" vim-airline-themesが必要
let g:airline_theme='behelit'

" カラースキーマを設定
syntax on
colorscheme iceberg
au BufWritePre *.go Fmt
"" highlight 
let g:go_hightlight_functions = 1
let g:go_hightlight_methods = 1
let g:go_hightlight_structs = 1
let g:go_hightlight_interfaces = 1
let g:go_hightlight_operators = 1
let g:go_hightlight_build_constraints = 1
"" GoFmt時にインポートするパッケージを整理(GoFmtはファイル書き込み時に自動的に実行される)
let g:go_fmt_command = "goimports"
