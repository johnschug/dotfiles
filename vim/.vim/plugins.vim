scriptencoding utf-8

autocmd vimrc BufWritePost plugins.vim nested source $MYVIMRC

" Ale {{{
  autocmd vimrc User ALELint call lightline#update()

  let g:ale_sign_warning = '⚠'
  let g:ale_sign_error = '✖'
  let g:ale_linters = {
        \ 'rust': ['rustc'],
        \ 'markdown': ['proselint', 'vale'],
        \ 'text': ['proselint', 'vale'],
        \ }

  nmap <silent> [e <Plug>(ale_previous_wrap)
  nmap <silent> ]e <Plug>(ale_next_wrap)

  function! StatusLineError() abort
    let l:counts = ale#statusline#Count(bufnr(''))
    let l:symbols = ['E:', 'W:']
    let l:counts = [l:counts.error + l:counts.style_error,
          \ l:counts.warning + l:counts.style_warning]
    return join(map(filter(range(2), 'l:counts[v:val] > 0'),
          \ 'l:symbols[v:val].l:counts[v:val]'))
  endfunction
" }}}

" asyncomplete {{{
  let g:asyncomplete_remove_duplicates = 1

  imap <c-space> <Plug>(asyncomplete_force_refresh)

  function! s:RegisterAsyncSources() abort
    call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
          \ 'name': 'file',
          \ 'whitelist': ['*'],
          \ 'priority': 10,
          \ 'completor': function('asyncomplete#sources#file#completor')
          \ }))
    call asyncomplete#register_source(asyncomplete#sources#ultisnips#get_source_options({
          \ 'name': 'ultisnips',
          \ 'whitelist': ['*'],
          \ 'priority': 5,
          \ 'completor': function('asyncomplete#sources#ultisnips#completor'),
          \ }))
    call asyncomplete#register_source(asyncomplete#sources#omni#get_source_options({
          \ 'name': 'omni',
          \ 'whitelist': ['*'],
          \ 'blacklist': ['html'],
          \ 'completor': function('asyncomplete#sources#omni#completor')
          \  }))
  endfunction

  autocmd vimrc User asyncomplete_setup call s:RegisterAsyncSources()
" }}}

" delimitMate {{{
  let g:delimitMate_expand_space = 1
  let g:delimitMate_expand_cr = 2
  let g:delimitMate_jump_expansion = 1
" }}}

" editorconfig {{{
  let g:EditorConfig_disable_rules = ['trim_trailing_whitespace']
" }}}

" EnhancedDiff {{{
  let &diffexpr='EnhancedDiff#Diff("git diff", "--diff-algorithm=patience")'
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

" Skim / FZF {{{
  if executable('rg')
    let $SKIM_DEFAULT_COMMAND='rg --files'
  elseif executable('ag')
    let $SKIM_DEFAULT_COMMAND='ag -l -g ""'
  endif
  let $FZF_DEFAULT_COMMAND=$SKIM_DEFAULT_COMMAND

  nnoremap <silent> <C-Space> :Buffers<CR>
  nnoremap <silent> <C-P> :Files<CR>
" }}}

" UltiSnips {{{
  let g:UltiSnipsExpandTrigger = '<c-j>'
  let g:UltiSnipsJumpForwardTrigger = '<c-j>'
  let g:UltiSnipsJumpBackwardTrigger = '<c-k>'
" }}}

" Unicode.vim {{{
  nmap ga <Plug>(UnicodeGA)
" }}}

" vim-lsp {{{
  let g:lsp_signs_enabled = 1

  if executable('rls')
    autocmd vimrc User lsp_setup call lsp#register_server({
          \ 'name': 'rls',
          \ 'cmd': {server_info->['rustup', 'run', 'nightly', 'rls']},
          \ 'whitelist': ['rust'],
          \})
  endif
" }}}
" vim:set sw=2 ts=2 et fdm=marker:
