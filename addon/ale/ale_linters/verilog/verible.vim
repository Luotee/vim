" Author: Zeger Van de Vannet
" Description: Verible (verilog_lint) for verilog files

" Set this option to change verible lint options
if !exists('g:ale_verilog_verible_options')
    let g:ale_verilog_verible_options = ''
endif

function! ale_linters#verilog#verible#GetCommand(buffer) abort
    let l:filename = ale#util#Tempname() . '_verible_linted.v'
    call ale#command#ManageFile(a:buffer, l:filename)
    let l:lines = getbufline(a:buffer, 1, '$')
    call ale#util#Writefile(a:buffer, l:lines, l:filename)

    return 'verible-verilog-lint '
    \ . ale#Var(a:buffer, 'verilog_verible_options') . ' '
    \ . ale#Escape(l:filename)
endfunction

function! ale_linters#verilog#verible#Handle(buffer, lines) abort
    let l:output = []

    let l:pattern = '\([^:]\+\):\([^:]\+\):\([^:]\+\):\([^:]\+\)'

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:line = l:match[2] + 0
        let l:type = l:match[4] =~# 'error' ? 'E' : 'W'
        let l:text = l:match[4]

        call add(l:output, {
        \   'lnum': l:line,
        \   'text': l:text,
        \   'type': l:type,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('verilog', {
\   'name': 'verible',
\   'output_stream': 'stdout',
\   'executable': 'verible-verilog-lint',
\   'command': function('ale_linters#verilog#verible#GetCommand'),
\   'callback': 'ale_linters#verilog#verible#Handle',
\   'read_buffer': 0,
\})