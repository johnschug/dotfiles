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

if !empty($XDG_DATA_HOME)
  let g:vimdata = $XDG_DATA_HOME.'/vim'
elseif has('win32') || has('win64')
  let g:vimdata = !empty($LOCALAPPDATA) ? $LOCALAPPDATA.'/vim' : g:vimroot
else
  let g:vimdata = expand('~/.local/share/vim')
endif

runtime local.vim

if exists('*local#init')
  call local#init()
endif
" }}}

" Plugins {{{
  runtime! macros/matchit.vim
  runtime plugins.vim
" }}}

" General {{{
  filetype plugin indent on
  set autoread
  set hidden
  set path+=**
  set fileformats=unix,dos,mac
  set shortmess+=a
  set viminfo=

  if !isdirectory(g:vimdata.'/backup')
    call mkdir(g:vimdata.'/backup', 'p')
  endif
  let &backupdir=g:vimdata.'/backup'
  let &directory=g:vimdata.'/swap//'
  if exists('+undofile')
    let &undodir=g:vimdata.'/undo'
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
  set statusline=
  set statusline+=%{&paste?'[PASTE]\ ':''}%r%f%(\ %M%)%=
  set statusline+=%{&spell?&spelllang.'\ ':''}
  set statusline+=%{!empty(&ft)?&ft:'no\ ft'}
  set statusline+=\ \|\ %{strlen(&fenc)?&fenc:&enc}
  set statusline+=\ \|\ %{&ff}
  set statusline+=\ :\ %3p%%\ :%3l:%-3v
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

  if exists('&inccommand')
    set inccommand=nosplit
  endif

  set ttimeout
  set ttimeoutlen=100
" }}}

" Commands {{{
  if executable('xclip')
    command! -range Copy <line1>,<line2>write !xclip -f -sel clip
    command! Paste read !xclip -o -sel clip
  endif

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
    nnoremap gB :ls<CR>:b<SPACE>

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
  nnoremap <silent> <C-L> :nohlsearch<CR><C-L>
  nnoremap <silent> <Leader>d :bd<CR>
  nnoremap <silent> <Leader>n :set relativenumber!<CR>
  nnoremap <silent> <Leader>o :set paste!<CR>
  nnoremap <silent> <Leader>m :setlocal expandtab shiftwidth=2 softtabstop=2 tabstop=2<CR>
  nnoremap <silent> <Leader>M :setlocal expandtab shiftwidth=4 softtabstop=4 tabstop=4<CR>
  nnoremap <silent> <Leader>j :setlocal noexpandtab shiftwidth=4 softtabstop=4 tabstop=4<CR>
  nnoremap <silent> <Leader>J :setlocal noexpandtab shiftwidth=8 softtabstop=8 tabstop=8<CR>
  nnoremap <silent> <Leader>ss :set spell!<CR>
  nnoremap <silent> <Leader>sv :source $MYVIMRC<CR>
  nnoremap <silent> <Leader>ev :EditConfig('vimrc')<CR>
  nnoremap <silent> <Leader>el :EditConfig('local')<CR>
  nnoremap <silent> <Leader>ef :EditConfig('ftplugin')<CR>
  nnoremap <silent> <Leader>es :EditConfig('syntax')<CR>
  nnoremap <silent> <Leader>ec :EditConfig('colors')<CR>

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

  autocmd vimrc FileType * let &l:tags = &tags.','.expand(g:vimdata.'/tags/').&ft
" }}}

if exists('*local#finish')
  call local#finish()
endif
" vim:set sw=2 ts=2 et fdm=marker fdl=0:
