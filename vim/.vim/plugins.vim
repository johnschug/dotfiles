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

" Ale {{{
  autocmd vimrc User ALELint call lightline#update()

  let g:ale_virtualtext_cursor = 1
  let g:ale_sign_warning = 'W>'
  let g:ale_sign_error = 'E>'
  let g:ale_linters = {
        \ 'markdown': ['proselint', 'vale'],
        \ 'text': ['proselint', 'vale'],
        \ }

  nmap <silent> [e <Plug>(ale_previous_wrap)
  nmap <silent> ]e <Plug>(ale_next_wrap)

  let g:diagnostic_functions['ale'] = {-> ale#statusline#Count(bufnr('')) }
" }}}

" asyncomplete {{{
  let g:asyncomplete_smart_completion = 1
  let g:asyncomplete_remove_duplicates = 1

  imap <C-Space> <Plug>(asyncomplete_force_refresh)
  inoremap <expr> <CR> pumvisible() ? "\<C-y>\<CR>" : "\<CR>"

  function! s:RegisterAsyncSources() abort
    call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
          \ 'name': 'file',
          \ 'whitelist': ['*'],
          \ 'priority': 10,
          \ 'completor': function('asyncomplete#sources#file#completor')
          \ }))
    call asyncomplete#register_source(asyncomplete#sources#omni#get_source_options({
          \ 'name': 'omni',
          \ 'whitelist': ['*'],
          \ 'blacklist': ['html'],
          \ 'completor': function('asyncomplete#sources#omni#completor')
          \  }))
  endfunction

  autocmd vimrc User asyncomplete_setup call s:RegisterAsyncSources()
  autocmd vimrc CompleteDone * if pumvisible() == 0 | pclose | endif
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
        \             ['readonly', 'filename']],
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
    let g:rustfmt_options = '+nightly'
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
  if has('nvim')
    let g:lsp_diagnostics_float_cursor = 1
  endif

  let g:diagnostic_functions['lsp'] = function('lsp#get_buffer_diagnostics_counts')

  function! s:RegisterLspServers() abort
    if executable('rust-analyzer')
      call lsp#register_server({
            \ 'name': 'rust-analyzer',
            \ 'cmd': {server_info->['rust-analyzer']},
            \ 'whitelist': ['rust'],
            \})
    elseif executable('rls')
      call lsp#register_server({
            \ 'name': 'rls',
            \ 'cmd': {server_info->['rustup', 'run', 'nightly', 'rls']},
            \ 'whitelist': ['rust'],
            \})
    endif
    if executable('clangd')
      call lsp#register_server({
            \ 'name': 'clangd',
            \ 'cmd': {server_info->['clangd']},
            \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
            \})
    endif
  endfunction
  function! s:EnableLspForBuffer() abort
    setlocal keywordprg=:LspHover
    nmap <buffer> gd <plug>(lsp-definition)
  endfunction
  autocmd vimrc User lsp_setup call s:RegisterLspServers()
  autocmd vimrc User lsp_buffer_enabled call s:EnableLspForBuffer()
  autocmd vimrc User lsp_diagnostics_updated call lightline#update()
" }}}

" vim-vsnip {{{
  imap <expr> <C-j> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-j>'
  smap <expr> <C-j> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-j>'
  imap <expr> <C-k> vsnip#available(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'
  smap <expr> <C-k> vsnip#available(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'
" }}}

" vim:set sw=2 ts=2 et fdm=marker:
