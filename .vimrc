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
    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_python_python_exec = 'python3'
  " }}}

  " YouCompleteMe {{{
    let g:ycm_add_preview_to_completeopt = 1
    if filereadable(expand('~/.ycm_extra_conf.py'))
      let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
    endif
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
  Plug 'tpope/vim-surround'
  Plug 'tomtom/tcomment_vim'
  Plug 'SirVer/ultisnips'
  Plug 'chrisbra/unicode.vim'
  Plug 'Yggdroot/indentLine'
  Plug 'scrooloose/syntastic'
  Plug 'majutsushi/tagbar'
  Plug 'bling/vim-airline'
  Plug 'editorconfig/editorconfig-vim'
  Plug 'vim-pandoc/vim-pandoc'
  Plug 'vim-pandoc/vim-pandoc-syntax', { 'for': 'pandoc' }
  Plug 'rust-lang/rust.vim', { 'for': 'rust' }
  Plug 'phildawes/racer', { 'for': 'rust', 'do': 'cargo build --release' }
  Plug 'racer-rust/vim-racer', { 'for': 'rust' }
  Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer --system-libclang' }
  call plug#end()
" }}}

" General {{{
  filetype plugin indent on
  syntax on
  set autoread
  set hidden
  set backupdir=~/.vim/backup//,~/_vim/backup//,~/tmp//,.
  set path+=**
  set encoding=utf-8
  set fileformats=unix,dos,mac
  set shortmess+=a
" }}}

" Interface {{{
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

  set conceallevel=2
  set concealcursor=vin

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
    autocmd QuickFixCmdPost [^l]* nested cwindow|redraw!
    autocmd QuickFixCmdPost    l* nested lwindow|redraw!
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
  nnoremap <silent> K :silent! grep! "\b<C-R><C-W>\b"<CR>
  nnoremap <silent> <Leader>n :set relativenumber!<CR>
  nnoremap <silent> <Leader>o :set paste!<CR>
  nnoremap <silent> <Leader>j :setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4<CR>
  nnoremap <silent> <Leader>J :setlocal expandtab tabstop=8 shiftwidth=8 softtabstop=4<CR>
  nnoremap <silent> <Leader>M :setlocal noexpandtab tabstop=8 shiftwidth=4 softtabstop=4<CR>
  nnoremap <silent> <Leader>m :setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2<CR>
  nnoremap <silent> <Leader>g :YcmCompleter GoTo<CR>
  nnoremap <silent> <C-L> :nohlsearch<CR><C-L>
  nnoremap <silent> <F3> :TagbarToggle<CR>
  nnoremap <silent> <F5> :YcmForceCompileAndDiagnostics<CR>
  nmap ga <Plug>(UnicodeGA)

  xnoremap ae :<C-U>normal! ggVG<CR>
  onoremap ae :<C-U>keepjumps normal! ggVG<CR>

  cnoremap <C-O> <C-R>=expand("%:h")<CR>/
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

if filereadable(expand('~/.vimrc.local'))
  execute 'source' expand('~/.vimrc.local')
elseif filereadable(expand('~/_vimrc.local'))
  execute 'source' expand('~/_vimrc.local')
endif

" vim:foldmethod=marker:foldlevel=0
