"##################################### turning on pathogen plugin manager"
execute pathogen#infect()

"language of the vim's UI"
set langmenu=en_US.UTF-8
"language of the entire vim"
"language messages en

"default WORKING DIRECTORY
":cd D:\code\

"set backupdir=~/.vim/backup//
"set directory=~/.vim/swp//

set number
set cursorline
set mouse=a
set autoindent

filetype plugin indent on

set tabstop=4 softtabstop=0 noexpandtab shiftwidth=4

syntax on


"set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
"set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar


set encoding=utf-8
" kodowanie znakow uzyte w pliku konfiguracyjnym
" przydatne jesli chcemy miec polskie znaki. inne kodowania to np. cp1250, lub iso-8859-2
" lista dostepnych kodowan jest dostepna w vimie
" :he encoding-names

"set guifont=Inconsolata\ for\ Powerline\ Medium\ 11

set ruler
set rulerformat=%40(%y/%{&fenc}/%{&ff}%=%l,%c%V%5(%P%)%)

set list
set listchars=trail:_,tab:>-
set wildmenu
set incsearch
set ignorecase

"###autoformat
"let g:formatterpath = ['C:\Users\bb\node_modules\js-beautify\js\bin']

"###powerline"
"python from powerline.vim import setup as powerline_setup
"python powerline_setup()
"python del powerline_setup
"set laststatus=2
"let g:Powerline_symbols = 'fancy'

"nerdtree"
"let g:NERDTreeDirArrows = 1
"let g:NERDTreeDirArrowExpandable = '▸'
"let g:NERDTreeDirArrowCollapsible = '▾'

autocmd BufEnter * lcd %:p:h
map <C-n> :NERDTreeToggle<CR>

map <F2> :mksession! ~/vim_session <cr> " Quick write session with F2
map <F3> :source ~/vim_session <cr>     " And load session with F3


"##############YouCompleteMe
let g:ycm_global_ycm_extra_conf = "~/.vim/ycm_extra_conf.py"
let g:ycm_key_list_select_completion=[]
let g:ycm_key_list_previous_completion=[]
"###Python support YouCompleteMe
let g:ycm_python_binary_path = '/usr/bin/python3'

"special filetype handling"
autocmd filetype cpp,h set nolist

if has("gui_running")
  " GUI is running or is about to start.
  " Maximize gvim window (for an alternative on Windows, see simalt below).
  set lines=43 columns=94
  set background=dark
  colorscheme solarized
else
  " This is console Vim.

  colorscheme solarized
  set t_Co=256
  let g:solarized_termcolors=256
  set background=dark
  
  if exists("+lines")
    set lines=25
  endif
  if exists("+columns")
    set columns=100
  endif
endif




set nocompatible
source $VIMRUNTIME/vimrc_example.vim
"source $VIMRUNTIME/mswin.vim
"behave mswin


"set diffexpr=MyDiff()
"function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let eq = ''
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      let cmd = '""' . $VIMRUNTIME . '\diff"'
      let eq = '"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
"endfunction

