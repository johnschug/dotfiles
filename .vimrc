set nocompatible
scriptencoding utf-8

" General {{{
  filetype plugin indent on
  syntax on
  set autoread
  set nobackup
  set hidden
  set encoding=utf-8
  set fileformats=unix,dos,mac
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

  set foldenable
  set foldmethod=syntax
  set foldcolumn=1
  set foldminlines=5

  set hlsearch
  set incsearch
  set ignorecase
  set smartcase

  set wildmenu
  set wildmode=longest,list,full

  set background=dark
  set t_Co=16
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
  set textwidth=80

  set formatoptions+=j
  set backspace=indent,eol,start
  set virtualedit=block
  set autoindent
  set copyindent
  set completeopt=longest,menuone,menu
  set spelllang=en_us

  set ttimeout
  set ttimeoutlen=100
" }}}

" Commands {{{
  command! -range Copy <line1>,<line2>!xclip -f -sel clip
  command! Paste :read !xclip -o -sel clip

  if executable('ag')
    set grepprg=ag\ --nogroup\ --nocolor
  endif
" }}}

" Mappings {{{
  " Navigation {{{
    nnoremap j gj
    nnoremap k gk
    nnoremap gb <C-^>
    nnoremap <silent> <expr> [a ':<C-U>' . v:count1 . 'prev<CR>'
    nnoremap <silent> <expr> ]a ':<C-U>' . v:count1 . 'next<CR>'
    nnoremap <silent> <expr> [A ':<C-U>' . v:count1 . 'first<CR>'
    nnoremap <silent> <expr> ]A ':<C-U>' . v:count1 . 'last<CR>'
    nnoremap <silent> <expr> [b ':<C-U>' . v:count1 . 'bprev<CR>'
    nnoremap <silent> <expr> ]b ':<C-U>' . v:count1 . 'bnext<CR>'
    nnoremap <silent> <expr> [B ':<C-U>' . v:count1 . 'bfirst<CR>'
    nnoremap <silent> <expr> ]B ':<C-U>' . v:count1 . 'blast<CR>'
    nnoremap <silent> <expr> [t ':<C-U>' . v:count1 . 'tprev<CR>'
    nnoremap <silent> <expr> ]t ':<C-U>' . v:count1 . 'tnext<CR>'
    nnoremap <silent> <expr> [T ':<C-U>' . v:count1 . 'tfirst<CR>'
    nnoremap <silent> <expr> ]T ':<C-U>' . v:count1 . 'tlast<CR>'
    nnoremap <silent> <expr> [q ':<C-U>' . v:count1 . 'cprev<CR>'
    nnoremap <silent> <expr> ]q ':<C-U>' . v:count1 . 'cnext<CR>'
    nnoremap <silent> <expr> [Q ':<C-U>' . v:count1 . 'cfirst<CR>'
    nnoremap <silent> <expr> ]Q ':<C-U>' . v:count1 . 'clast<CR>'
    nnoremap <silent> <expr> [l ':<C-U>' . v:count1 . 'lprev<CR>'
    nnoremap <silent> <expr> ]l ':<C-U>' . v:count1 . 'lnext<CR>'
    nnoremap <silent> <expr> [L ':<C-U>' . v:count1 . 'lfirst<CR>'
    nnoremap <silent> <expr> ]L ':<C-U>' . v:count1 . 'llast<CR>'
  " }}}
  nnoremap <silent> [<Space> :<C-U>put! =repeat(nr2char(10), v:count1)<CR>']+1
  nnoremap <silent> ]<Space> :<C-U>put =repeat(nr2char(10), v:count1)<CR>'[-1
  nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'
  nnoremap <silent> <Leader>n :set relativenumber!<CR>
  nnoremap <silent> <Leader>o :set paste!<CR>
  nnoremap <silent> <Leader>j :setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4<CR>
  nnoremap <silent> <Leader>J :setlocal expandtab tabstop=8 shiftwidth=8 softtabstop=4<CR>
  nnoremap <silent> <Leader>M :setlocal noexpandtab tabstop=8 shiftwidth=4 softtabstop=4<CR>
  nnoremap <silent> <Leader>m :setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2<CR>
  nnoremap <silent> <Leader>g :YcmCompleter GoTo<CR>
  nnoremap <silent> <Leader>f :silent! grep! "\b<C-R><C-W>\b"<CR>:cw<CR>
  nnoremap <silent> <C-L> :nohl<CR><C-L>
  nnoremap <silent> <F3> :TagbarToggle<CR>
  nnoremap <silent> <F5> :YcmForceCompileAndDiagnostics<CR>
  nmap ga <Plug>(UnicodeGA)

  onoremap ae :<C-U>keepjumps normal! ggVG<CR>

  cnoremap <C-D> <C-R>=expand("%:h")<CR>/
" }}}

" Plugins {{{
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
    let g:ycm_semantic_triggers = {
          \ 'rust' : ['.', '::'],
          \ }
  " }}}

  " UltiSnips {{{
    let g:UltiSnipsExpandTrigger = "<c-j>"
    let g:UltiSnipsJumpForwardTrigger = "<c-j>"
    let g:UltiSnipsJumpBackwardTrigger = "<c-k>"
  " }}}

  " Racer {{{
    let g:racer_cmd = expand('~/.vim/bundle/racer/target/release/racer')
  " }}}

  " tags {{{
    set tags+=~/.vim/tags

    let gitroot = substitute(system('git rev-parse --show-toplevel'), '[\n\r]', '', 'g')
    if gitroot != ''
      let &tags = &tags . ',' . gitroot . '/.git/tags'
    endif
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
  Plug 'vim-pandoc/vim-pandoc-syntax'
  Plug 'rust-lang/rust.vim', { 'for': 'rust' }
  Plug 'phildawes/racer', { 'for': 'rust', 'do': 'cargo build --release' }
  Plug 'racer-rust/vim-racer', { 'for': 'rust' }
  Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer --system-libclang' }
  call plug#end()
" }}}

if filereadable(expand('~/.vimrc.local'))
  execute 'source' expand('~/.vimrc.local')
elseif filereadable(expand('~/_vimrc.local'))
  execute 'source' expand('~/_vimrc.local')
endif

" vim:foldmethod=marker:foldlevel=0
