" Name:     Breeze vim colorscheme
" Author:   John Schug <john.ips.schug@gmail.com>
" License:  MIT
" Created:  2016-10-30
" Based On: Solarized by Ethan Schoonover
"
" Colors {{{
let g:breeze_colors = {
      \ 'bg0':   '#232629',
      \ 'bg1':   '#31363b',
      \ 'bg2': '#2a2e32',
      \ 'inactive':  '#657b83',
      \ 'search':  '#3daee9',
      \ 'visual':  '#2980b9',
      \ 'normal':  '#7f8c8d',
      \ 'red': '#da4453',
      \ 'green': '#27ae60',
      \ 'blue':  '#1d99f3',
      \ 'magenta':  '#9b59b6',
      \ 'cyan':  '#27aeae',
      \ 'orange':  '#f67400',
      \ 'violet':  '#8e44ad',
      \ 'white':  '#cfcfc2',
      \ 'comment_grey':  '#586e75',
      \ 'base1':  '#95a5a6',
      \}
let s:bg0 = g:breeze_colors.bg0
let s:bg1 = g:breeze_colors.bg1
let s:bg2 = g:breeze_colors.bg2
let s:inactive = g:breeze_colors.inactive
let s:normal = g:breeze_colors.normal

let s:red = g:breeze_colors.red
let s:green = g:breeze_colors.green
let s:blue = g:breeze_colors.blue
let s:magenta = g:breeze_colors.magenta
let s:cyan = g:breeze_colors.cyan
let s:orange = g:breeze_colors.orange
let s:violet = g:breeze_colors.violet
let s:white = g:breeze_colors.white

let s:comment_grey = g:breeze_colors.comment_grey
let s:base1 = g:breeze_colors.base1
let s:search = g:breeze_colors.search
let s:visual = g:breeze_colors.visual
"}}}

" Initialization {{{
highlight clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name = 'breeze'

let s:italics = get(g:, 'breeze_italics', 1)
function! s:h(group, style) abort
  if s:italics == 0
    if index(split(get(a:style, 'fmt', ''), ','), 'italic') >= 0
      unlet a:style.fmt
    endif
  endif

  execute 'highlight' a:group
        \ 'guifg='   (has_key(a:style, 'fg') ? a:style.fg : 'NONE')
        \ 'guibg='   (has_key(a:style, 'bg') ? a:style.bg : 'NONE')
        \ 'guisp='   (has_key(a:style, 'sp') ? a:style.sp : 'NONE')
        \ 'gui='     (get(a:style, 'fmt', 'NONE'))
endfunction
"}}}

" Base highlighting"{{{
call s:h('Normal', { 'fg': s:normal, 'bg': s:bg0 })

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

call s:h('Type', { 'fg': s:violet })
"       *Type            int, long, char, etc.
"        StorageClass    static, register, volatile, etc.
"        Structure       struct, union, enum, etc.
"        Typedef         A typedef

call s:h('Special', { 'fg': s:inactive })
call s:h('SpecialComment', { 'fg': s:inactive, 'fmt': 'italic' })
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
call s:h('MatchParen', {'fg': s:white, 'fmt': 'bold'})
call s:h('SpecialKey', {'fg': s:inactive, 'fmt': 'bold'})
call s:h('NonText', {'fg': s:inactive})
call s:h('Directory', {'fg': s:blue})
call s:h('Search', {'fg': s:search, 'fmt': 'reverse'})
call s:h('IncSearch', {'fg': s:orange, 'fmt': 'standout'})
call s:h('Question', {'fg': s:cyan, 'fmt': 'bold'})
call s:h('VertSplit', {'fg': s:bg1, 'bg': s:bg1})
call s:h('Title', {'fg': s:orange, 'fmt': 'bold'})
call s:h('Folded', {'fg': s:normal, 'bg': s:bg1, 'sp': s:bg0, 'fmt': 'underline,bold'})

call s:h('DiffAdd', {'fg': s:green, 'bg': s:bg1, 'fmt': 'bold'})
call s:h('DiffChange', {'fg': s:search, 'bg': s:bg1, 'fmt': 'bold'})
call s:h('DiffDelete', {'fg': s:red, 'bg': s:bg1, 'fmt': 'bold'})
call s:h('DiffText', {'fg': s:blue, 'bg': s:bg1, 'fmt': 'bold'})

call s:h('Conceal', {'fg': s:blue})
call s:h('SpellBad', {'sp': s:red, 'fmt': 'undercurl'})
call s:h('SpellCap', {'sp': s:violet, 'fmt': 'undercurl'})
call s:h('SpellRare', {'sp': s:cyan, 'fmt': 'undercurl'})
call s:h('SpellLocal', {'sp': s:orange, 'fmt': 'undercurl'})

call s:h('ModeMsg', {'fg': s:blue})
hi! link MoreMsg ModeMsg
call s:h('WarningMsg', {'fg': s:orange, 'fmt': 'bold'})
call s:h('ErrorMsg', {'fg': s:red, 'fmt': 'bold' })

call s:h('Cursor', {'fg': s:bg0, 'bg': s:normal})
hi! link lCursor Cursor

call s:h('Visual', {'fg': s:bg0, 'bg': s:visual})
call s:h('VisualNOS', {'bg': s:bg1, 'fmt': 'standout,reverse'})
call s:h('StatusLine', {'fg': s:base1, 'bg': s:bg1})
call s:h('StatusLineNC', {'fg': s:inactive, 'bg': s:bg1})

call s:h('LineNr', {'fg': s:comment_grey, 'bg': s:bg1})
call s:h('SignColumn', {'fg': s:normal, 'bg': s:bg1})
hi! link FoldColumn SignColumn

call s:h('ColorColumn', {'bg': s:bg2})
hi! link CursorColumn CursorLine
hi! link CursorLine ColorColumn
call s:h('CursorLineNr', {'bg': s:bg1, 'fmt': 'bold'})
hi! link QuickFixLine CursorLine

call s:h('Pmenu', {'fg': s:normal, 'bg': s:bg1})
call s:h('PmenuSel', {'fg': s:comment_grey, 'bg': s:bg0, 'fmt': 'reverse'})
call s:h('PmenuSbar', {'bg': s:bg2})
call s:h('PmenuThumb', {'bg': s:white})
call s:h('WildMenu', {'fg': s:white, 'bg': s:bg1, 'fmt': 'reverse'})

call s:h('TabLine', {'fg': s:normal, 'bg': s:bg1, 'sp': s:normal, 'fmt': 'underline'})
hi! link TabLineFill TabLine
call s:h('TabLineSel', {'fg': s:comment_grey, 'bg': s:white, 'sp': s:normal, 'fmt': 'reverse,underline'})
"}}}
" Plugins {{{
  call s:h('ErrorBar', {'fg': s:red, 'fmt': 'reverse'})

  call s:h('HintText', {'fmt': 'italic'})
  hi! link InformationText HintText
  call s:h('WarningText', {'fg': s:orange, 'fmt': 'italic'})
  call s:h('ErrorText', {'fg': s:red, 'fmt': 'italic'})

  call s:h('HintSign', {'fg': s:normal, 'bg': s:bg1, 'fmt': 'bold'})
  call s:h('InformationSign', {'fg': s:blue, 'bg': s:bg1, 'fmt': 'bold'})
  call s:h('WarningSign', {'fg': s:orange, 'bg': s:bg1, 'fmt': 'bold'})
  call s:h('ErrorSign', {'fg': s:red, 'bg': s:bg1, 'fmt': 'bold'})
  " Lsp {{{
  hi! link LspReferenceText CursorLine
  hi! link LspReferenceRead LspReferenceText
  hi! link LspReferenceWrite LspReferenceText

  hi! link LspDiagnosticsUnderlineError SpellBad

  hi! link LspDiagnosticsVirtualTextHint HintText
  hi! link LspDiagnosticsVirtualTextInformation InformationText
  hi! link LspDiagnosticsVirtualTextWarning WarningText
  hi! link LspDiagnosticsVirtualTextError ErrorText

  hi! link LspDiagnosticsSignHint HintSign
  hi! link LspDiagnosticsSignInformation InformationSign
  hi! link LspDiagnosticsSignWarning WarningSign
  hi! link LspDiagnosticsSignError ErrorSign
  "}}}
"}}}
set background=dark
" vim:set sw=2 ts=2 et tw=78 fdm=marker fdl=0:
