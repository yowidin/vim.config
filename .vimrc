:syntax enable

" Vundle settings
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'rdnetto/YCM-Generator'
Plugin 'git://github.com/kristijanhusak/vim-hybrid-material.git'
Plugin 'bling/vim-airline'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-fugitive'
Bundle 'jistr/vim-nerdtree-tabs'
Plugin 'derekwyatt/vim-fswitch'


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

colorscheme hybrid_material
let g:airline_theme = "hybrid"
set laststatus=2

set tabstop=3 softtabstop=0 expandtab shiftwidth=3 smarttab

" NERDTree settings
" Hotkey
map <F3> :NERDTreeToggle<CR>

" Autoclose then NERDTree is a last tab
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

set nowrap

let g:nerdtree_tabs_open_on_console_startup=1
let NERDTreeHighlightCursorline=1
let NERDTreeChDirMode=2
let NERDTreeShowHidden=1

nnoremap <silent> <F5> :YcmCompleter GoTo<CR>

" CTRL+S+TAB - previous tab
nmap <silent> <C-S-Tab> :tabprevious<CR>

" CTRL+TAB - next tab
nmap <silent> <C-Tab> :tabnext<CR>

function! MySwitchBuf(filename)
  " remember current value of switchbuf
  let l:old_switchbuf = &switchbuf
  try
    " change switchbuf so other windows and tabs are used
    set switchbuf=useopen,usetab
    execute 'vertical sbuf' a:filename
  finally
    " restore old value of switchbuf
    let &switchbuf = l:old_switchbuf
  endtry
endfunction

function! SwitchInBuffer()
   try
      let l:path = FSReturnReadableCompanionFilename('%')
      call MySwitchBuf(l:path)
   catch
      echom "Cannot detect companion file name!"
   finally
   endtry
endfunction

nnoremap <silent> <F4> :call SwitchInBuffer()<CR>


" F6 - Search for a word under cursor into all files within the directory 
map <F6> :noautocmd execute "vimgrep /" . expand("<cword>") . "/j %:p:h/**" <Bar> cw<CR>

function! InputGrep()
  call inputsave()
  let text = input('Enter text: ')
  call inputrestore()
  execute "vimgrep /" . text . "/j %:p:h/**"
  execute "cw"
endfunction

" F7 - Ask user for a input strin and search for it into all files within
" current file's directory
nnoremap <silent> <F7> :call InputGrep()<CR>

" F9 - make in the current directory
nnoremap <F9> :make<CR>
