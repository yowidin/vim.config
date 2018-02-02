syntax enable

" Vundle settings
set nocompatible              " be iMproved, required
filetype off                  " required

" 256 Collors support
set t_Co=256

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'Valloric/YouCompleteMe'
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
Plugin 'altercation/vim-colors-solarized'
Plugin 'yowidin/vim-german-spell'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'godlygeek/tabular'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-session'
Plugin 'Chiel92/vim-autoformat'
"Plugin 'vim-scripts/Conque-GDB'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

set modeline
set modelines=10

set background=dark
:silent! colorscheme solarized

set laststatus=2

" White spacing
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab nowrap

nmap <silent> <F3> :NERDTreeTabsToggle<CR>
nmap <silent> <S-F1> :Dox<CR>

nmap <silent> <leader>l :set list!<CR>
nmap <silent> <leader>p :set paste!<CR>
nmap <silent> <leader>h :set hlsearch!<CR>

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=trail:·,tab:▸\ ,eol:¬

" Doxygen settings - no @brief, compact documentation
let g:DoxygenToolkit_briefTag_pre=""
let g:DoxygenToolkit_compactDoc="yes"

let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
let g:UltiSnipsListSnippets="<c-F11>"

let g:ycm_complete_in_comments=1
let g:ycm_collect_identifiers_from_comments_and_strings=1
let g:ycm_autoclose_preview_window_after_completion=1
let g:ycm_autoclose_preview_window_after_insertion=1

let g:nerdtree_tabs_open_on_console_startup=0

let NERDTreeHighlightCursorline=1
let NERDTreeChDirMode=2
let NERDTreeShowHidden=1
let NERDTreeIgnore = ['\.pyc$', '\.swp']

" NERDTree autocommands
augroup nerdtree
   au!
   " Do not open NERDTree if filename is passed as argument to VIM
   "au StdinReadPre * let s:std_in=1
   "au VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

   " Autoclose then NERDTree is a last tab
   au bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
augroup END

" C++ specific stuff
augroup cpp_files
   au!

   " Set companion file extensions and search path
   " Try to search in the directory with `inlide` replaced by `src` frist
   " and then with `include/???/` replaced by `src/`, ommiting first
   " subdirectory
   au BufEnter *.h let b:fswitchdst  = 'cpp,cc' | let b:fswitchlocs = 'reg:/include/src/,reg:|include/.\{-}/|src/|'
   au BufEnter *.hh let b:fswitchdst  = 'cpp,cc' | let b:fswitchlocs = 'reg:/include/src/,reg:|include/.\{-}/|src/|'

   " Setup C++ comments
   au FileType cpp setlocal comments=s1:/**,mb:*,ex:*/,://!,://,s1:/*,mb:*,ex:*/

   " And spacing
   au FileType cpp setlocal tabstop=3 softtabstop=0 expandtab shiftwidth=3 smarttab
augroup END

nnoremap <silent> <F2> :YcmCompleter GoTo<CR>
nnoremap <silent> <C-F2> :YcmCompleter GoToDeclaration<CR>
nnoremap <silent> <S-F2> :YcmCompleter GoToDefinition<CR>

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
" Ctrl+F4 - Open or create a companion file
nnoremap <silent> <C-F4> :call SwitchInBuffer(1)<CR>

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

set backspace=indent,eol,start

noremap <Up>     <NOP>
noremap <Down>   <NOP>
noremap <Left>   <NOP>
noremap <Right>  <NOP>

set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar

set number
set relativenumber

nmap <F8> :TagbarToggle<CR>

"if has('python3')
"    map <F12> :py3f ~/.vim/clang-format3.py<cr>
"    imap <F12> <c-o>:py3f ~/.vim/clang-format3.py<cr>
"else
"    map <F12> :pyf ~/.vim/clang-format.py<cr>
"    imap <F12> <c-o>:pyf ~/.vim/clang-format.py<cr>
"endif
noremap <F12> :Autoformat<CR>
let g:autoformat_autoindent=0
let g:autoformat_retab=0
let g:autoformat_remove_trailing_spaces=0

nnoremap <silent><A-j> :set paste<CR>m`o<Esc>``:set nopaste<CR>
nnoremap <silent><A-k> :set paste<CR>m`O<Esc>``:set nopaste<CR>

" Map buffer navigators
if has('nvim')
   tnoremap <C-h> <C-\><C-n><C-w>h
   tnoremap <C-j> <C-\><C-n><C-w>j
   tnoremap <C-k> <C-\><C-n><C-w>k
   tnoremap <C-l> <C-\><C-n><C-w>l
endif
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

set cino=g0,N-s,l1,t0,c1,C1,(0

"let g:ConqueTerm_CloseOnEnd = 1
"let g:ConqueTerm_StartMessages = 1
"let g:ConqueTerm_CWInsert = 1
"let g:ConqueTerm_ToggleKey = ''
"let g:ConqueTerm_ExecFileKey = ''
"let g:ConqueTerm_SendFileKey = ''
"let g:ConqueTerm_SendVisKey = ''

"let g:ConqueGdb_ToggleBreak = '<F9>'
"let g:ConqueGdb_Run = '<F5>'
"let g:ConqueGdb_Next = '<F10>'
"let g:ConqueGdb_Step = '<F11>'
"let g:ConqueGdb_Print = '<F6>'
"let g:ConqueGdb_Finish = '<S-F5>'

if &term =~ "xterm\\|rxvt\\|screen-256color\\|xterm-256color"
  " use an orange cursor in insert mode
  let &t_SI = "\<Esc>]12;green\x7"
  " use a red cursor otherwise
  let &t_EI = "\<Esc>]12;lightblue\x7"
  silent !echo -ne "\033]12;lightblue\007"
  " reset cursor when vim exits
  au! VimLeave * silent !echo -ne "\033]112\007"
  " use \003]12;gray\007 for gnome-terminal and rxvt up to version 9.21

  " Shapes
  " solid underscore
  let &t_SI .= "\<Esc>[6 q"
  " solid block
  let &t_EI .= "\<Esc>[2 q"
  " 1 or 0 -> blinking block
  " 3 -> blinking underscore
  " Recent versions of xterm (282 or above) also support
  " 5 -> blinking vertical bar
  " 6 -> solid vertical bar
endif

" Mouse support tmux knows the extended mouse mode
set mouse+=a
if &term =~ '^xterm-256color\|^screen'
   set ttymouse=xterm2
endif

" Requires installed powerline fonts.
" See: http://vi.stackexchange.com/questions/5622/how-to-configure-vim-airline-plugin-to-look-like-its-own-project-screenshot
" Font should also be set within the terminal or X file
let g:airline_powerline_fonts=1

" Tagbar settings
let g:tagbar_autoclose=1

" Remap russian characters to english
set langmap=ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ;~QWERTYUIOP{}ASDFGHJKL:\\"ZXCVBNM<>,ёйцукенгшщзхъфывапролджэячсмитьбю;`qwertyuiop[]asdfghjkl\\;'zxcvbnm\\,.

set switchbuf="usetab"

" Store swap files in a separate directory
set swapfile
set dir=$HOME/tmp/vimswap//,.

" Highlight extra white spaces
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" Silent make - cd into a directory, execute the make command and open the
" quickfix window in case of build errors
command -complete=dir -nargs=1 Smake cd <args> | silent make | cd - | cwindow | redraw!

" Don't save sessions automatically
:let g:session_autosave="no"
:let g:session_autoload="no"
