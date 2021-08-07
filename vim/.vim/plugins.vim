scriptencoding utf-8

let g:diagnostic_functions = {}
function! StatusLineError() abort
  let l:symbols = ['E:', 'W:']
  let l:counts = [0, 0]
  for F in values(g:diagnostic_functions)
    let l:diags = F()
    let l:counts[0] += l:diags.error
    let l:counts[1] += l:diags.warning
  endfor
  return join(map(filter(range(2), 'l:counts[v:val] > 0'),
        \ 'l:symbols[v:val].l:counts[v:val]'))
endfunction

" asyncomplete {{{
  let g:asyncomplete_smart_completion = 1
  let g:asyncomplete_remove_duplicates = 1

  imap <silent> <C-Space> <Plug>(asyncomplete_force_refresh)
  imap <silent> <expr> <CR> pumvisible() ? "\<C-y>\<CR>" : "\<C-g>u<Plug>delimitMateCR"

  function! s:register_async_sources() abort
    call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
          \ 'name': 'file',
          \ 'allowlist': ['*'],
          \ 'priority': 10,
          \ 'completor': function('asyncomplete#sources#file#completor')
          \ }))
    call asyncomplete#register_source(asyncomplete#sources#omni#get_source_options({
          \ 'name': 'omni',
          \ 'allowlist': ['*'],
          \ 'blocklist': ['html'],
          \ 'completor': function('asyncomplete#sources#omni#completor')
          \  }))
  endfunction

  autocmd vimrc User asyncomplete_setup call s:register_async_sources()
" }}}

" delimitMate {{{
  let g:delimitMate_expand_space = 1
  let g:delimitMate_expand_cr = 2
  let g:delimitMate_jump_expansion = 1
" }}}

" editorconfig {{{
  let g:EditorConfig_disable_rules = ['trim_trailing_whitespace']
" }}}

" Fugitive {{{
  nnoremap <Leader>gs :Gstatus<CR>
  nnoremap <Leader>gb :leftabove Gblame<CR><C-W>p
  nnoremap <Leader>gl :silent! Gllog!<CR>
  nnoremap <Leader>gd :Gvdiff<CR>
  nnoremap <Leader>gw :Gwrite<CR>
" }}}

" lightline {{{
  let g:lightline = {
        \ 'colorscheme': 'breeze',
        \ 'active': {
        \   'left': [['mode', 'paste'],
        \             ['fugitive', 'hunks'],
        \             ['readonly', 'filename', 'lsp_progress']],
        \   'right': [['errors', 'lineinfo'],
        \              ['percent'],
        \              ['filetype', 'fileencoding', 'fileformat'],
        \              ['spell']],
        \ },
        \ 'component': {
        \   'fugitive': '%{exists("*fugitive#head")?fugitive#head(7):""}',
        \   'filename': '%f%( %M%)',
        \   'fileformat': '%{winwidth(0)>=80?&ff:""}',
        \   'fileencoding': '%{winwidth(0)>=80?(!empty(&fenc)?&fenc:&enc):""}',
        \ },
        \ 'component_expand': {
        \   'errors': 'StatusLineError',
        \ },
        \ 'component_function': {
        \   'hunks': 'StatusLineHunks',
        \   'lsp_progress': 'StatusLineLspProgress',
        \ },
        \ 'component_visible_condition': {
        \   'fugitive': '(exists("*fugitive#head") && !empty(fugitive#head(7)))',
        \   'fileformat': '(winwidth(0) >= 80)',
        \   'fileencoding': '(winwidth(0) >= 80)',
        \ },
        \ 'component_type': { 'errors': 'error' },
        \ }
" }}}

" rustfmt.vim {{{
  if executable('rustup')
    let g:rustfmt_command = 'rustfmt +nightly'
  endif
" }}}

" signify {{{
  autocmd vimrc User Signify call lightline#update()

  let g:signify_vcs_list = ['git']

  function! StatusLineHunks()
    if (winwidth(0) < 100) || !exists('*sy#repo#get_stats')
      return ''
    endif

    let l:symbols = ['+', '-', '~']
    let l:stats = copy(sy#repo#get_stats())
    let l:stats[1:2] = reverse(l:stats[1:2])
    return join(map(filter(range(len(l:stats)), 'l:stats[v:val] > 0'),
           \ 'l:symbols[v:val].l:stats[v:val]'))
  endfunction
" }}}

" Unicode.vim {{{
  nmap ga <Plug>(UnicodeGA)
" }}}

" vim-lsp {{{
  let g:diagnostic_functions['lsp'] = function('lsp#get_buffer_diagnostics_counts')

  let g:lsp_diagnostics_float_cursor = 1
  let g:lsp_work_done_progress_enabled = 1

  function! s:register_lsp_servers() abort
    if executable('ocamllsp')
      call lsp#register_server({
            \ 'name': 'ocaml-lsp',
            \ 'cmd': {server_info->['ocamllsp']},
            \ 'allowlist': ['ocaml'],
            \})
    endif
  endfunction
  function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal keywordprg=:LspHover
    if exists('+tagfunc')
      setlocal tagfunc=lsp#tagfunc
    endif
    nmap <silent> <buffer> gd <plug>(lsp-definition)
    nmap <silent> <buffer> gD <plug>(lsp-declaration)
    nmap <silent> <buffer> gs <plug>(lsp-workspace-symbol-search)
    nmap <silent> <buffer> gr <plug>(lsp-references)
    nmap <silent> <buffer> gi <plug>(lsp-implementation)
    nmap <silent> <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <silent> <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <silent> <buffer> gy <plug>(lsp-code-action)
  endfunction
  function! StatusLineLspProgress() abort
    if !exists('*lsp#get_progress')
      return ''
    endif
    let l:progress = lsp#get_progress()
    if empty(l:progress)
      return ''
    endif

    let l:progress = l:progress[len(l:progress) - 1]
    let l:percent = get(l:progress, 'percentage', '')
    if index([v:t_number, v:t_float], type(l:percent)) >= 0
      let l:percent = ' '.string(abs(round(l:percent*10))/10).'%'
    else
      let l:percent = ''
    endif
    return l:progress['server'].': '.l:progress['title'].' '.l:progress['message'].l:percent
  endfunction
  autocmd vimrc User lsp_setup call s:register_lsp_servers()
  autocmd vimrc User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
  autocmd vimrc User lsp_diagnostics_updated call lightline#update()
  autocmd vimrc User lsp_progress_updated call lightline#update()
" }}}

" vim-lsp-settings {{{
  let g:lsp_settings = { 'efm-langserver': { 'disabled': 1 } }
" }}}

" vim-vsnip {{{
  let g:vsnip_snippet_dir = g:vimconf . '/vsnip'
  imap <expr> <C-j> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-j>'
  smap <expr> <C-j> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-j>'
  imap <expr> <C-k> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'
  smap <expr> <C-k> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'
" }}}

" vim:set sw=2 ts=2 et fdm=marker:
