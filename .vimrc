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
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'majutsushi/tagbar'
Plugin 'DoxygenToolkit.vim'
Plugin 'scrooloose/nerdcommenter'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

colorscheme hybrid_material
let g:airline_theme = "hybrid"
set laststatus=2

set tabstop=3 softtabstop=0 expandtab shiftwidth=3 smarttab

map <F3> :NERDTreeToggle<CR>

" CTRL+S+TAB - previous tab
nmap <silent> <C-S-Tab> :tabprevious<CR>

" CTRL+TAB - next tab
nmap <silent> <C-Tab> :tabnext<CR>

nmap <silent> <S-F1> :Dox<CR>

" Autoclose then NERDTree is a last tab
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

set nowrap

let g:DoxygenToolkit_compactOneLineDoc="yes"
let g:DoxygenToolkit_briefTag_pre=""

let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
let g:UltiSnipsListSnippets="<c-F11>"

let g:ycm_complete_in_comments=1

let g:nerdtree_tabs_open_on_console_startup=1

let NERDTreeHighlightCursorline=1
let NERDTreeChDirMode=2
let NERDTreeShowHidden=1

nnoremap <silent> <F5> :YcmCompleter GoTo<CR>
nnoremap <silent> <C-F5> :YcmCompleter GoToDeclaration<CR>
nnoremap <silent> <S-F5> :YcmCompleter GoToDefinition<CR>

augroup mycppfiles
   au!
   au BufEnter *.h let b:fswitchdst  = 'cpp,cc'
 augroup END

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

function! CreateCompanionFile()
   try
      let l:path = FSReturnCompanionFilenameString('%')
      " Create new one 
      execute 'vsplit | wincmd l | e ' . l:path
   catch
      echom "Cannot create a companion file!"
   endtry
endfunction

" Tries to open an existing companion file
" in either new or existing screen buffer.
function! SwitchInBuffer(create)
   try   
      " This function may throw (e.g. invalid file type) 
      let l:path = FSReturnReadableCompanionFilename('%')
      if empty(l:path)
         " Or companion file may not exist
         if a:create == 1
            call CreateCompanionFile()
         else
            echom 'Could not find companion file!'
            return
         endif
      endif

      try
         " Try to activate existing buffer
         call MySwitchBuf(l:path)
      catch
         " Or open new one if it's not open
         execute 'vsplit | wincmd l | e ' . l:path
      endtry
   catch
      if a:create == 1
         call CreateCompanionFile()
      else
         echom 'Error getting companion file!'
      endif
   endtry
endfunction

" F4 - Open companion file
nnoremap <silent> <F4> :call SwitchInBuffer(0)<CR>
" Ctrl+F4 - Open companion file
nnoremap <silent> <C-F4> :call SwitchInBuffer(1)<CR>


" F6 - Search for a word under cursor into all files within the directory 
map <F6> :noautocmd execute "vimgrep /" . expand("<cword>") . "/j %:p:h/**" <Bar> cw<CR>

function! InputGrep()
   try 
      call inputsave()
      let text = input('Enter text: ')
      call inputrestore()
      if !empty(text)
         execute "noautocmd vimgrep /" . text . "/j %:p:h/**"
         execute "cw"
      else
         echom "Search string is empty!"
      endif
   catch
      echom "Nothing found!"
   endtry
endfunction

" Ctrl+F - Ask user for a input string and search for it into all files within
" current file's directory
nnoremap <silent> <C-F> :call InputGrep()<CR>

" Ctrl+B - make in the current directory
nnoremap <silent> <C-B> :redir @a<CR>:make<CR>:redir END<CR>:below new<CR>"ap:setlocal buftype=nofile<CR>

set backspace=indent,eol,start

noremap <Up>     <NOP>
noremap <Down>   <NOP>
noremap <Left>   <NOP>
noremap <Right>  <NOP>

nmap <c-s> :w<CR>
imap <c-s> <Esc>:w<CR>
nmap <D-s> :w<CR>
imap <D-s> <Esc>:w<CR>a

nmap <c-z> :undo<CR>
imap <c-z> <Esc>:undo<CR>
nmap <D-z> :undo<CR>
imap <D-z> <Esc>:undo<CR>

map <silent> <Left> :wincmd h<CR>
map <silent> <Right> :wincmd l<CR>
map <silent> <Up> :wincmd k<CR>
map <silent> <Down> :wincmd j<CR>

set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar

set number
set relativenumber

nmap <F8> :TagbarToggle<CR>

map <F12> :pyf ~/.vim/clang-format.py<cr>
imap <F12> <c-o>:pyf ~/.vim/clang-format.py<cr>

