if exists('did_load_filetypes')
  finish
endif

augroup filetypedetect
  autocmd! BufNewFile,BufRead {.,}tmux*.conf setfiletype tmux
augroup END
