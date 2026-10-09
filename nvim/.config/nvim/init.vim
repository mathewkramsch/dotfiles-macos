" Reuse ~/.vimrc so Vim and Neovim share one config.

set runtimepath^=~/.vim
set runtimepath+=~/.vim/after
let &packpath = &runtimepath

" keep mkview/loadview (used in ~/.vimrc) writing to the same place vim uses
set viewdir=~/.vim/view

source ~/.vimrc

if has('nvim')
  " Neovim doesn't honor `hi NonText guifg=bg` (unlike Vim, which resolves
  " "bg" to #000000) and renders splits via WinSeparator instead of the
  " VertSplit group .vimrc/notes.vim set - so EOB tildes and the split
  " divider need fixing up here. Re-applied on every buffer/window since
  " gruvbox/notes reset highlighting on load. Also mirrors render-markdown's
  " groups onto notes.vim's existing markdown* groups and strips the
  " heading background bands to match Vim's plain-text heading style.
  function! s:ApplyVimParity() abort
    highlight NonText guifg=#000000
    highlight EndOfBuffer guifg=#000000
    highlight WinSeparator guifg=#111111 guibg=NONE

    highlight link RenderMarkdownH1 markdownH1
    highlight link RenderMarkdownH2 markdownH2
    highlight link RenderMarkdownH3 markdownH3
    highlight link RenderMarkdownH4 markdownH4
    highlight link RenderMarkdownH5 markdownH5
    highlight link RenderMarkdownH6 markdownH6
    highlight link RenderMarkdownCode markdownCodeBlock
    highlight link RenderMarkdownCodeInline markdownCode
    highlight link RenderMarkdownBullet markdownListMarker
    highlight link RenderMarkdownUnchecked markdownListMarker
    highlight link RenderMarkdownChecked markdownListMarker
    highlight link RenderMarkdownQuote markdownBlockquote
    highlight link RenderMarkdownHtmlComment htmlComment
    highlight RenderMarkdownH1Bg guibg=NONE
    highlight RenderMarkdownH2Bg guibg=NONE
    highlight RenderMarkdownH3Bg guibg=NONE
    highlight RenderMarkdownH4Bg guibg=NONE
    highlight RenderMarkdownH5Bg guibg=NONE
    highlight RenderMarkdownH6Bg guibg=NONE
  endfunction

  " BufWinEnter/FileType don't reliably fire for a buffer opened as a
  " command-line argument, so VimEnter is a fallback to cover it.
  function! s:ApplyVimParityForInitialBuffer() abort
    if expand('%:e') ==# 'md' || expand('%:e') ==# 'n'
      colorscheme notes
    endif
    call s:ApplyVimParity()
    lua pcall(vim.treesitter.stop)
    lua pcall(function() require('render-markdown').buf_enable() end)
  endfunction

  " Toggle comment with ctrl+/ (terminals send this as <C-_>), using
  " Neovim's built-in gc/gcc comment operator - not available in plain Vim.
  nmap <C-_> gcc
  vmap <C-_> gc

  " On an empty line, build the comment skeleton from 'commentstring' and
  " drop the cursor in the middle (e.g. markdown: '<!-- ' + cursor + ' -->')
  " instead of toggling a comment around nothing.
  function! s:CommentSkeleton() abort
    let l:cs = &commentstring =~# '%s' ? &commentstring : '%s'
    let l:parts = split(l:cs, '%s', 1)
    let l:left = get(l:parts, 0, '')
    let l:right = get(l:parts, 1, '')
    let l:indent = matchstr(getline('.'), '^\s*')
    if l:right ==# ''
      call setline('.', l:indent . l:left)
      startinsert!
    else
      " left/right already carry commentstring's own padding (e.g.
      " '<!-- '/' -->'), so just join them - no extra spaces needed.
      call setline('.', l:indent . l:left . l:right)
      call cursor(line('.'), len(l:indent . l:left) + 1)
      startinsert
    endif
  endfunction

  " gcc is Normal/Visual-only, so run it via <Cmd> (no mode-change event)
  " then relocate the cursor. Can't just shift by length change: surround
  " comments grow on both ends, so find the untouched "core" text instead.
  function! s:ToggleCommentInsert() abort
    if getline('.') =~# '^\s*$'
      call s:CommentSkeleton()
      return
    endif
    let l:col = col('.')
    let l:old = getline('.')
    normal gcc
    let l:new = getline('.')
    let l:indent = matchstr(l:old, '^\s*')
    let l:old_core = l:old[len(l:indent):]
    let l:new_core = l:new[len(l:indent):]
    if strlen(l:new_core) >= strlen(l:old_core)
      let l:idx = stridx(l:new_core, l:old_core)
      let l:left_len = l:idx >= 0 ? l:idx : 0
    else
      let l:idx = stridx(l:old_core, l:new_core)
      let l:left_len = l:idx >= 0 ? -l:idx : 0
    endif
    let l:old_rel = max([l:col - 1 - len(l:indent), 0])
    let l:new_rel = min([max([l:old_rel + l:left_len, 0]), strlen(l:new_core)])
    call cursor(line('.'), len(l:indent) + l:new_rel + 1)
    startinsert
  endfunction
  inoremap <silent> <C-_> <Cmd>call <SID>ToggleCommentInsert()<CR>

  augroup nvim_vim_parity
    autocmd!
    " Plain BufWinEnter, not ColorScheme: this needs to run for every buffer,
    " including ones that never trigger `colorscheme notes` (.vimrc only
    " does that for *.n/*.md), so a ColorScheme hook alone wouldn't cover it.
    autocmd BufWinEnter * call s:ApplyVimParity()

    " Neovim's bundled markdown/lua/help/query ftplugins auto-start
    " treesitter, overriding notes.vim's regex colors. Stop it.
    autocmd FileType * lua pcall(vim.treesitter.stop)

    autocmd VimEnter * ++nested call s:ApplyVimParityForInitialBuffer()
  augroup END
endif

" add padding to split panes
" Updates every window in the tab, not just the current one -- a window
" can shift from leftmost to non-leftmost (e.g. neo-tree opening to its
" left) without itself receiving WinEnter/BufWinEnter, since focus moves
" to the new window instead, so a current-window-only check would leave
" its padding stale until it's clicked into.
function! SetSignColumnByPosition()
  for l:winnr in range(1, winnr('$'))
    let l:signcolumn = win_screenpos(l:winnr)[1] > 1 ? 'yes:1' : 'auto'
    call setwinvar(l:winnr, '&signcolumn', l:signcolumn)
  endfor
endfunction
autocmd WinEnter,WinNew,WinClosed,VimResized,BufWinEnter * call SetSignColumnByPosition()

" In-buffer markdown rendering, installed via Neovim's built-in vim.pack.
" Uses bundled markdown/markdown_inline treesitter parsers, not the
" nvim-treesitter plugin. restart_highlighter stays false (default) so it
" doesn't re-enable the highlighter stopped above; it only needs the parser.
lua << EOF
vim.pack.add({
  { src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/MunifTanjim/nui.nvim' },
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim' },
})
require('neo-tree').setup({})
require('render-markdown').setup({
  -- Default 'overlay' position left-pads each heading's icon with spaces
  -- to match the number of '#' characters it's hiding, so deeper levels
  -- (##, ###, ...) end up progressively indented relative to h1. 'inline'
  -- puts the icon directly at column 0 for every level instead.
  heading = {
    position = 'inline',
    -- Default numbered-box icons (1/2/.../6) stay inline.
    -- Only the sign-column icon is disabled - with line numbers off, the
    -- sign column sits right at the left edge, looking like a stray flag
    -- glyph (󰫎) stuck in front of the heading text.
    sign = false,
  },
})
EOF

" Override .vimrc's <C-t> NERDTreeToggle with Neotree, for Neovim only.
nnoremap <C-t> :Neotree toggle<CR>

