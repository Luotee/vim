" windows: put in $HOME/vimefiles/vimrcs
  " set encoding=utf-8
  " set runtimepath+=$HOME/OneDrive/.vim
  " source $HOME/OneDrive/.vim/.vimrc

" font setting for all platform
if has("gui_running")
  if has("gui_gtk2")
    set guifont=Microsoft\ JhengHei\ Mono\ 15
  elseif has("gui_macvim")
    set guifont=Menlo\ Regular:h14
  elseif has("gui_win32")
    set guifont=YaHei\ Consolas\ Hybrid:h12
  endif
endif

let mapleader=","


let g:plugin_list = [
    \ "'morhetz/gruvbox'",
    \ "'preservim/nerdtree'",
    \ "'preservim/nerdcommenter'",
    \ "'mg979/vim-visual-multi'",
    \ "'matze/vim-move'",
    \ "'dense-analysis/ale'",
    \ "'juneedahamed/svnj.vim'",
    \ "'MTDL9/vim-log-highlighting'"
    \ ]

call plug#begin('$HOME/OneDrive/.vim/addon')
for plugin in g:plugin_list
  " echo plugin
  execute 'Plug ' . plugin
endfor
call plug#end()

let cfg_path = expand('$HOME/OneDrive/.vim/addon_cfg')
for plugin in g:plugin_list
    let plugin_name = matchstr(plugin, "'[^/]\\+/\\zs[^'/]\\+") . '_cfg.vim'
    let cfg_full_path = cfg_path . '/' . plugin_name
    if filereadable(cfg_full_path)
      execute 'source ' . cfg_full_path
    else
      echo 'missing cfg file: ' . plugin_name
    endif
endfor
" print blank line in last to avoid windows display bug
echo ""


nnoremap <Tab> >>_
nnoremap <S-Tab> <<_
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
inoremap <S-Tab> <Esc><<i



" [vim settings]
" tab completion menu
set wildmenu
set wildignorecase
set wildmode=full
" show line numbers
set nu
" underline current line
set cursorline
" show column/row info (default=on)
set ruler
" color the code
syntax enable
" show horizontal scrollbar
set guioptions+=b
" auto-indent when line break
set ai
" tab space
set tabstop=2
" tab indent unit
set shiftwidth=2
" switch tab by space
set expandtab
" enable backspace in insert mode (default=on)
set backspace=2
" file type auto-indent
filetype indent on
" enable mouse cursor
set mouse=a
" realtime show the search result
set incsearch
" hightlight search
set hlsearch
" disable search when press double <Esc>
nnoremap <silent> <Esc><Esc> :noh<CR>
" command record limit
set history=100


nnoremap <leader>vm :vsp $MYVIMRC<CR>
nnoremap <leader>vs :source $MYVIMRC<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>e :e<CR>
nnoremap <leader>df :windo diffthis<CR>
nnoremap <leader>du :windo diffupdate<CR>
nnoremap <leader>do :windo diffoff<CR>
vnoremap <leader>dp :diffput<CR>
nnoremap <leader>ft :setfiletype
vnoremap <leader>lw :set wrap!<CR>
nnoremap <leader>p :let @*=expand("%:p")<CR> :let @+=expand("%:p")<CR>

vnoremap <C-c> "+y gv
vnoremap <C-x> "+c
vnoremap <C-v> c<ESC>"+p
inoremap <C-v> <C-r><C-o>+
cnoremap <C-v> <C-r>+
nnoremap <C-v> "+p

vnoremap <C-f> y/<C-r>0<CR>
