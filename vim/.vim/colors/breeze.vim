" Name:     Breeze vim colorscheme
" Author:   John Schug <john.ips.schug@gmail.com>
" License:  MIT
" Created:  2016-10-30
" Based On: Solarized by Ethan Schoonover
"
" Colors {{{
let g:breeze_colors = {
      \ 'red': { 'gui': '#dc322f', 'cterm256': 160, 'cterm16': 1 },
      \ 'green': { 'gui':  '#27ae60', 'cterm256': 100, 'cterm16': 2 },
      \ 'blue': { 'gui': '#1d99f3', 'cterm256': 33, 'cterm16': 4 },
      \ 'magenta': { 'gui': '#9b59b6', 'cterm256': 25, 'cterm16': 5},
      \ 'cyan': { 'gui': '#27aeae', 'cterm256': 36, 'cterm16': 6},
      \ 'orange': { 'gui': '#cb4b16', 'cterm256': 166, 'cterm16': 9 },
      \ 'violet': { 'cterm16': 13, 'cterm256': 24, 'gui': '#8e44ad'},
      \ 'white': { 'cterm16': 7, 'cterm256': 255, 'gui':  '#eef0f1'},
      \ 'black': { 'cterm16': 8, 'cterm256': 235, 'gui':  '#232629'},
      \ 'charcoal_grey': { 'cterm16': 0, 'cterm256': 237, 'gui':  '#31363b'},
      \ 'comment_grey': { 'cterm16': 10, 'cterm256': 241, 'gui': '#586e75'},
      \ 'normal': { 'cterm16': 12, 'cterm256': 245, 'gui': '#7f8c8d'},
      \ 'search': { 'gui': '#2980b9', 'cterm256': 31, 'cterm16': 3 },
      \ 'inactive': { 'cterm16': 11, 'cterm256': 243, 'gui': '#657b83'},
      \ 'base1': { 'cterm16': 15, 'cterm256': 247, 'gui': '#95a5a6'},
      \ 'visual': { 'gui': '#2d5c76', 'cterm256': '244', 'cterm16': 4 }
      \}
let s:red = g:breeze_colors.red
let s:green = g:breeze_colors.green
let s:search = g:breeze_colors.search
let s:blue = g:breeze_colors.blue
let s:magenta = g:breeze_colors.magenta
let s:cyan = g:breeze_colors.cyan
let s:orange = g:breeze_colors.orange
let s:violet = g:breeze_colors.violet
let s:white = g:breeze_colors.white
let s:black = g:breeze_colors.black
let s:charcoal_grey = g:breeze_colors.charcoal_grey
let s:comment_grey = g:breeze_colors.comment_grey
let s:inactive = g:breeze_colors.inactive
let s:normal = g:breeze_colors.normal
let s:base1 = g:breeze_colors.base1
let s:visual = g:breeze_colors.visual
"}}}

" Initialization {{{
highlight clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name = 'breeze'

let s:termcolors = (min([get(g:, 'breeze_termcolors', 256), &t_Co]) < 256)?16:256
let s:italics = get(g:, "breeze_italics", 1)

function! s:h(group, style) abort
  if s:italics == 0
    if index(split(get(a:style, 'fmt', ''), ','), 'italic') >= 0
      unlet a:style.fmt
    endif
  endif

  let l:ctermfg = (has_key(a:style, 'fg') ? a:style.fg['cterm'.s:termcolors] : 'NONE')
  let l:ctermbg = (has_key(a:style, 'bg') ? a:style.bg['cterm'.s:termcolors] : 'NONE')

  execute 'highlight' a:group
        \ 'guifg='   (has_key(a:style, 'fg')    ? a:style.fg.gui   : 'NONE')
        \ 'guibg='   (has_key(a:style, 'bg')    ? a:style.bg.gui   : 'NONE')
        \ 'guisp='   (has_key(a:style, 'sp')    ? a:style.sp.gui   : 'NONE')
        \ 'gui='     (get(a:style, 'fmt', 'NONE'))
        \ 'ctermfg=' . l:ctermfg
        \ 'ctermbg=' . l:ctermbg
        \ 'cterm='   (get(a:style, 'fmt', 'NONE'))
        \ 'term='   (get(a:style, 'fmt', 'NONE'))
