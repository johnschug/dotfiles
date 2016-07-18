scriptencoding utf-8

" Plugins {{{
  runtime! macros/matchit.vim

  " airline {{{
    let g:airline_left_sep = ''
    let g:airline_left_alt_sep = ''
    let g:airline_right_sep = ''
    let g:airline_right_alt_sep = ''
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#buffer_nr_show = 1
    let g:airline#extensions#tabline#fnamemod = ':t'
  " }}}

  " indentLine {{{
    let g:indentLine_first_char = '│'
    let g:indentLine_char = '│'
    let g:indentLine_color_term = 245
    let g:indentLine_showFirstIndentLevel = 1
  " }}}

  " tagbar {{{
    let g:tagbar_compact = 1
    let g:tagbar_autofocus = 1
    let g:tagbar_foldlevel = 1
    let g:tagbar_autoshowtag = 1
    let g:tagbar_sort = 1
  " }}}

  " syntastic {{{
    let g:syntastic_check_on_open = 1
    let g:syntastic_check_on_wq = 0
    let g:syntastic_aggregate_errors = 1
    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 0
    let g:syntastic_python_python_exec = 'python3'
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
    let g:UltiSnipsExpandTrigger = "<c-j>"
    let g:UltiSnipsJumpForwardTrigger = "<c-j>"
    let g:UltiSnipsJumpBackwardTrigger = "<c-k>"
  " }}}

  " Racer {{{
    let g:racer_cmd = expand('~/.vim/bundle/racer/target/release/racer')
  " }}}

  " vim-plug {{{
    let g:plug_window = 'vertical belowright new'
  " }}}

  call plug#begin('~/.vim/bundle')
  Plug 'Valloric/ListToggle'
  Plug 'Raimondi/delimitMate'
  Plug 'tomtom/tcomment_vim'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-fugitive'
  Plug 'tommcdo/vim-lion'
  Plug 'SirVer/ultisnips'
  Plug 'chrisbra/unicode.vim'
  Plug 'Yggdroot/indentLine'
  Plug 'scrooloose/syntastic'
  Plug 'majutsushi/tagbar'
  Plug 'mhinz/vim-signify'
  Plug 'tpope/vim-dispatch'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'editorconfig/editorconfig-vim'
  Plug 'cespare/vim-toml'
  Plug 'vim-pandoc/vim-pandoc'
  Plug 'vim-pandoc/vim-pandoc-syntax', { 'for': 'pandoc' }
  Plug 'rust-lang/rust.vim'
  Plug 'Valloric/YouCompleteMe', { 'do': './install.py --racer-completer' }
  call plug#end()
" }}}

" General {{{
  set autoread
  set hidden
  set backupdir=~/.vim/backup//,~/_vim/backup//,~/tmp//,.
  set path+=**
  set encoding=utf-8
  set fileformats=unix,dos,mac
  set shortmess+=a
  set viminfo=
" }}}

" Interface {{{
  set ttyfast
  set lazyredraw
  set scrolloff=5
  set list
  set listchars=tab:▸\ ,eol:¬
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
  set foldopen=hor,insert,mark,quickfix,search,tag,undo

  set hlsearch
  set incsearch
  set ignorecase
  set smartcase

  set wildmenu
  set wildmode=longest:full,full
  set wildignorecase
  set wildignore+=*.swp,*.bak,*~
  set wildignore+=*.pyc,*.rlib,*.class,*.o,*.obj,*.a,*.lib,*.so,*.dll,*.pdb
  set wildignore+=*/.git/**/*,*/.hg/**/*,*/.svn/**/*
  set wildignore+=tags,cscope.*

  set background=dark
  colorscheme solarized

  augroup Numbers
    autocmd!
    autocmd InsertEnter * :set norelativenumber
    autocmd InsertLeave * :set relativenumber
  augroup END
" }}}

" Editing {{{
  set nowrap
  set expandtab
  set smarttab
  set shiftwidth=2
  set softtabstop=2
  set tabstop=2

  set formatoptions+=j1
  set backspace=indent,eol,start
  set virtualedit=block
  set autoindent
  set copyindent
  set complete+=kspell
  set completeopt+=longest,menuone
  set spelllang=en_us

  set ttimeout
  set ttimeoutlen=100
" }}}

" Commands {{{
  command! -range Copy <line1>,<line2>!xclip -f -sel clip
  command! Paste :read !xclip -o -sel clip

  augroup QuickFix
    autocmd!
    autocmd QuickFixCmdPost [^l]* nested :botright cwindow|redraw!
    autocmd QuickFixCmdPost    l* nested :lwindow|redraw!
  augroup END

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
    for cmd in [['a', ''], ['b', 'b'], ['t', 't'], ['q', 'c'], ['l', 'l']]
      execute "nnoremap <silent> <expr> [".cmd[0]." ':<C-U>'.v:count1.'".cmd[1]."prev<CR>'"
      execute "nnoremap <silent> <expr> ]".cmd[0]." ':<C-U>'.v:count1.'".cmd[1]."next<CR>'"
      execute "nnoremap <silent> [".toupper(cmd[0])." :<C-U>".cmd[1]."first<CR>"
      execute "nnoremap <silent> ]".toupper(cmd[0])." :<C-U>".cmd[1]."last<CR>"
    endfor
  " }}}
  nnoremap <silent> [<Space> :<C-U>put! =repeat(nr2char(10), v:count1)<CR>']+1
  nnoremap <silent> ]<Space> :<C-U>put =repeat(nr2char(10), v:count1)<CR>'[-1
  nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'
  nnoremap <silent> gs :silent! grep! "\b<C-R><C-W>\b"<CR>
  nmap ga <Plug>(UnicodeGA)
  nnoremap <silent> <C-L> :nohlsearch<CR><C-L>
  nnoremap <silent> <F3> :TagbarToggle<CR>
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

" Tags {{{
  set tags=./tags;,tags

  let gitroot = substitute(system('git rev-parse --show-toplevel'), '[\n\r]', '', 'g')
  if gitroot != ''
    let &tags = &tags . ',' . gitroot . '/.git/tags'
  endif

  augroup Tags
    autocmd!
    autocmd FileType * :let &l:tags = &tags . ',' . expand('~/.vim/tags/') . &ft
  augroup END
" }}}

" File Types {{{
  augroup RcFileTypes
    autocmd!
    autocmd FileType vim setlocal keywordprg=:help
    autocmd FileType gitcommit,text,markdown,pandoc,c,cpp,rust setlocal spell
  augroup END
" }}}

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
elseif filereadable(expand('~/_vimrc.local'))
  source ~/_vimrc.local
endif

" vim:foldmethod=marker:foldlevel=0:sw=2:sts=2:ts=2:expandtab
