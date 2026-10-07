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
    highlight WinSeparator guibg=#111111 guifg=#111111

    highlight link RenderMarkdownH1 markdownH1
    highlight link RenderMarkdownH2 markdownH2
    highlight link RenderMarkdownH3 markdownH3
    highlight link RenderMarkdownH4 markdownH4
    highlight link RenderMarkdownH5 markdownH5
    highlight link RenderMarkdownH6 markdownH6
    highlight link RenderMarkdownCode markdownCode
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

  augroup nvim_vim_parity
    autocmd!
    " Plain BufWinEnter, not ColorScheme: .vimrc's BufWinEnter autocmd sets
    " `colorscheme notes` for *.n/*.md, and non-nested autocmds don't chain,
    " so a ColorScheme hook would never fire for those buffers.
    autocmd BufWinEnter * call s:ApplyVimParity()

    " Neovim's bundled markdown/lua/help/query ftplugins auto-start
    " treesitter, overriding notes.vim's regex colors. Stop it.
    autocmd FileType * lua pcall(vim.treesitter.stop)

    autocmd VimEnter * ++nested call s:ApplyVimParityForInitialBuffer()
  augroup END
endif

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