endfunction
"}}}

" Base highlighting"{{{
call s:h('Normal', { 'fg': s:normal, 'bg': s:black })

call s:h('Comment', { 'fg': s:comment_grey, 'fmt': 'italic' })
"       *Comment         any comment

call s:h('Constant', { 'fg': s:cyan })
"       *Constant        any constant
"        String          a string constant: "this is a string"
"        Character       a character constant: 'c', '\n'
"        Number          a number constant: 234, 0xff
"        Boolean         a boolean constant: TRUE, false
"        Float           a floating point constant: 2.3e10

call s:h('Identifier', { 'fg': s:blue })
"       *Identifier      any variable name
"        Function        function name (also: methods for classes)
"
call s:h('Statement', { 'fg': s:green })
call s:h('Exception', { 'fmt': 'bold' })
"       *Statement       any statement
"        Conditional     if, then, else, endif, switch, etc.
"        Repeat          for, do, while, etc.
"        Label           case, default, etc.
"        Operator        "sizeof", "+", "*", etc.
"        Keyword         any other keyword
"        Exception       try, catch, throw

call s:h('PreProc', { 'fg': s:orange })
"       *PreProc         generic Preprocessor
"        Include         preprocessor #include
"        Define          preprocessor #define
"        Macro           same as Define
"        PreCondit       preprocessor #if, #else, #endif, etc.

call s:h('Type', { 'fg': s:magenta })
"       *Type            int, long, char, etc.
"        StorageClass    static, register, volatile, etc.
"        Structure       struct, union, enum, etc.
"        Typedef         A typedef

call s:h('Special', { 'fg': s:red })
call s:h('SpecialComment', { 'fg': s:red, 'fmt': 'italic' })
"       *Special         any special symbol
"        SpecialChar     special character in a constant
"        Tag             you can use CTRL-] on this
"        Delimiter       character that needs attention
"        Debug           debugging statements
"        SpecialComment  special things inside a comment

call s:h('Underlined', { 'fg': s:violet })
"       *Underlined      text that stands out, HTML links

call s:h('Ignore', {})
"       *Ignore          left blank, hidden  |hl-Ignore|

call s:h('Error', { 'fg': s:red, 'fmt': 'bold' })
"       *Error           any erroneous construct

call s:h('Todo', { 'fg': s:base1, 'fmt': 'bold' })
"       *Todo            anything that needs extra attention; mostly the
"                        keywords TODO FIXME and XXX
"
"}}}
" Extended highlighting {{{
call s:h('SpecialKey', {'fg': s:inactive, 'fmt': 'bold'})
call s:h('NonText', {'fg': s:inactive})
call s:h('StatusLine', {'fg': s:base1, 'bg': s:charcoal_grey})
call s:h('StatusLineNC', {'fg': s:inactive, 'bg': s:charcoal_grey})
call s:h('Visual', {'fg': s:visual, 'bg': s:black, 'fmt': 'reverse'})
call s:h('Directory', {'fg': s:blue})
call s:h('ErrorMsg', {'fg': s:red})
call s:h('IncSearch', {'fg': s:orange, 'fmt': 'standout'})
call s:h('Search', {'fg': s:search, 'fmt': 'reverse'})
call s:h('MoreMsg', {'fg': s:blue})
call s:h('ModeMsg', {'fg': s:blue})
call s:h('LineNr', {'fg': s:comment_grey, 'bg': s:charcoal_grey})
call s:h('Question', {'fg': s:cyan, 'fmt': 'bold'})
call s:h('VertSplit', {'fg': s:charcoal_grey, 'bg': s:charcoal_grey})
call s:h('Title', {'fg': s:orange, 'fmt': 'bold'})
call s:h('VisualNOS', {'bg': s:charcoal_grey, 'fmt': 'standout,reverse'})
call s:h('WarningMsg', {'fg': s:red, 'fmt': 'bold'})
call s:h('WildMenu', {'fg': s:white, 'bg': s:charcoal_grey, 'fmt': 'reverse'})
call s:h('Folded', {'fg': s:normal, 'bg': s:charcoal_grey, 'sp': s:black, 'fmt': 'underline,bold'})
call s:h('FoldColumn', {'fg': s:normal, 'bg': s:charcoal_grey})
call s:h('DiffAdd', {'fg': s:green, 'bg': s:charcoal_grey, 'fmt': 'bold'})
call s:h('DiffChange', {'fg': s:search, 'bg': s:charcoal_grey, 'fmt': 'bold'})
call s:h('DiffDelete', {'fg': s:red, 'bg': s:charcoal_grey, 'fmt': 'bold'})
call s:h('DiffText', {'fg': s:blue, 'bg': s:charcoal_grey, 'fmt': 'bold'})
call s:h('SignColumn', {'fg': s:normal, 'bg': s:charcoal_grey})
call s:h('Conceal', {'fg': s:blue})
call s:h('SpellBad', {'sp': s:red, 'fmt': 'undercurl'})
call s:h('SpellCap', {'sp': s:violet, 'fmt': 'undercurl'})
call s:h('SpellRare', {'sp': s:cyan, 'fmt': 'undercurl'})
call s:h('SpellLocal', {'sp': s:orange, 'fmt': 'undercurl'})
call s:h('Pmenu', {'fg': s:normal, 'bg': s:charcoal_grey, 'fmt': 'reverse'})
call s:h('PmenuSel', {'fg': s:comment_grey, 'bg': s:charcoal_grey, 'fmt': 'reverse'})
call s:h('PmenuSbar', {'fg': s:white, 'bg': s:normal, 'fmt': 'reverse'})
call s:h('PmenuThumb', {'fg': s:normal, 'bg': s:black, 'fmt': 'reverse'})
call s:h('TabLine', {'fg': s:normal, 'bg': s:charcoal_grey, 'sp': s:normal, 'fmt': 'underline'})
call s:h('TabLineFill', {'fg': s:normal, 'bg': s:charcoal_grey, 'sp': s:normal, 'fmt': 'underline'})
call s:h('TabLineSel', {'fg': s:comment_grey, 'bg': s:white, 'sp': s:normal, 'fmt': 'reverse,underline'})
call s:h('CursorColumn', {'bg': s:charcoal_grey})
call s:h('CursorLine', {'bg': s:charcoal_grey})
call s:h('CursorLineNr', {'bg': s:charcoal_grey, 'fmt': 'bold'})
call s:h('ColorColumn', {'bg': s:charcoal_grey})
call s:h('Cursor', {'fg': s:black, 'bg': s:normal})
hi! link lCursor Cursor
call s:h('MatchParen', {'fg': s:red, 'fmt': 'bold'})
call s:h('QuickFixLine', {'bg': s:charcoal_grey})
"}}}
" Plugins {{{
  call s:h('WarningSign', {'fg': s:orange, 'bg': s:charcoal_grey, 'fmt': 'bold'})
  call s:h('ErrorSign', {'fg': s:red, 'bg': s:charcoal_grey, 'fmt': 'bold'})
  " Syntastic {{{
  hi! link SyntasticWarningSign WarningSign
  hi! link SyntasticErrorSign ErrorSign
  "}}}
  " Neomake {{{
  hi! link NeomakeWarningSign WarningSign
  hi! link NeomakeErrorSign ErrorSign
  "}}}
  " Ale {{{
  hi! link ALEWarningSign WarningSign
  hi! link ALEErrorSign ErrorSign
  "}}}
  " Lsp {{{
  hi! link LspWarningText WarningSign
  hi! link LspErrorText ErrorSign
  "}}}
"}}}
set background=dark
" vim:set sw=2 ts=2 et tw=78 fdm=marker fdl=0:
