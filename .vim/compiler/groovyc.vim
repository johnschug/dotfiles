if exists("current_compiler")
  finish
endif

let current_compiler = "groovyc"
setlocal makeprg=groovyc\ %
setlocal errorformat=%f:\ %l:\ %m\ @\ line\ %*\\d\\,\ column\ %c.,%-G%.%#

