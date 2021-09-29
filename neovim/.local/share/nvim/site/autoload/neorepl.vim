scriptencoding utf-8

if !has('nvim')
  finish
endif

let s:defaults = {
      \ 'repls': {
      \   'shell': {
      \     'exe': &shell,
      \   },
      \   'sh': {},
      \   'bash': {},
      \   'zsh': {},
      \   'fish': {},
      \   'irb': {},
      \   'node': {},
      \   'bpython': {},
      \   'ipython': {},
      \   'python': {},
      \   'python2': {},
      \   'python3': {},
      \   'ocaml': {},
      \   'utop': {},
      \   'ghci': {},
      \   'stack': { 'args': ['ghci'] },
      \   'scala': {},
      \},
      \ 'filetypes': {
      \   'sh': 'sh',
      \   'bash': 'bash',
      \   'zsh': 'zsh',
      \   'fish': 'fish',
      \   'ruby': 'irb',
      \   'javascript': 'node',
      \   'python': ['bpython', 'ipython', 'python', 'python3', 'python2'],
      \   'ocaml': ['utop', 'ocaml'],
      \   'haskell': ['stack', 'ghci'],
      \   'scala': 'scala',
      \},
      \ 'default': 'shell',
      \ 'window': '15new',
      \}

function! s:defaults.repls.ocaml.transform(lines) abort
  if empty(a:lines)
    return ''
  endif

  return join(copy(a:lines), "\n") . ";;\n"
endfunction

let s:defaults.repls.utop.transform = s:defaults.repls.ocaml.transform

function! s:open_win() abort
  execute 'silent '.get(g:, 'neorepl_window', s:defaults.window)
  setlocal winfixwidth winfixheight bufhidden=wipe nospell
  return win_getid()
endfunction

function! s:new_repl(template) abort
  let a:template.buf = bufnr('')
  let a:template.id = termopen([a:template.exe] + a:template.args, a:template)
  try
    if a:template.name ==# a:template.type
      execute 'silent file! repl://'.fnameescape(a:template.type)
    else
      execute 'silent file! repl://'.fnameescape(a:template.type).
            \ ' ('.fnameescape(a:template.name).')'
    endif
  catch
  endtry
  silent normal! G
  return a:template
endfunction

let s:active = { 'open': {} }

function! s:active.remove(buf) abort
  if has_key(l:self.open, a:buf)
    if bufloaded(a:buf)
      execute 'silent bd!' a:buf
    endif

    call remove(l:self.open, a:buf)
  endif
endfunction

function! s:active.open_new(repl, ft) abort
  if !has_key(t:, 'neorepl_win') || !win_gotoid(t:neorepl_win)
    let t:neorepl_win = s:open_win()
  else
    enew | setlocal bufhidden=wipe
  endif

  function! a:repl.on_exit(id, code, _event) abort
    call s:active.remove(l:self.buf)
  endfunction
  let l:repl = s:new_repl(a:repl)
  let l:self.open[l:repl.buf] = l:repl

  setlocal bufhidden=hide nobuflisted
  silent doautocmd <nomodeline> User NeoReplOpen
  let t:neorepl_last = l:repl.buf
  return l:repl.buf
endfunction

function! s:active.switch_active(buf) abort
  if !bufexists(a:buf)
    return 0
  endif

  if !has_key(t:, 'neorepl_win') || !win_gotoid(t:neorepl_win)
    let t:neorepl_win = s:open_win()
  endif

  execute 'silent b!' a:buf
  setlocal bufhidden=hide nobuflisted
  silent doautocmd <nomodeline> User NeoReplOpen
  let t:neorepl_last = a:buf
  return a:buf
endfunction

function! s:active.find(name) abort
  for l:r in values(l:self.open)
    if l:r.name ==# a:name
      return l:r
    endif
  endfor
  return {}
endfunction

function! neorepl#dump() abort
  echom string(s:active)
endfunction

function! neorepl#open(...) abort
  let l:name = get(a:000, 0, '')
  let l:base = get(a:000, 1, l:name)
  let l:ft = &filetype

  if !empty(l:base)
    let l:repl = s:active.find(l:name)
    if !empty(l:repl)
      return s:active.switch_active(l:repl.buf)
    endif

    let l:repl = neorepl#get_repl(l:name, l:base)
    if !empty(l:repl) && !executable(l:repl.exe)
      let l:repl = {}
    endif
  else
    let l:repls = empty(l:ft) ? [] : neorepl#get_repls(l:ft)

    for l:n in l:repls
      let l:r = s:active.find(l:n)
      if !empty(l:r) && s:active.switch_active(l:r.buf)
        return l:r.buf
      endif
    endfor

    call filter(map(l:repls, 'neorepl#get_repl(v:val)'),
          \ '!empty(v:val) && executable(v:val.exe)')

    if empty(l:repls)
      if has_key(t:, 'neorepl_last') &&
            \ s:active.switch_active(t:neorepl_last)
        return t:neorepl_last
      else
        let l:repl = neorepl#get_repl(get(g:, 'neorepl_default', s:defaults.default))
      endif
    else
      let l:repl = get(l:repls, 0, {})
    endif
  endif

  return empty(l:repl) ? 0 : s:active.open_new(l:repl, l:ft)
endfunction

function! neorepl#open_last() abort
  if has_key(t:, 'neorepl_last')
    return s:active.switch_active(t:neorepl_last)
  endif
  return 0
endfunction

function! neorepl#stop(...) abort
  let l:names = copy(a:000)
  call filter(l:names, '!empty(v:val)')

  if empty(l:names)
    for l:r in values(copy(s:active.open))
      call jobstop(l:r.id)
      call s:active.remove(l:r.buf)
    endfor
  else
    for l:r in values(copy(s:active.open))
      if index(l:names, l:r.name) >= 0
        call jobstop(l:r.id)
        call s:active.remove(l:r.buf)
      endif
    endfor
  endif
endfunction

function! neorepl#reset(...) abort
  call call('neorepl#stop', a:000)
  return call('neorepl#open', a:000)
endfunction

function! neorepl#close() abort
  if !has_key(t:, 'neorepl_win') || !win_gotoid(t:neorepl_win)
    return
  endif
  close
  silent doautocmd <nomodeline> User NeoReplClose
endfunction

function! neorepl#send(lines, ...) abort
  let l:buf = call('neorepl#open', a:000)
  if !l:buf
    return
  endif

  let l:repl = get(s:active.open, l:buf, {})
  if !empty(l:repl)
    if type(get(l:repl, 'transform')) == type(function('tr'))
      let l:data = l:repl.transform(a:lines)
    else
      let l:data = add(copy(a:lines), '')
    endif

    call jobsend(l:repl.id, l:data)
    normal! G
  endif
endfunction

function! neorepl#get_repl(name, ...) abort
  if empty(a:name)
    return {}
  endif

  let l:base = get(a:000, 0, a:name)
  let l:repls = deepcopy(s:defaults.repls)
  call extend(l:repls, get(g:, 'neorepl_repls', {}))
  let l:template = get(l:repls, l:base, {})

  if !empty(l:template)
    call extend(l:template, { 'name': a:name, 'type': l:base })
    call extend(l:template, { 'exe': l:base, 'args': [] }, 'keep')
  endif
  return l:template
endfunction

function! neorepl#get_repls(ft) abort
  let l:fts = deepcopy(s:defaults.filetypes)
  call extend(l:fts, get(g:, 'neorepl_filetype_repls', {}))

  let l:repls = get(l:fts, a:ft, [])
  if (type(l:repls) == type('')) || (type(l:repls) == type({}))
    let l:repls = [l:repls]
  endif
  return l:repls
endfunction
