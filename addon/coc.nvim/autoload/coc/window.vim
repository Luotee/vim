let g:coc_max_treeview_width = get(g:, 'coc_max_treeview_width', 40)
let s:is_vim = !has('nvim')

" Get tabpagenr of winid, return -1 if window doesn't exist
function! coc#window#tabnr(winid) abort
  " getwininfo not work with popup on vim
  if exists('*win_execute')
    let ref = {}
    call win_execute(a:winid, 'let ref["out"] = tabpagenr()')
    return get(ref, 'out', -1)
  endif
  let info = getwininfo(a:winid)
  return empty(info) ? -1 : info[0]['tabnr']
endfunction

" (1, 0) based line, column
function! coc#window#get_cursor(winid) abort
  if exists('*nvim_win_get_cursor')
    return nvim_win_get_cursor(a:winid)
  endif

  let pos = getcurpos(a:winid)
  return [pos[1], pos[2] - 1]
endfunction

" Check if winid visible on current tabpage
function! coc#window#visible(winid) abort
  if s:is_vim
    if coc#window#tabnr(a:winid) != tabpagenr()
      return 0
    endif
    " Check possible hidden popup
    try
      return get(popup_getpos(a:winid), 'visible', 0) == 1
    catch /^Vim\%((\a\+)\)\=:E993/
      return 1
    endtry
  endif
  if !nvim_win_is_valid(a:winid)
    return 0
  endif
  return coc#window#tabnr(a:winid) == tabpagenr()
endfunction

" winid is popup and shown
function! s:visible_popup(winid) abort
  let popups = popup_list()
  if index(popups, a:winid) != -1
    return get(popup_getpos(a:winid), 'visible', 0) == 1
  endif
  return 0
endfunction

" Return v:null when name or window doesn't exist,
" 'getwinvar' only works on window of current tab
function! coc#window#get_var(winid, name, ...) abort
  if !s:is_vim
    try
      if a:name =~# '^&'
        if has('nvim-0.10')
          return nvim_get_option_value(a:name[1:], {'win': a:winid})
        else
          return nvim_win_get_option(a:winid, a:name[1:])
        endif
      else
        return nvim_win_get_var(a:winid, a:name)
      endif
    catch /E5555/
      return get(a:, 1, v:null)
    endtry
  else
    try
      return coc#api#exec('win_get_var', [a:winid, a:name, get(a:, 1, v:null)])
    catch /Invalid window id/
      return get(a:, 1, v:null)
    endtry
  endif
endfunction

" Not throw like setwinvar
function! coc#window#set_var(winid, name, value) abort
  try
    if !s:is_vim
      if a:name =~# '^&'
        if has('nvim-0.10')
          call nvim_set_option_value(a:name[1:], a:value, {'win': a:winid})
        else
          call nvim_win_set_option(a:winid, a:name[1:], a:value)
        endif
      else
        call nvim_win_set_var(a:winid, a:name, a:value)
      endif
    else
      call coc#api#exec('win_set_var', [a:winid, a:name, a:value])
    endif
  catch /Invalid window id/
    " ignore
  endtry
endfunction

function! coc#window#is_float(winid) abort
  if s:is_vim
    try
      return !empty(popup_getpos(a:winid))
    catch /^Vim\%((\a\+)\)\=:E993/
      return 0
    endtry
  else
    let config = nvim_win_get_config(a:winid)
    return !empty(config) && !empty(get(config, 'relative', ''))
  endif
endfunction

" Reset current lnum & topline of window
function! coc#window#restview(winid, lnum, topline) abort
  if empty(getwininfo(a:winid))
    return
  endif
  if s:is_vim && s:visible_popup(a:winid)
    call popup_setoptions(a:winid, {'firstline': a:topline})
    return
  endif
  call coc#compat#execute(a:winid, ['noa call winrestview({"lnum":'.a:lnum.',"topline":'.a:topline.'})'])
endfunction

function! coc#window#set_height(winid, height) abort
  if empty(getwininfo(a:winid))
    return
  endif
  if exists('*nvim_win_set_height')
    call nvim_win_set_height(a:winid, a:height)
  else
    call coc#compat#execute(a:winid, 'noa resize '.a:height, 'silent')
  endif
endfunction

function! coc#window#adjust_width(winid) abort
  let bufnr = winbufnr(a:winid)
  if bufloaded(bufnr)
    let maxwidth = 0
    let lines = getbufline(bufnr, 1, '$')
    if len(lines) > 2
      call coc#compat#execute(a:winid, 'setl nowrap')
      for line in lines
        let w = strwidth(line)
        if w > maxwidth
          let maxwidth = w
        endif
      endfor
    endif
    if maxwidth > winwidth(a:winid)
      call coc#compat#execute(a:winid, 'vertical resize '.min([maxwidth, g:coc_max_treeview_width]))
    endif
  endif
endfunction

" Get single window by window variable, current tab only
function! coc#window#find(key, val) abort
  for i in range(1, winnr('$'))
    let res = getwinvar(i, a:key)
    if res == a:val
      return win_getid(i)
    endif
  endfor
  return -1
endfunction

" Visible buffer numbers
function! coc#window#bufnrs() abort
  let winids = []
  if exists('*nvim_list_wins')
    let winids = nvim_list_wins()
  else
    let winids = map(getwininfo(), 'v:val["winid"]')
  endif
  return uniq(map(winids, 'winbufnr(v:val)'))
endfunction

function! coc#window#buf_winid(bufnr) abort
  let winids = map(getwininfo(), 'v:val["winid"]')
  for winid in winids
    if winbufnr(winid) == a:bufnr
      return winid
    endif
  endfor
  return -1
endfunction

" Avoid errors
function! coc#window#close(winid) abort
  if empty(a:winid) || a:winid == -1
    return
  endif
  if coc#float#valid(a:winid)
    call coc#float#close(a:winid)
    return
  endif
  if exists('*nvim_win_is_valid') && exists('*nvim_win_close')
    if nvim_win_is_valid(a:winid)
      call nvim_win_close(a:winid, 1)
    endif
  else
    call coc#compat#execute(a:winid, 'noa close!', 'silent!')
  endif
endfunction

function! coc#window#visible_range() abort
  let winid = win_getid()
  if winid == 0
    return v:null
  endif
  let info = getwininfo(winid)[0]
  return [info['topline'], info['botline']]
endfunction

function! coc#window#visible_ranges(bufnr) abort
  let wins = gettabinfo(tabpagenr())[0]['windows']
  let res = []
  for id in wins
    let info = getwininfo(id)[0]
    if info['bufnr'] == a:bufnr
      call add(res, [info['topline'], info['botline']])
    endif
  endfor
  return res
endfunction
