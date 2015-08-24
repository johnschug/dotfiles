if exists("g:loaded_syntastic_groovy_groovyc_checker")
  finish
endif
let g:loaded_syntastic_groovy_groovyc_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_groovy_groovyc_GetLocList() dict
  let makeprg = self.makeprgBuild({})
  let errorformat='%f: %l: %m @ line %*\d\, column %c.,%-C%.%#'

  let loclist = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

  call self.setWantSort(1)

  return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
            \ 'filetype': 'groovy',
            \ 'name': 'groovyc',
            \ 'exec': 'groovyc' })

let &cpo = s:save_cpo
unlet s:save_cpo
