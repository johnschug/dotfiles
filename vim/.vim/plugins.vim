scriptencoding utf-8

autocmd vimrc BufWritePost plugins.vim nested source $MYVIMRC

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

" Fugitive {{{
  nnoremap <Leader>gs :Gstatus<CR>
  nnoremap <Leader>gb :leftabove Gblame<CR><C-W>p
  nnoremap <Leader>gl :silent! Gllog!<CR>
  nnoremap <Leader>gd :Gvdiff<CR>
  nnoremap <Leader>gw :Gwrite<CR>
" }}}

" " Neomake {{{
"   autocmd vimrc BufReadPost,BufWritePost * Neomake
"   autocmd vimrc User NeomakeCountsChanged call lightline#update()
"
"   let g:neomake_verbose = 0
"   let g:neomake_open_list = 2
"   let g:neomake_warning_sign = { 'text': '⚠' }
"   let g:neomake_error_sign = { 'text': '✖' }
" " }}}

" Ale {{{
  autocmd vimrc User ALELint call lightline#update()

  let g:ale_sign_warning = '⚠'
  let g:ale_sign_error = '✖'
  let g:ale_linters = { 'rust': ['rustc'] }

  nmap <silent> [e <Plug>(ale_previous_wrap)
  nmap <silent> ]e <Plug>(ale_next_wrap)

  function! StatusLineError()
    let l:counts = ale#statusline#Count(bufnr(''))
    let l:symbols = ['E:', 'W:']
    let l:counts = [l:counts.error + l:counts.style_error,
          \ l:counts.warning + l:counts.style_warning]
    return join(map(filter(range(2), 'l:counts[v:val] > 0'),
          \ 'l:symbols[v:val].l:counts[v:val]'))
  endfunction
" }}}

" completor {{{
  let g:completor_ocaml_omni_trigger = '(?:\w{2,}|\.\w*|\#\w*)$'
  let g:completor_haskell_trigger = '(?:\w{2,}|\.\w*)$'
" }}}

" delimitMate {{{
  let g:delimitMate_expand_space = 1
  let g:delimitMate_expand_cr = 2
  let g:delimitMate_jump_expansion = 1
" }}}

" UltiSnips {{{
  let g:UltiSnipsExpandTrigger = '<c-j>'
  let g:UltiSnipsJumpForwardTrigger = '<c-j>'
  let g:UltiSnipsJumpBackwardTrigger = '<c-k>'
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

" EnchancedDiff {{{
  let &diffexpr='EnhancedDiff#Diff("git diff", "--diff-algorithm=patience")'
" }}}

" Unicode.vim {{{
  nmap ga <Plug>(UnicodeGA)
" }}}

" Skim / FZF {{{
  if executable('rg')
    let $SKIM_DEFAULT_COMMAND='rg --files'
  elseif executable('ag')
    let $SKIM_DEFAULT_COMMAND='ag -l -g ""'
  endif
  let $FZF_DEFAULT_COMMAND=$SKIM_DEFAULT_COMMAND

  if exists(':Buffers')
    nnoremap <silent> <C-J> :Buffers<CR>
  endif
  if exists(':Files')
    nnoremap <silent> <C-P> :Files<CR>
  endif
" }}}

" vim:set sw=2 ts=2 et fdm=marker fdl=0:
