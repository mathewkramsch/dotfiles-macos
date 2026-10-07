" Make Neovim use the exact same config/plugins/colors as regular Vim.
" No separate nvim config to maintain - this just points nvim at ~/.vim
" and sources ~/.vimrc directly, so both editors stay in sync automatically.

set runtimepath^=~/.vim
set runtimepath+=~/.vim/after
let &packpath = &runtimepath

" keep mkview/loadview (used in ~/.vimrc) writing to the same place vim uses
set viewdir=~/.vim/view

source ~/.vimrc
