" .vimrc
syntax on
set nocompatible
set nomodeline
set mouse=a
set clipboard=unnamed
set breakindent
set breakindentopt=shift:2,min:20,sbr
set sidescroll=1
set splitright  " configure vertical split to open new window on the right
set splitbelow  " horizontal split -> new window below
set hlsearch  " so searches are highlighted
set title
set backspace=indent,eol,start
let &showbreak='    ↳ '
autocmd BufRead, BufNewFile *.htm,*.html setlocal tabstop=2 shiftwidth=2 softtabstop=2

" tabs
set shiftwidth=4 smarttab
set expandtab
set tabstop=8 softtabstop=0

" gets rid of autocomments
augroup Format-Options
    autocmd!
    autocmd BufEnter * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
augroup END

" split window config
let g:netrw_altv=1  " makes new window open to left (when press v in filebrowser)
let g:netrw_winsize = 75  " makes new window 75%

" NERDTree config
nnoremap <C-t> :NERDTreeToggle<CR>
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

" cursor to line in insert mode
let &t_SI = "\e[5 q"
let &t_EI = "\e[1 q"

" make cursor change quicker
set ttimeout
set ttimeoutlen=1
set listchars=tab:>-,trail:~,extends:>,precedes:<,space:.
set ttyfast

" keybindings
noremap! jj <ESC>

vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

" maps :W to :w
cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
cnoreabbrev <expr> WQ ((getcmdtype() is# ':' && getcmdline() is# 'WQ')?('wq'):('WQ'))
cnoreabbrev <expr> WQA ((getcmdtype() is# ':' && getcmdline() is# 'WQA')?('wqa'):('WQA'))
cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
cnoreabbrev <expr> WQa ((getcmdtype() is# ':' && getcmdline() is# 'WQa')?('wqa'):('WQa'))
cnoreabbrev <expr> Wqa ((getcmdtype() is# ':' && getcmdline() is# 'Wqa')?('wqa'):('Wqa'))
cnoreabbrev <expr> WqA ((getcmdtype() is# ':' && getcmdline() is# 'WqA')?('wqa'):('WqA'))

" plugins
call plug#begin('~/.vim/plugged')
	Plug 'morhetz/gruvbox'
	Plug 'yuezk/vim-js'
	Plug 'maxmellon/vim-jsx-pretty'
	Plug 'preservim/nerdtree'
	Plug 'uiiaoo/java-syntax.vim'
	Plug 'junegunn/goyo.vim'
"	Plug 'dracula/vim', {'as': 'dracula'}
"	Plug 'xuhdev/vim-latex-live-preview'
"	Plug 'instant-markdown/vim-instant-markdown', {'for': 'markdown', 'do': 'yarn install'}
call plug#end()

" java syntax highlighting
highlight link javaIdentifier NONE
highlight link javaDelimiter NONE

" instant markdown preview
let g:instant_markdown_autostart = 0
command P InstantMarkdownPreview

" gruvbox color scheme
set termguicolors
let g:gruvbox_italic=0
let g:gruvbox_contrast_dark = 'hard'
set t_Co=256

colorscheme gruvbox
" colorscheme dracula
set background=dark

" keeps transparency with gruvbox
highlight Normal     ctermbg=NONE guibg=NONE
highlight LineNr     ctermbg=NONE guibg=NONE
highlight SignColumn ctermbg=NONE guibg=NONE
 
" disables status bar in split mode
set laststatus=0

" hides the line,col + scroll-percent ("All") ruler at the bottom right,
" which would otherwise still show up in the command-line row since
" laststatus=0 hides the per-window statusline, not the ruler itself
set noruler

" cursor line highlight
set cursorline
highlight cursorline ctermbg=NONE guibg=#060606
autocmd InsertEnter * highlight cursorline guibg=#0b0b0b
autocmd InsertLeave * highlight cursorline guibg=#060606

" custom mode indicator -- replaces the plain "-- INSERT --"/"-- VISUAL --"
" showmode text with a colored "pill" (INSERT in H1's green, VISUAL in H2's
" aqua), since 'ModeMsg' alone can't give different modes different colors
set noshowmode

" Re-applied on every colorscheme change (not just defined once here) --
" `colorscheme notes` runs `hi clear` for *.n/*.md buffers, which would
" otherwise silently wipe these two groups out the first time it fires.
function! s:SetModeIndicatorHighlights() abort
  highlight InsertModeIndicator guifg=#000000 guibg=#b8bb26 gui=bold cterm=bold
  highlight VisualModeIndicator guifg=#000000 guibg=#8ec07c gui=bold cterm=bold
endfunction
autocmd ColorScheme * call s:SetModeIndicatorHighlights()
call s:SetModeIndicatorHighlights()

function! s:ShowModeIndicator(hl, text) abort
  execute 'echohl ' . a:hl
  echo a:text
  echohl None
endfunction

function! s:ClearModeIndicator() abort
  echo ''
endfunction

augroup custom_mode_indicator
  autocmd!
  autocmd InsertEnter * call s:ShowModeIndicator('InsertModeIndicator', v:insertmode ==# 'i' ? ' INSERT ' : ' REPLACE ')
  autocmd InsertLeave * call s:ClearModeIndicator()
  autocmd ModeChanged *:[vV\x16]* call s:ShowModeIndicator('VisualModeIndicator', ' VISUAL ')
  autocmd ModeChanged [vV\x16]*:* call s:ClearModeIndicator()
augroup END

map tg gT
map H 30h
map J 4j
map K 4k
map L 30l

set nowrap

augroup remember_folds
  autocmd!
  autocmd BufWinLeave * mkview
  autocmd BufWinEnter * silent! loadview
augroup END

" tab bar config
hi TabLineFill guibg=NONE
hi TabLineSel guibg=#111111

" folding
hi Folded guibg=#070707
set foldtext=getline(v:foldstart)
set fcs=fold:\ ,vert:\|

" syntax highlighting for notes
" ++nested so the ColorScheme autocmd it triggers actually fires -- plugins
" like neo-tree hook ColorScheme to rebuild their `highlight default` groups
" (e.g. NeoTreeRootName's bold/italic), and without nesting that rebuild
" never runs, silently losing that styling the first time this fires.
autocmd BufWinEnter *.n,*.md ++nested colorscheme notes
autocmd BufWinEnter *.n set nonumber
autocmd BufWinEnter *.n set foldcolumn=2
autocmd BufWinEnter *.n set autoindent

" changes look of split dividers -- thin line instead of a filled block
set fillchars+=vert:│,stl:─,stlnc:─
highlight VertSplit guifg=#111111 guibg=NONE gui=NONE cterm=NONE
highlight StatusLine guifg=#111111 guibg=NONE gui=NONE cterm=NONE
highlight StatusLineNC guifg=#111111 guibg=NONE gui=NONE cterm=NONE

" hide empty line character
hi NonText guifg=bg
