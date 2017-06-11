scriptencoding utf-8

" Options {{{
  " lightline {{{
    let g:lightline = {
          \ 'colorscheme': 'breeze',
          \ 'active': {
          \   'left': [['mode', 'paste'],
          \             ['fugitive', 'hunks'],
          \             ['readonly', 'filename']],
          \   'right': [['neomake', 'lineinfo'],
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
          \   'neomake': 'LightlineError',
          \ },
          \ 'component_function': {
          \   'hunks': 'LightlineHunks',
          \ },
          \ 'component_visible_condition': {
          \   'fugitive': '(exists("*fugitive#head") && !empty(fugitive#head(7)))',
          \   'fileformat': '(winwidth(0) >= 80)',
          \   'fileencoding': '(winwidth(0) >= 80)',
          \ },
          \ 'component_type': { 'neomake': 'error' },
          \ }

    function! LightlineHunks()
      if (winwidth(0) < 100) || !exists('*sy#repo#get_stats')
        return ''
      endif

      let l:symbols = ['+', '-', '~']
      let l:stats = copy(sy#repo#get_stats())
      let l:stats[1:2] = reverse(l:stats[1:2])
      return join(map(filter(range(len(l:stats)), 'l:stats[v:val] > 0'),
             \ 'l:symbols[v:val].l:stats[v:val]'))
    endfunction

    function! LightlineError()
      let l:local = neomake#statusline#LoclistStatus()
      return !empty(l:local) ? l:local : neomake#statusline#QflistStatus()
    endfunction
  " }}}

  " Neomake {{{
    autocmd vimrc BufReadPost,BufWritePost * Neomake
    autocmd vimrc User NeomakeCountsChanged call lightline#update()

    let g:neomake_verbose = 0
    let g:neomake_open_list = 2
    let g:neomake_warning_sign = { 'text': '⚠' }
    let g:neomake_error_sign = { 'text': '✖' }
  " }}}

  " YouCompleteMe {{{
    let g:ycm_add_preview_to_completeopt = 1
    if filereadable(expand('~/.ycm_extra_conf.py'))
      let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
    endif
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
  " }}}

  " vim-plug {{{
    let g:plug_window = 'vertical belowright new'
  " }}}
" }}}

call plug#begin(g:vimdata.'/plugged')
Plug 'Valloric/ListToggle'
Plug 'Raimondi/delimitMate'
Plug 'tomtom/tcomment_vim'
Plug 'tommcdo/vim-lion'
Plug 'wellle/targets.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'chrisbra/unicode.vim', { 'on': ['<Plug>(UnicodeGA)', 'UnicodeTable'] }
Plug 'neomake/neomake'
Plug 'sbdchd/neoformat'
Plug 'mhinz/vim-signify'
Plug 'itchyny/lightline.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'cespare/vim-toml'
Plug 'itchyny/vim-haskell-indent'
Plug 'vim-pandoc/vim-pandoc' | Plug 'vim-pandoc/vim-pandoc-syntax', { 'for': 'pandoc' }
Plug 'hashivim/vim-vagrant'
Plug 'chrisbra/vim-diff-enhanced'
Plug 'rust-lang/rust.vim'
Plug 'maralla/completor.vim'
" Plug 'Valloric/YouCompleteMe', { 'do': './install.py --racer-completer' }

if exists('*local#plugins')
  call local#plugins()
endif
call plug#end()

" Settings {{{
  let &diffexpr='EnhancedDiff#Diff("git diff", "--diff-algorithm=patience")'

  if executable('rg')
    let $SKIM_DEFAULT_COMMAND='rg --files'
  elseif executable('ag')
    let $SKIM_DEFAULT_COMMAND='ag -l -g ""'
  endif
  let $FZF_DEFAULT_COMMAND=$SKIM_DEFAULT_COMMAND

  if executable('hindent')
    autocmd vimrc FileType haskell setlocal equalprg=hindent
  endif
" }}}

" Mappings {{{
  if executable('sk') || executable('fzf')
    nnoremap <silent> <C-J> :Buffers<CR>
    nnoremap <silent> <C-P> :Files<CR>
  endif
  nmap ga <Plug>(UnicodeGA)
  nnoremap <silent> <Leader>g :YcmCompleter GoTo<CR>
  nnoremap <Leader>gs :Gstatus<CR>
  nnoremap <Leader>gb :leftabove Gblame<CR><C-W>p
  nnoremap <Leader>gl :silent! Gllog!<CR>
  nnoremap <Leader>gd :Gvdiff<CR>
  nnoremap <Leader>gw :Gwrite<CR>
" }}}
" vim:set sw=2 ts=2 et fdm=marker fdl=0:
