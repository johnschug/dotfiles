if has('vim_starting') && &encoding !=# 'utf-8'
   set encoding=utf-8
endif
scriptencoding utf-8

augroup vimrc
  autocmd!
augroup END

" Plugins {{{
  runtime! macros/matchit.vim

  " lightline {{{
    let g:lightline = {
          \ 'colorscheme': 'solarized',
          \ 'active': {
          \   'left': [['mode', 'paste'],
          \             ['fugitive', 'hunks'],
          \             ['readonly', 'filename']],
          \   'right': [['neomake', 'lineinfo'],
          \              ['percent'],
          \              ['filetype', 'fileencoding', 'fileformat']],
          \ },
          \ 'component': {
          \   'fugitive': '%{exists("*fugitive#head")?fugitive#head(7):""}',
          \   'filename': '%f%( %M%)',
          \   'fileformat': '%{winwidth(0)>=80?&ff:""}',
          \   'fileencoding': '%{winwidth(0)>=80?(!empty(&fenc)?&fenc:&enc):""}',
          \ },
          \ 'component_expand': {
          \   'neomake': 'neomake#statusline#LoclistStatus',
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
  " }}}

  " Neomake {{{
    autocmd vimrc BufWritePost * Neomake
    autocmd vimrc User NeomakeCountsChanged call lightline#update()

    let g:neomake_verbose = 0
    let g:neomake_open_list = 2
    let g:neomake_warning_sign = { 'text': '>>' }
    let g:neomake_error_sign = { 'text': '>>' }
  " }}}

  " YouCompleteMe {{{
    let g:ycm_add_preview_to_completeopt = 1
    if filereadable(expand('~/.ycm_extra_conf.py'))
      let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
    endif
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

  call plug#begin('~/.vim/plugins')
  Plug 'Valloric/ListToggle'
  Plug 'Raimondi/delimitMate'
  Plug 'tomtom/tcomment_vim'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-fugitive'
  Plug 'tommcdo/vim-lion'
  Plug 'SirVer/ultisnips'
  Plug 'honza/vim-snippets'
  Plug 'chrisbra/unicode.vim'
  Plug 'neomake/neomake'
  Plug 'mhinz/vim-signify'
  Plug 'itchyny/lightline.vim'
  Plug 'editorconfig/editorconfig-vim'
  Plug 'cespare/vim-toml'
  Plug 'vim-pandoc/vim-pandoc'
  Plug 'vim-pandoc/vim-pandoc-syntax', { 'for': 'pandoc' }
  Plug 'chrisbra/vim-diff-enhanced'
  Plug 'rust-lang/rust.vim'
  Plug 'Valloric/YouCompleteMe', { 'do': './install.py --racer-completer' }
  call plug#end()
" }}}

" General {{{
  if !exists('g:vim_root')
    let g:vimroot = split(&runtimepath, ',')[0]
  endif

  set autoread
  set hidden
  set path+=**
  set fileformats=unix,dos,mac
  set shortmess+=a
  set viminfo=

  let &backupdir = g:vimroot.'/backup//,~/tmp//,.'
" }}}

" Interface {{{
  set ttyfast
  set lazyredraw
  set scrolloff=5
  set list
  set listchars=tab:▸\ ,eol:¬,trail:•
  set number
  set relativenumber
  set cursorline
  set cursorcolumn
  set colorcolumn=+1
  set showcmd
  set noshowmode
  set laststatus=2
  set display+=lastline

  set splitbelow splitright

  set nofoldenable
  set foldmethod=syntax
  set foldcolumn=1
  set foldminlines=5
  set foldopen+=insert
  set fillchars=diff:⎼,fold:⎼

  set hlsearch
  set incsearch
  set ignorecase
  set smartcase

  set wildmenu
  set wildignorecase
  set wildignore+=*.swp,*.bak,*~
  set wildignore+=*.pyc,*.rlib,*.class,*.o,*.obj,*.a,*.lib,*.so,*.dll,*.pdb
  set wildignore+=*/.git/**/*,*/.hg/**/*,*/.svn/**/*
  set wildignore+=tags,cscope.*

  " if (has('termguicolors'))
  "   set t_8f=[38;2;%lu;%lu;%lum
  "   set t_8b=[48;2;%lu;%lu;%lum
  "   set termguicolors
  " endif

  set background=dark
  colorscheme solarized

  autocmd vimrc InsertEnter * set norelativenumber
  autocmd vimrc InsertLeave * set relativenumber
  autocmd vimrc WinEnter * if exists('w:cursor') |
        \ let [&cursorline, &cursorcolumn] = w:cursor |
        \ endif
  autocmd vimrc WinLeave * let w:cursor = [&cursorline, &cursorcolumn] |
        \ setlocal nocursorline nocursorcolumn
  autocmd vimrc FileType qf,netrw nested setlocal cursorline nocursorcolumn
" }}}

" Editing {{{
  set nowrap
  set expandtab
  set smarttab
  set shiftwidth=2
  set softtabstop=2
  set tabstop=2

  set matchpairs+=<:>,[:]
  set formatoptions+=j1
  set backspace=indent,eol,start
  set virtualedit=block
  set autoindent
  set copyindent
  set complete+=kspell
  set completeopt+=menuone
  set spelllang=en_us
  set diffopt+=iwhite
  let &diffexpr='EnhancedDiff#Diff("git diff", "--diff-algorithm=patience")'

  set ttimeout
  set ttimeoutlen=100
" }}}

" Commands {{{
  command! -range Copy <line1>,<line2>!xclip -f -sel clip
  command! Paste read !xclip -o -sel clip
  command! DiffOrig call s:DiffOrig()
  function! s:DiffOrig()
    let l:ft = &filetype
    diffthis
    vnew | r ++edit # | 0d_
    diffthis
    execute 'setlocal bt=nofile bh=wipe nobl noswf ro noma ft='.l:ft
  endfunction

  autocmd vimrc QuickFixCmdPost [^l]* nested botright cwindow|redraw!
  autocmd vimrc QuickFixCmdPost    l* nested lwindow|redraw!

  if executable('ag')
    set grepprg=ag\ --nogroup\ --nocolor\ --column\ --vimgrep
    set grepformat=%f:%l:%c:%m,%f:%l:%m
  else
    set grepprg=grep\ -rnH
  endif
" }}}

" Mappings {{{
  " Navigation {{{
    nnoremap gb <C-^>
    nnoremap gB :ls<CR>:b<Space>
    nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
    nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
    for s:cmd in [['a', ''], ['b', 'b'], ['t', 't'], ['q', 'c'], ['l', 'l']]
      execute 'nnoremap <silent> <expr> ['.s:cmd[0]." ':<C-U>'.v:count1.'".s:cmd[1]."prev<CR>'"
      execute 'nnoremap <silent> <expr> ]'.s:cmd[0]." ':<C-U>'.v:count1.'".s:cmd[1]."next<CR>'"
      execute 'nnoremap <silent> ['.toupper(s:cmd[0]).' :<C-U>'.s:cmd[1].'first<CR>'
      execute 'nnoremap <silent> ]'.toupper(s:cmd[0]).' :<C-U>'.s:cmd[1].'last<CR>'
    endfor
  " }}}
  nnoremap <silent> [<Space> :<C-U>put! =repeat(nr2char(10), v:count1)<CR>']+1
  nnoremap <silent> ]<Space> :<C-U>put =repeat(nr2char(10), v:count1)<CR>'[-1
  nnoremap <expr> gp '`['.strpart(getregtype(), 0, 1).'`]'
  nnoremap <silent> gs :silent! grep! "\b<C-R><C-W>\b"<CR>
  nmap ga <Plug>(UnicodeGA)
  nnoremap <silent> <C-L> :nohlsearch<CR><C-L>
  nnoremap <silent> <F5> :YcmForceCompileAndDiagnostics<CR>
  nnoremap <silent> <Leader>d :bd<CR>
  nnoremap <silent> <Leader>n :set relativenumber!<CR>
  nnoremap <silent> <Leader>o :set paste!<CR>
  nnoremap <silent> <Leader>m :setlocal expandtab shiftwidth=2 softtabstop=2 tabstop=2<CR>
  nnoremap <silent> <Leader>M :setlocal expandtab shiftwidth=4 softtabstop=4 tabstop=4<CR>
  nnoremap <silent> <Leader>j :setlocal noexpandtab shiftwidth=4 softtabstop=4 tabstop=4<CR>
  nnoremap <silent> <Leader>J :setlocal noexpandtab shiftwidth=8 softtabstop=8 tabstop=8<CR>
  nnoremap <silent> <Leader>g :YcmCompleter GoTo<CR>
  nnoremap <silent> <Leader>s :set spell!<CR>
  nnoremap <Leader>gs :Gstatus<CR>
  nnoremap <Leader>gb :leftabove Gblame<CR><C-W>p
  nnoremap <Leader>gl :silent! Gllog!<CR>
  nnoremap <Leader>gd :Gvdiff<CR>
  nnoremap <Leader>gw :Gwrite<CR>

  xnoremap ae :<C-U>normal! ggVG<CR>
  onoremap ae :<C-U>keepjumps normal! ggVG<CR>

  cabbrev %% <C-R>=fnameescape(expand('%'))<CR>
  cabbrev :: <C-R>=fnameescape(expand('%:h'))<CR>
" }}}

" File Type {{{
  autocmd vimrc FileType vim setlocal keywordprg=:help
  autocmd vimrc FileType gitcommit,text,markdown,pandoc,c,cpp,rust setlocal spell
" }}}

" Projects {{{
  set tags=./tags;,tags

  let s:gitroot = substitute(system('git rev-parse --show-toplevel'), '[\n\r]', '', 'g')
  if v:shell_error == 0 && !empty(s:gitroot)
    let &path .= ','.s:gitroot.'/**'
    let &tags .= ','.s:gitroot.'/.git/tags'
  endif

  autocmd vimrc FileType * let &l:tags = &tags.','.expand(g:vimroot.'/tags/').&ft
" }}}

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
elseif filereadable(expand('~/_vimrc.local'))
  source ~/_vimrc.local
endif

" vim:set sw=2 ts=2 et fdm=marker fdl=0:
