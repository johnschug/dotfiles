if has('vim_starting') && &encoding !=# 'utf-8'
   set encoding=utf-8
endif
scriptencoding utf-8

" Early Setup {{{
augroup vimrc
  autocmd!
augroup END

if has('gui_running')
  set guioptions-=m
  set guioptions+=M
endif

if !exists('g:vim_root')
  let g:vimroot = split(&runtimepath, ',')[0]
endif

runtime local.vim

if exists('*local#init')
  call local#init()
endif
" }}}

" Plugins {{{
  runtime! macros/matchit.vim

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

  if $XDG_DATA_HOME == 0
    let s:plugin_dir = expand('~/.local/share/vim/plugged')
  else
    let s:plugin_dir = $XDG_DATA_HOME.'/vim/plugged'
  endif
  call plug#begin(s:plugin_dir)
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
  Plug 'vim-pandoc/vim-pandoc' | Plug 'vim-pandoc/vim-pandoc-syntax', { 'for': 'pandoc' }
  Plug 'hashivim/vim-vagrant'
  Plug 'chrisbra/vim-diff-enhanced'
  Plug 'rust-lang/rust.vim'
  Plug 'Valloric/YouCompleteMe', { 'do': './install.py --racer-completer' }

  if exists('*local#plugins')
    call local#plugins()
  endif
  call plug#end()
" }}}

" General {{{
  set autoread
  set hidden
  set path+=**
  set fileformats=unix,dos,mac
  set shortmess+=a
  set viminfo=

  set backupdir-=.
  set backupdir-=~/
  set backupdir+=.

  if exists('+undofile')
    set undofile

    autocmd vimrc BufWritePre /tmp/* setlocal noundofile
  endif

  autocmd vimrc BufWritePost _vimrc,.vimrc nested source $MYVIMRC
" }}}

" Interface {{{
  set ttyfast
  set lazyredraw
  set scrolloff=5
  set list
  set listchars=tab:▸\ ,nbsp:␣,trail:•,eol:¬
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
  set wildignore+=*.swp,*.bak,.DS_Store,._*,*~
  set wildignore+=*.pyc,*.rlib,*.class,*.o,*.obj,*.a,*.lib,*.so,*.dll,*.pdb
  set wildignore+=*/.git/**/*,*/.hg/**/*,*/.svn/**/*
  set wildignore+=tags,cscope.*

  if has('gui_running')
    if has('gui_win32')
      if exists('&renderoptions')
        set renderoptions=type:directx,geom:1,renmode:5,taamode:1
      endif
      set guifont^=Source_Code_Pro:h10,Noto_Mono:h10,DejaVu_Sans_Mono:h10,Courier_New:h10
    else
      set guifont^=Source\ Code\ Pro\ 10,Noto\ Mono\ 10,DejaVu\ Sans\ Mono\ 10
    endif
    set guioptions-=r
    set guioptions-=R
    set guioptions-=l
    set guioptions-=L
    set guioptions-=T
  endif

  let g:breeze_use_palette = !$NOPALETTE
  colorscheme breeze

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

  set nostartofline
  set matchpairs+=<:>,[:]
  set formatoptions+=qjl1
  set backspace=indent,eol,start
  set virtualedit=block
  set autoindent
  set copyindent
  set preserveindent
  set complete+=kspell
  set completeopt+=menuone
  set spelllang=en_us
  set dictionary^=spell
  if filereadable('/usr/share/dict/words')
    set dictionary+=/usr/share/dict/words
  endif
  set diffopt+=iwhite
  let &diffexpr='EnhancedDiff#Diff("git diff", "--diff-algorithm=patience")'

  if exists('&inccommand')
    set inccommand=nosplit
  endif

  set ttimeout
  set ttimeoutlen=100
" }}}

" Commands {{{
  command! -range Copy <line1>,<line2>write !xclip -f -sel clip
  command! Paste read !xclip -o -sel clip
  command! DiffOrig call s:DiffOrig()
  function! s:DiffOrig() abort
    let l:ft = &filetype
    diffthis
    vnew | r ++edit # | 0d_
    diffthis
    execute 'setlocal bt=nofile bh=wipe nobl noswf ro noma ft='.l:ft
  endfunction
  command! -nargs=1 EditConfig call s:EditConfig(<args>)
  function! s:EditConfig(what) abort
    let l:ft = &filetype
    if a:what ==# 'vimrc'
      let l:file = expand($MYVIMRC)
    elseif a:what ==# 'local'
      let l:file = g:vimroot.'/local.vim'
    elseif a:what ==# 'colors'
      let l:colors = get(g:, 'colors_name', '')
      if empty(l:colors)
        return
      endif
      let l:file = g:vimroot.'/colors/'.l:colors.'.vim'
    elseif !isdirectory(globpath(g:vimroot, a:what)) || empty(l:ft)
      return
    else
      let l:file = g:vimroot.'/'.a:what.'/'.l:ft.'.vim'
    endif
    execute ':vsplit '.l:file
    execute ':lcd %:p:h'
  endfunction

  autocmd vimrc QuickFixCmdPost [^l]* nested botright cwindow|redraw!
  autocmd vimrc QuickFixCmdPost    l* nested lwindow|redraw!

  if executable('rg')
    set grepprg=rg\ --vimgrep\ --no-heading\ -S
    set grepformat^=%f:%l:%c:%m
  elseif executable('ag')
    set grepprg=ag\ --vimgrep
    set grepformat^=%f:%l:%c:%m
  else
    set grepprg=grep\ -rnH
  endif
" }}}

" Mappings {{{
  " Navigation {{{
    nnoremap gb <C-^>
    nnoremap <silent> <expr> gB (exists(':Buffers') == 2)?':Buffers<CR>':':ls<CR>:b<SPACE>'
    nnoremap <silent> <C-P> :Files<CR>

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
  nnoremap <expr> g. '`['.strpart(getregtype(), 0, 1).'`]'
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
  nnoremap <silent> <Leader>ss :set spell!<CR>
  nnoremap <silent> <Leader>sv :source $MYVIMRC<CR>
  nnoremap <silent> <Leader>ev :EditConfig('vimrc')<CR>
  nnoremap <silent> <Leader>el :EditConfig('local')<CR>
  nnoremap <silent> <Leader>ef :EditConfig('ftplugin')<CR>
  nnoremap <silent> <Leader>es :EditConfig('syntax')<CR>
  nnoremap <silent> <Leader>ec :EditConfig('colors')<CR>
  nnoremap <Leader>gs :Gstatus<CR>
  nnoremap <Leader>gb :leftabove Gblame<CR><C-W>p
  nnoremap <Leader>gl :silent! Gllog!<CR>
  nnoremap <Leader>gd :Gvdiff<CR>
  nnoremap <Leader>gw :Gwrite<CR>

  inoremap <C-W> <C-G>u<C-W>
  inoremap <C-U> <C-G>u<C-U>

  xnoremap ae :<C-U>normal! ggVG<CR>
  onoremap ae :<C-U>keepjumps normal! ggVG<CR>

  cabbrev %% <C-R>=fnameescape(expand('%'))<CR>
  cabbrev :: <C-R>=fnameescape(expand('%:h'))<CR>
" }}}

" File Type {{{
  autocmd vimrc FileType vim setlocal keywordprg=:help
  autocmd vimrc FileType gitcommit,text,markdown,pandoc,html,c,cpp,rust setlocal spell
" }}}

" Projects {{{
  set tags=./tags;,tags

  let s:gitroot = get(systemlist('git rev-parse --show-toplevel'), 0, '')
  if v:shell_error == 0 && !empty(s:gitroot)
    let &path .= ','.s:gitroot.'/**'
    let &tags .= ','.s:gitroot.'/.git/tags'
  endif

  autocmd vimrc FileType * let &l:tags = &tags.','.expand(g:vimroot.'/tags/').&ft
" }}}

if exists('*local#finish')
  call local#finish()
endif
" vim:set sw=2 ts=2 et fdm=marker fdl=0:
