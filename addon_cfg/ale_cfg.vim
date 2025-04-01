" [ale]
let g:ale_enable = 0
let g:ale_set_highlights = 1
let g:ale_sign_error = 'XX'
let g:ale_sign_warning = '!!'
let g:ale_statusline_format = ['X %d', '! %d', 'O ok']
let g:ale_echo_msg_error_str = 'Error'
let g:ale_echo_msg_warning_str = 'Warning'
let g:ale_echo_msg_format = '[%linter%] %severity%: %s'
let g:ale_lint_on_enter = 0
let g:ale_set_loclist = 1
let g:ale_set_quickfix = 0
let g:ale_open_list = 1
let g:ale_keep_list_window_open = 0
let g:ale_list_window_size = 3
let g:ale_virtualtext_cursor = 'disable'
" only run linters named in ale_linters
let g:ale_linters_explicit = 1
let g:ale_linters = {
\ 'verilog': ['verible'],
\ 'systemverilog': ['verible']
\}
function! LinterStatus() abort
  let l:counts = ale#statusline#Count(bufnr(''))
  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors
  let l:filename = expand("%:t")
  return l:counts.total == 0 ? 
    \ printf("[%s]", filename) :
    \ printf("[%s] Error(%d) Warning(%d)", filename, l:all_errors, l:all_non_errors)
endfunction
set statusline=%{LinterStatus()}
let g:ale_floating_window_border = repeat([''], 8)

nnoremap <leader>at :ALEToggle<CR>
" nmap <silent> <C-k> <Plug>(ale_previous_wrap)
" nmap <silent> <C-j> <Plug>(ale_next_wrap)

