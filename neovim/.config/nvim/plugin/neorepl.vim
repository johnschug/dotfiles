if exists('g:loaded_neorepl') || !has('nvim')
  finish
endif
let g:loaded_neorepl = 1

command! -nargs=* ReplOpen call neorepl#open(<f-args>)
command! ReplOpenLast call neorepl#open_last()
command! ReplClose call neorepl#close()
command! -nargs=? ReplReset call neorepl#reset(<f-args>)
command! -nargs=* ReplStop call neorepl#stop(<f-args>)
command! -range -nargs=? ReplSend call neorepl#send(getline(<line1>, <line2>), <q-args>)

nnoremap <unique> <script> <silent> <Plug>ReplOpen1 :ReplOpen<CR>
nnoremap <unique> <script> <silent> <Plug>ReplOpenLast :ReplOpenLast<CR>
nnoremap <unique> <script> <silent> <Plug>ReplClose :ReplClose<CR>
nnoremap <unique> <script> <silent> <Plug>ReplReset :ReplReset<CR>
nnoremap <unique> <script> <silent> <Plug>ReplStop :ReplStop<CR>
nnoremap <unique> <script> <silent> <Plug>ReplSend :call neorepl#send([getline('.')])<CR>
vnoremap <unique> <script> <silent> <Plug>ReplSend :ReplSend<CR>

nmap <LocalLeader>ro <Plug>ReplOpen1
nmap <LocalLeader>rc <Plug>ReplClose
nmap <LocalLeader>rr <Plug>ReplReset
nmap <LocalLeader>rs <Plug>ReplSend
vmap <LocalLeader>rs <Plug>ReplSend

nmap <A-'> <Plug>ReplSend
nmap <A-CR> <Plug>ReplSend
vmap <A-CR> <Plug>ReplSend
