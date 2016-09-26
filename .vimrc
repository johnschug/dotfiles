set encoding=utf-8
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
          \   'left': [ [ 'mode', 'paste' ],
          \             [ 'fugitive', 'filename', 'readonly', 'modified'  ] ],
          \   'right': [ [ 'neomake', 'lineinfo' ],
          \              [ 'percent' ],
          \              [ 'fileformat', 'fileencoding', 'filetype' ] ],
          \ },
          \ 'component_function': {
          \   'fugitive': 'LightLineFugitive',
          \   'fileformat': 'LightLineFileformat',
          \   'filetype': 'LightLineFiletype',
          \   'fileencoding': 'LightLineFileencoding',
          \ },
          \ 'component_expand': {
          \   'neomake': 'neomake#statusline#LoclistStatus',
          \ },
          \ 'component_type': { 'neomake': 'error' },
          \ }

    function! LightLineFugitive()
      if exists('*fugitive#head')
        let l:branch = fugitive#head()
        return l:branch !=# '' ? l:branch : ''
      endif
      return ''
    endfunction

    function! LightLineFileformat()
      return winwidth(0) > 70 ? &fileformat : ''
    endfunction

    function! LightLineFiletype()
      return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : '') : ''
    endfunction

    function! LightLineFileencoding()
      return winwidth(0) > 70 ? (&fileencoding !=# '' ? &fileencoding : &encoding) : ''
    endfunction
  " }}}

  " Neomake {{{
    autocmd vimrc BufWritePost * Neomake
    autocmd vimrc User NeomakeCountsChanged call lightline#update()

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
  Plug 'tpope/vim-dispatch'
  Plug 'itchyny/lightline.vim'
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
  set wildignorecase
  set wildignore+=*.swp,*.bak,*~
  set wildignore+=*.pyc,*.rlib,*.class,*.o,*.obj,*.a,*.lib,*.so,*.dll,*.pdb
  set wildignore+=*/.git/**/*,*/.hg/**/*,*/.svn/**/*
  set wildignore+=tags,cscope.*

  set background=dark
  colorscheme solarized

  augroup vimrc
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

  augroup vimrc
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
    for s:cmd in [['a', ''], ['b', 'b'], ['t', 't'], ['q', 'c'], ['l', 'l']]
      execute 'nnoremap <silent> <expr> ['.s:cmd[0]." ':<C-U>'.v:count1.'".s:cmd[1]."prev<CR>'"
      execute 'nnoremap <silent> <expr> ]'.s:cmd[0]." ':<C-U>'.v:count1.'".s:cmd[1]."next<CR>'"
      execute 'nnoremap <silent> ['.toupper(s:cmd[0]).' :<C-U>'.s:cmd[1].'first<CR>'
      execute 'nnoremap <silent> ]'.toupper(s:cmd[0]).' :<C-U>'.s:cmd[1].'last<CR>'
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

  autocmd vimrc FileType * :let &l:tags = &tags . ',' . expand('~/.vim/tags/') . &ft
" }}}

" File Types {{{
  augroup vimrc
    autocmd FileType vim setlocal keywordprg=:help
    autocmd FileType gitcommit,text,markdown,pandoc,c,cpp,rust setlocal spell
  augroup END
" }}}

" Projects {{{
  let s:gitroot = substitute(system('git rev-parse --show-toplevel'), '[\n\r]', '', 'g')
  if v:shell_error == 0 && s:gitroot !=# ''
    let &path = &path . ',' . s:gitroot . '/**'
    let &tags = &tags . ',' . s:gitroot . '/.git/tags'
  endif
" }}}

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
elseif filereadable(expand('~/_vimrc.local'))
  source ~/_vimrc.local
endif

" vim:foldmethod=marker:foldlevel=0:sw=2:sts=2:ts=2:expandtab
