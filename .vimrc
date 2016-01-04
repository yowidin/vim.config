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

" Tries to open an existing companion file
" in either new or existing screen buffer.
function! SwitchInBuffer()
   try   
      " This function may throw (e.g. invalid file type) 
      let l:path = FSReturnReadableCompanionFilename('%')
      if empty(l:path)
         " Or companion file may not exist
         echom 'Could not find companion file!'
         return
      endif

      try
         " Try to activate existing buffer
         call MySwitchBuf(l:path)
      catch
         " Or open new one if it's not open
         execute 'vsplit | wincmd l | e ' . l:path
      endtry
   catch
      echom 'Error getting companion file!'
   endtry
endfunction

" F4 - Open companion file
nnoremap <silent> <F4> :call SwitchInBuffer()<CR>


" F6 - Search for a word under cursor into all files within the directory 
map <F6> :noautocmd execute "vimgrep /" . expand("<cword>") . "/j %:p:h/**" <Bar> cw<CR>

function! InputGrep()
   try 
      call inputsave()
      let text = input('Enter text: ')
      call inputrestore()
      if !empty(text)
         execute "vimgrep /" . text . "/j %:p:h/**"
         execute "cw"
      else
         echom "Search string is empty!"
      endif
   catch
      echom "Nothing found!"
   endtry
endfunction

" Ctrl+Shift+F - Ask user for a input string and search for it into all files within
" current file's directory
nnoremap <silent> <C-S-F> :call InputGrep()<CR>

" Ctrl+Shift+B - make in the current directory
nnoremap <C-S-B> :make<CR>
