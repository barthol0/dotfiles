""language of the vim's UI"
set langmenu=en_US.UTF-8

" turn hybrid line numbers on
set number relativenumber
set nu rnu

set cursorline
set mouse=a
set autoindent

filetype plugin indent on

set tabstop=4 softtabstop=0 noexpandtab shiftwidth=4

syntax on

set encoding=utf-8

set ruler
set rulerformat=%40(%y/%{&fenc}/%{&ff}%=%l,%c%V%5(%P%)%)

set list
set listchars=trail:_,tab:>-
set wildmenu
set incsearch
set ignorecase

"nerdtree"
"let g:NERDTreeDirArrows = 1
"let g:NERDTreeDirArrowExpandable = '▸'
"let g:NERDTreeDirArrowCollapsible = '▾'

autocmd BufEnter * lcd %:p:h
map <C-n> :NERDTreeToggle<CR>
