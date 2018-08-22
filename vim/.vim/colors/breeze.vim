" Name:     Breeze vim colorscheme
" Author:   John Schug <john.ips.schug@gmail.com>
" License:  MIT
" Created:  2016-10-30
" Based On: Solarized by Ethan Schoonover
"
" vint: -ProhibitUsingUndeclaredVariable
"
" Colorscheme initialization "{{{
" ---------------------------------------------------------------------
hi clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name = 'breeze'

let s:use_palette = get(g:, 'breeze_use_palette', 1)
"}}}
" Palettes "{{{
" ---------------------------------------------------------------------
let s:base03      = [[8, 235],  '#232629']
let s:base02      = [[0, 237],  '#31363b']
let s:base01      = [[10, 241], '#586e75']
let s:base00      = [[11, 243], '#657b83']
let s:base0       = [[12, 245], '#7f8c8d']
let s:base1       = [[14, 247], '#93a1a1']
let s:base2       = [[7, 255],  '#eee8d5']
let s:base3       = [[15, 15], '#fdf6e3']
let s:red         = [[1, 160],  '#dc322f']
let s:green       = [[2, 100],  '#859900']
let s:yellow      = [[3, 31],  '#2980b9']
let s:blue        = [[4, 33],  '#1d99f3']
let s:magenta     = [[5, 25],  '#34495e']
let s:cyan        = [[6, 36],  '#16a085']
let s:orange      = [[9, 166],  '#cb4b16']
let s:violet      = [[13, 24], '#2c3e50']
let s:back        = s:base03

if !s:use_palette && &t_Co >= 256
  let s:mode = 1
else
  let s:mode = 0
endif
"}}}
" Highlighting primitives"{{{
" ---------------------------------------------------------------------
let s:bg_none = ' ctermbg=NONE guibg=NONE'
let s:fg_none = ' ctermfg=NONE guifg=NONE'
for s:i in ['back', 'base03', 'base02', 'base01', 'base00',
      \ 'base0', 'base1', 'base2', 'base3', 'green', 'yellow', 'orange',
      \ 'red', 'magenta', 'violet', 'blue', 'cyan']
  exe 'let s:bg_'.s:i." = ' ctermbg='.s:".s:i."[0][s:mode].' guibg='.s:".s:i.'[1]'
  exe 'let s:fg_'.s:i." = ' ctermfg='.s:".s:i."[0][s:mode].' guifg='.s:".s:i.'[1]'
endfor

let s:fmt_none     = ' cterm=NONE term=NONE gui=NONE'
let s:fmt_bold     = ' cterm=NONE,bold term=NONE,bold gui=NONE,bold'
let s:fmt_bldi     = s:fmt_bold
let s:fmt_undr     = ' cterm=NONE,underline term=NONE,underline gui=NONE,underline'
let s:fmt_undb     = ' cterm=NONE,underline,bold term=NONE,underline,bold gui=NONE,underline,bold'
let s:fmt_undi     = s:fmt_undr
let s:fmt_curl     = ' cterm=NONE,undercurl term=NONE,undercurl gui=NONE,undercurl'
let s:fmt_ital     = ' cterm=NONE,italic term=NONE,italic gui=NONE,italic'
let s:fmt_stnd     = ' cterm=NONE,standout term=NONE,standout gui=NONE,standout'
let s:fmt_revr     = ' cterm=NONE,reverse term=NONE,reverse gui=NONE,reverse'
let s:fmt_revb     = ' cterm=NONE,reverse,bold term=NONE,reverse,bold gui=NONE,reverse,bold'
let s:fmt_revbb    = ' cterm=NONE,reverse term=NONE,reverse gui=NONE,reverse'
let s:fmt_revbbu   = ' cterm=NONE,reverse,underline term=NONE,reverse,underline gui=NONE,reverse,underline'

let s:sp_none      = ' guisp=NONE'
let s:sp_back      = ' guisp='.s:back[1]
let s:sp_base03    = ' guisp='.s:base03[1]
let s:sp_base02    = ' guisp='.s:base02[1]
let s:sp_base01    = ' guisp='.s:base01[1]
let s:sp_base00    = ' guisp='.s:base00[1]
let s:sp_base0     = ' guisp='.s:base0[1]
let s:sp_base1     = ' guisp='.s:base1[1]
let s:sp_base2     = ' guisp='.s:base2[1]
let s:sp_base3     = ' guisp='.s:base3[1]
let s:sp_green     = ' guisp='.s:green[1]
let s:sp_yellow    = ' guisp='.s:yellow[1]
let s:sp_orange    = ' guisp='.s:orange[1]
let s:sp_red       = ' guisp='.s:red[1]
let s:sp_magenta   = ' guisp='.s:magenta[1]
let s:sp_violet    = ' guisp='.s:violet[1]
let s:sp_blue      = ' guisp='.s:blue[1]
let s:sp_cyan      = ' guisp='.s:cyan[1]

"}}}
" Basic highlighting"{{{
" ---------------------------------------------------------------------
" note that link syntax to avoid duplicate configuration doesn't work with the
" exe compiled formats

exe 'hi! Normal'         .s:fmt_none   .s:fg_base0  .s:bg_back

exe 'hi! Comment'        .s:fmt_ital   .s:fg_base01 .s:bg_none
"       *Comment         any comment

exe 'hi! Constant'       .s:fmt_none   .s:fg_cyan   .s:bg_none
"       *Constant        any constant
"        String          a string constant: "this is a string"
"        Character       a character constant: 'c', '\n'
"        Number          a number constant: 234, 0xff
"        Boolean         a boolean constant: TRUE, false
"        Float           a floating point constant: 2.3e10

exe 'hi! Identifier'     .s:fmt_none   .s:fg_blue   .s:bg_none
exe 'hi! Function'       .s:fmt_none   .s:fg_blue   .s:bg_none
exe 'hi! Member'         .s:fmt_none   .s:fg_blue   .s:bg_none
exe 'hi! Method'         .s:fmt_none   .s:fg_blue   .s:bg_none
exe 'hi! Field'          .s:fmt_none   .s:fg_blue   .s:bg_none
exe 'hi! LocalVariable'  .s:fmt_none   .s:fg_blue   .s:bg_none
"       *Identifier      any variable name
"        Function        function name (also: methods for classes)
"
exe 'hi! Statement'      .s:fmt_none   .s:fg_green  .s:bg_none
"       *Statement       any statement
"        Conditional     if, then, else, endif, switch, etc.
"        Repeat          for, do, while, etc.
"        Label           case, default, etc.
"        Operator        "sizeof", "+", "*", etc.
"        Keyword         any other keyword
"        Exception       try, catch, throw
exe 'hi! Exception'      .s:fmt_bold   .s:fg_green .s:bg_none

exe 'hi! PreProc'        .s:fmt_none   .s:fg_orange .s:bg_none
"       *PreProc         generic Preprocessor
"        Include         preprocessor #include
"        Define          preprocessor #define
"        Macro           same as Define
"        PreCondit       preprocessor #if, #else, #endif, etc.

exe 'hi! Type'           .s:fmt_none   .s:fg_yellow .s:bg_none
exe 'hi! Class'          .s:fmt_none   .s:fg_yellow .s:bg_none
exe 'hi! Structure'      .s:fmt_none   .s:fg_yellow .s:bg_none
"       *Type            int, long, char, etc.
"        StorageClass    static, register, volatile, etc.
"        Structure       struct, union, enum, etc.
"        Typedef         A typedef

exe 'hi! Special'        .s:fmt_none   .s:fg_red    .s:bg_none
"       *Special         any special symbol
"        SpecialChar     special character in a constant
"        Tag             you can use CTRL-] on this
"        Delimiter       character that needs attention
"        Debug           debugging statements
exe 'hi! SpecialComment' .s:fmt_ital   .s:fg_red    .s:bg_none
"        SpecialComment  special things inside a comment

exe 'hi! Underlined'     .s:fmt_none   .s:fg_violet .s:bg_none
"       *Underlined      text that stands out, HTML links

exe 'hi! Ignore'         .s:fmt_none   .s:fg_none   .s:bg_none
"       *Ignore          left blank, hidden  |hl-Ignore|

exe 'hi! Error'          .s:fmt_bold   .s:fg_red    .s:bg_none
"       *Error           any erroneous construct

exe 'hi! Todo'           .s:fmt_bold   .s:fg_base1  .s:bg_none
"       *Todo            anything that needs extra attention; mostly the
"                        keywords TODO FIXME and XXX
"
"}}}
" Extended highlighting "{{{
" ---------------------------------------------------------------------
exe 'hi! SpecialKey'     .s:fmt_bold   .s:fg_base00 .s:bg_none
exe 'hi! NonText'        .s:fmt_bold   .s:fg_base00 .s:bg_none
exe 'hi! StatusLine'     .s:fmt_none   .s:fg_base1  .s:bg_base02
exe 'hi! StatusLineNC'   .s:fmt_none   .s:fg_base00 .s:bg_base02
exe 'hi! Visual'         .s:fmt_none   .s:fg_base01 .s:bg_base03 .s:fmt_revbb
exe 'hi! Directory'      .s:fmt_none   .s:fg_blue   .s:bg_none
exe 'hi! ErrorMsg'       .s:fmt_revr   .s:fg_red    .s:bg_none
exe 'hi! IncSearch'      .s:fmt_stnd   .s:fg_orange .s:bg_none
exe 'hi! Search'         .s:fmt_revr   .s:fg_yellow .s:bg_none
exe 'hi! MoreMsg'        .s:fmt_none   .s:fg_blue   .s:bg_none
exe 'hi! ModeMsg'        .s:fmt_none   .s:fg_blue   .s:bg_none
exe 'hi! LineNr'         .s:fmt_none   .s:fg_base01 .s:bg_base02
exe 'hi! Question'       .s:fmt_bold   .s:fg_cyan   .s:bg_none
if has('gui_running') || &t_Co > 8
  exe 'hi! VertSplit'  .s:fmt_none   .s:fg_base00 .s:bg_base00
else
  exe 'hi! VertSplit'  .s:fmt_revbb  .s:fg_base00 .s:bg_base02
endif
exe 'hi! Title'          .s:fmt_bold   .s:fg_orange .s:bg_none
exe 'hi! VisualNOS'      .s:fmt_stnd   .s:fg_none   .s:bg_base02 .s:fmt_revbb
exe 'hi! WarningMsg'     .s:fmt_bold   .s:fg_red    .s:bg_none
exe 'hi! WildMenu'       .s:fmt_none   .s:fg_base2  .s:bg_base02 .s:fmt_revbb
exe 'hi! Folded'         .s:fmt_undb   .s:fg_base0  .s:bg_base02  .s:sp_base03
exe 'hi! FoldColumn'     .s:fmt_none   .s:fg_base0  .s:bg_base02
exe 'hi! DiffAdd'        .s:fmt_bold   .s:fg_green  .s:bg_base02 .s:sp_green
exe 'hi! DiffChange'     .s:fmt_bold   .s:fg_yellow .s:bg_base02 .s:sp_yellow
exe 'hi! DiffDelete'     .s:fmt_bold   .s:fg_red    .s:bg_base02
exe 'hi! DiffText'       .s:fmt_bold   .s:fg_blue   .s:bg_base02 .s:sp_blue
exe 'hi! SignColumn'     .s:fmt_none   .s:fg_base0  .s:bg_base02
exe 'hi! Conceal'        .s:fmt_none   .s:fg_blue   .s:bg_none
exe 'hi! SpellBad'       .s:fmt_curl   .s:fg_none   .s:bg_none    .s:sp_red
exe 'hi! SpellCap'       .s:fmt_curl   .s:fg_none   .s:bg_none    .s:sp_violet
exe 'hi! SpellRare'      .s:fmt_curl   .s:fg_none   .s:bg_none    .s:sp_cyan
exe 'hi! SpellLocal'     .s:fmt_curl   .s:fg_none   .s:bg_none    .s:sp_yellow
exe 'hi! Pmenu'          .s:fmt_none   .s:fg_base0  .s:bg_base02  .s:fmt_revbb
exe 'hi! PmenuSel'       .s:fmt_none   .s:fg_base01 .s:bg_base2   .s:fmt_revbb
exe 'hi! PmenuSbar'      .s:fmt_none   .s:fg_base2  .s:bg_base0   .s:fmt_revbb
exe 'hi! PmenuThumb'     .s:fmt_none   .s:fg_base0  .s:bg_base03  .s:fmt_revbb
exe 'hi! TabLine'        .s:fmt_undr   .s:fg_base0  .s:bg_base02  .s:sp_base0
exe 'hi! TabLineFill'    .s:fmt_undr   .s:fg_base0  .s:bg_base02  .s:sp_base0
exe 'hi! TabLineSel'     .s:fmt_undr   .s:fg_base01 .s:bg_base2   .s:sp_base0  .s:fmt_revbbu
exe 'hi! CursorColumn'   .s:fmt_none   .s:fg_none   .s:bg_base02
exe 'hi! CursorLine'     .s:fmt_none   .s:fg_none   .s:bg_base02  .s:sp_base1
exe 'hi! CursorLineNr'   .s:fmt_bold   .s:fg_none   .s:bg_base02  .s:sp_base1
exe 'hi! ColorColumn'    .s:fmt_none   .s:fg_none   .s:bg_base02
exe 'hi! Cursor'         .s:fmt_none   .s:fg_base03 .s:bg_base0
hi! link lCursor Cursor
exe 'hi! MatchParen'     .s:fmt_bold   .s:fg_red    .s:bg_base01
exe 'hi! QuickFixLine'   .s:fmt_none   .s:fg_none   .s:bg_base02

"}}}
" vim syntax highlighting "{{{
" ---------------------------------------------------------------------
"exe "hi! vimLineComment" . s:fg_base01 .s:bg_none   .s:fmt_ital
"hi! link vimComment Comment
"hi! link vimLineComment Comment
hi! link vimVar Identifier
hi! link vimFunc Function
hi! link vimUserFunc Function
hi! link helpSpecial Special
hi! link vimSet Normal
hi! link vimSetEqual Normal
exe 'hi! vimCommentString'  .s:fmt_none    .s:fg_violet .s:bg_none
exe 'hi! vimCommand'        .s:fmt_none    .s:fg_yellow .s:bg_none
exe 'hi! vimCmdSep'         .s:fmt_bold    .s:fg_blue   .s:bg_none
exe 'hi! helpExample'       .s:fmt_none    .s:fg_base1  .s:bg_none
exe 'hi! helpOption'        .s:fmt_none    .s:fg_cyan   .s:bg_none
exe 'hi! helpNote'          .s:fmt_none    .s:fg_magenta.s:bg_none
exe 'hi! helpVim'           .s:fmt_none    .s:fg_magenta.s:bg_none
exe 'hi! helpHyperTextJump' .s:fmt_undr    .s:fg_blue   .s:bg_none
exe 'hi! helpHyperTextEntry'.s:fmt_none    .s:fg_green  .s:bg_none
exe 'hi! vimIsCommand'      .s:fmt_none    .s:fg_base00 .s:bg_none
exe 'hi! vimSynMtchOpt'     .s:fmt_none    .s:fg_yellow .s:bg_none
exe 'hi! vimSynType'        .s:fmt_none    .s:fg_cyan   .s:bg_none
exe 'hi! vimHiLink'         .s:fmt_none    .s:fg_blue   .s:bg_none
exe 'hi! vimHiGroup'        .s:fmt_none    .s:fg_blue   .s:bg_none
exe 'hi! vimGroup'          .s:fmt_undb    .s:fg_blue   .s:bg_none
"}}}
" diff highlighting "{{{
" ---------------------------------------------------------------------
hi! link diffAdded Statement
hi! link diffLine Identifier
"}}}
" git & gitcommit highlighting "{{{
"git
"exe "hi! gitDateHeader"
"exe "hi! gitIdentityHeader"
"exe "hi! gitIdentityKeyword"
"exe "hi! gitNotesHeader"
"exe "hi! gitReflogHeader"
"exe "hi! gitKeyword"
"exe "hi! gitIdentity"
"exe "hi! gitEmailDelimiter"
"exe "hi! gitEmail"
"exe "hi! gitDate"
"exe "hi! gitMode"
"exe "hi! gitHashAbbrev"
"exe "hi! gitHash"
"exe "hi! gitReflogMiddle"
"exe "hi! gitReference"
"exe "hi! gitStage"
"exe "hi! gitType"
"exe "hi! gitDiffAdded"
"exe "hi! gitDiffRemoved"
"gitcommit
"exe "hi! gitcommitSummary"
exe 'hi! gitcommitComment'      .s:fmt_ital     .s:fg_base01    .s:bg_none
hi! link gitcommitUntracked gitcommitComment
hi! link gitcommitDiscarded gitcommitComment
hi! link gitcommitSelected  gitcommitComment
exe 'hi! gitcommitUnmerged'     .s:fmt_bold     .s:fg_green     .s:bg_none
exe 'hi! gitcommitOnBranch'     .s:fmt_bold     .s:fg_base01    .s:bg_none
exe 'hi! gitcommitBranch'       .s:fmt_bold     .s:fg_magenta   .s:bg_none
hi! link gitcommitNoBranch gitcommitBranch
exe 'hi! gitcommitDiscardedType'.s:fmt_none     .s:fg_red       .s:bg_none
exe 'hi! gitcommitSelectedType' .s:fmt_none     .s:fg_green     .s:bg_none
"exe "hi! gitcommitUnmergedType"
"exe "hi! gitcommitType"
"exe "hi! gitcommitNoChanges"
"exe "hi! gitcommitHeader"
exe 'hi! gitcommitHeader'       .s:fmt_none     .s:fg_base01    .s:bg_none
exe 'hi! gitcommitUntrackedFile'.s:fmt_bold     .s:fg_cyan      .s:bg_none
exe 'hi! gitcommitDiscardedFile'.s:fmt_bold     .s:fg_red       .s:bg_none
exe 'hi! gitcommitSelectedFile' .s:fmt_bold     .s:fg_green     .s:bg_none
exe 'hi! gitcommitUnmergedFile' .s:fmt_bold     .s:fg_yellow    .s:bg_none
exe 'hi! gitcommitFile'         .s:fmt_bold     .s:fg_base0     .s:bg_none
hi! link gitcommitDiscardedArrow gitcommitDiscardedFile
hi! link gitcommitSelectedArrow  gitcommitSelectedFile
hi! link gitcommitUnmergedArrow  gitcommitUnmergedFile
"exe "hi! gitcommitArrow"
"exe "hi! gitcommitOverflow"
"exe "hi! gitcommitBlank"
" }}}
" html highlighting "{{{
" ---------------------------------------------------------------------
exe 'hi! htmlTag'           .s:fmt_none .s:fg_base01 .s:bg_none
exe 'hi! htmlEndTag'        .s:fmt_none .s:fg_base01 .s:bg_none
exe 'hi! htmlTagN'          .s:fmt_bold .s:fg_base1  .s:bg_none
exe 'hi! htmlTagName'       .s:fmt_bold .s:fg_blue   .s:bg_none
exe 'hi! htmlSpecialTagName'.s:fmt_ital .s:fg_blue   .s:bg_none
exe 'hi! htmlArg'           .s:fmt_none .s:fg_base00 .s:bg_none
exe 'hi! javaScript'        .s:fmt_none .s:fg_yellow .s:bg_none
"}}}
" perl highlighting "{{{
" ---------------------------------------------------------------------
exe 'hi! perlHereDoc'    . s:fg_base1  .s:bg_back   .s:fmt_none
exe 'hi! perlVarPlain'   . s:fg_yellow .s:bg_back   .s:fmt_none
exe 'hi! perlStatementFileDesc'. s:fg_cyan.s:bg_back.s:fmt_none
"}}}
" tex highlighting "{{{
" ---------------------------------------------------------------------
exe 'hi! texStatement'   . s:fg_cyan   .s:bg_back   .s:fmt_none
exe 'hi! texMathZoneX'   . s:fg_yellow .s:bg_back   .s:fmt_none
exe 'hi! texMathMatcher' . s:fg_yellow .s:bg_back   .s:fmt_none
exe 'hi! texMathMatcher' . s:fg_yellow .s:bg_back   .s:fmt_none
exe 'hi! texRefLabel'    . s:fg_yellow .s:bg_back   .s:fmt_none
"}}}
" haskell highlighting "{{{
" ---------------------------------------------------------------------
exe 'hi! cPreCondit'. s:fg_orange.s:bg_none   .s:fmt_none

exe 'hi! VarId'    . s:fg_blue   .s:bg_none   .s:fmt_none
exe 'hi! ConId'    . s:fg_yellow .s:bg_none   .s:fmt_none
exe 'hi! hsImport' . s:fg_magenta.s:bg_none   .s:fmt_none
exe 'hi! hsString' . s:fg_base00 .s:bg_none   .s:fmt_none

exe 'hi! hsStructure'        . s:fg_cyan   .s:bg_none   .s:fmt_none
exe 'hi! hs_hlFunctionName'  . s:fg_blue   .s:bg_none
exe 'hi! hsStatement'        . s:fg_cyan   .s:bg_none   .s:fmt_none
exe 'hi! hsImportLabel'      . s:fg_cyan   .s:bg_none   .s:fmt_none
exe 'hi! hs_OpFunctionName'  . s:fg_yellow .s:bg_none   .s:fmt_none
exe 'hi! hs_DeclareFunction' . s:fg_orange .s:bg_none   .s:fmt_none
exe 'hi! hsVarSym'           . s:fg_cyan   .s:bg_none   .s:fmt_none
exe 'hi! hsType'             . s:fg_yellow .s:bg_none   .s:fmt_none
exe 'hi! hsTypedef'          . s:fg_cyan   .s:bg_none   .s:fmt_none
exe 'hi! hsModuleName'       . s:fg_green  .s:bg_none   .s:fmt_undr
exe 'hi! hsModuleStartLabel' . s:fg_magenta.s:bg_none   .s:fmt_none
hi! link hsImportParams      Delimiter
hi! link hsDelimTypeExport   Delimiter
hi! link hsModuleStartLabel  hsStructure
hi! link hsModuleWhereLabel  hsModuleStartLabel

" following is for the haskell-conceal plugin
" the first two items don't have an impact, but better safe
exe 'hi! hsNiceOperator'     . s:fg_cyan   .s:bg_none   .s:fmt_none
exe 'hi! hsniceoperator'     . s:fg_cyan   .s:bg_none   .s:fmt_none
"}}}
" pandoc markdown syntax highlighting "{{{
" ---------------------------------------------------------------------

"PandocHiLink pandocNormalBlock
exe 'hi! pandocTitleBlock'               .s:fg_blue   .s:bg_none   .s:fmt_none
exe 'hi! pandocTitleBlockTitle'          .s:fg_blue   .s:bg_none   .s:fmt_bold
exe 'hi! pandocTitleComment'             .s:fg_blue   .s:bg_none   .s:fmt_bold
exe 'hi! pandocComment'                  .s:fg_base01 .s:bg_none   .s:fmt_ital
exe 'hi! pandocVerbatimBlock'            .s:fg_yellow .s:bg_none   .s:fmt_none
hi! link pandocVerbatimBlockDeep         pandocVerbatimBlock
hi! link pandocCodeBlock                 pandocVerbatimBlock
hi! link pandocCodeBlockDelim            pandocVerbatimBlock
exe 'hi! pandocBlockQuote'               .s:fg_blue   .s:bg_none   .s:fmt_none
exe 'hi! pandocBlockQuoteLeader1'        .s:fg_blue   .s:bg_none   .s:fmt_none
exe 'hi! pandocBlockQuoteLeader2'        .s:fg_cyan   .s:bg_none   .s:fmt_none
exe 'hi! pandocBlockQuoteLeader3'        .s:fg_yellow .s:bg_none   .s:fmt_none
exe 'hi! pandocBlockQuoteLeader4'        .s:fg_red    .s:bg_none   .s:fmt_none
exe 'hi! pandocBlockQuoteLeader5'        .s:fg_base0  .s:bg_none   .s:fmt_none
exe 'hi! pandocBlockQuoteLeader6'        .s:fg_base01 .s:bg_none   .s:fmt_none
exe 'hi! pandocListMarker'               .s:fg_magenta.s:bg_none   .s:fmt_none
exe 'hi! pandocListReference'            .s:fg_magenta.s:bg_none   .s:fmt_undr

" Definitions
" ---------------------------------------------------------------------
let s:fg_pdef = s:fg_violet
exe 'hi! pandocDefinitionBlock'              .s:fg_pdef  .s:bg_none  .s:fmt_none
exe 'hi! pandocDefinitionTerm'               .s:fg_pdef  .s:bg_none  .s:fmt_stnd
exe 'hi! pandocDefinitionIndctr'             .s:fg_pdef  .s:bg_none  .s:fmt_bold
exe 'hi! pandocEmphasisDefinition'           .s:fg_pdef  .s:bg_none  .s:fmt_ital
exe 'hi! pandocEmphasisNestedDefinition'     .s:fg_pdef  .s:bg_none  .s:fmt_bldi
exe 'hi! pandocStrongEmphasisDefinition'     .s:fg_pdef  .s:bg_none  .s:fmt_bold
exe 'hi! pandocStrongEmphasisNestedDefinition'   .s:fg_pdef.s:bg_none.s:fmt_bldi
exe 'hi! pandocStrongEmphasisEmphasisDefinition' .s:fg_pdef.s:bg_none.s:fmt_bldi
exe 'hi! pandocStrikeoutDefinition'          .s:fg_pdef  .s:bg_none  .s:fmt_revr
exe 'hi! pandocVerbatimInlineDefinition'     .s:fg_pdef  .s:bg_none  .s:fmt_none
exe 'hi! pandocSuperscriptDefinition'        .s:fg_pdef  .s:bg_none  .s:fmt_none
exe 'hi! pandocSubscriptDefinition'          .s:fg_pdef  .s:bg_none  .s:fmt_none

" Tables
" ---------------------------------------------------------------------
let s:fg_ptable = s:fg_blue
exe 'hi! pandocTable'                        .s:fg_ptable.s:bg_none  .s:fmt_none
exe 'hi! pandocTableStructure'               .s:fg_ptable.s:bg_none  .s:fmt_none
hi! link pandocTableStructureTop             pandocTableStructre
hi! link pandocTableStructureEnd             pandocTableStructre
exe 'hi! pandocTableZebraLight'              .s:fg_ptable.s:bg_base03.s:fmt_none
exe 'hi! pandocTableZebraDark'               .s:fg_ptable.s:bg_base02.s:fmt_none
exe 'hi! pandocEmphasisTable'                .s:fg_ptable.s:bg_none  .s:fmt_ital
exe 'hi! pandocEmphasisNestedTable'          .s:fg_ptable.s:bg_none  .s:fmt_bldi
exe 'hi! pandocStrongEmphasisTable'          .s:fg_ptable.s:bg_none  .s:fmt_bold
exe 'hi! pandocStrongEmphasisNestedTable'    .s:fg_ptable.s:bg_none  .s:fmt_bldi
exe 'hi! pandocStrongEmphasisEmphasisTable'  .s:fg_ptable.s:bg_none  .s:fmt_bldi
exe 'hi! pandocStrikeoutTable'               .s:fg_ptable.s:bg_none  .s:fmt_revr
exe 'hi! pandocVerbatimInlineTable'          .s:fg_ptable.s:bg_none  .s:fmt_none
exe 'hi! pandocSuperscriptTable'             .s:fg_ptable.s:bg_none  .s:fmt_none
exe 'hi! pandocSubscriptTable'               .s:fg_ptable.s:bg_none  .s:fmt_none

" Headings
" ---------------------------------------------------------------------
let s:fg_phead = s:fg_orange
exe 'hi! pandocHeading'                      .s:fg_phead .s:bg_none.s:fmt_bold
exe 'hi! pandocHeadingMarker'                .s:fg_yellow.s:bg_none.s:fmt_bold
exe 'hi! pandocEmphasisHeading'              .s:fg_phead .s:bg_none.s:fmt_bldi
exe 'hi! pandocEmphasisNestedHeading'        .s:fg_phead .s:bg_none.s:fmt_bldi
exe 'hi! pandocStrongEmphasisHeading'        .s:fg_phead .s:bg_none.s:fmt_bold
exe 'hi! pandocStrongEmphasisNestedHeading'  .s:fg_phead .s:bg_none.s:fmt_bldi
exe 'hi! pandocStrongEmphasisEmphasisHeading'.s:fg_phead .s:bg_none.s:fmt_bldi
exe 'hi! pandocStrikeoutHeading'             .s:fg_phead .s:bg_none.s:fmt_revr
exe 'hi! pandocVerbatimInlineHeading'        .s:fg_phead .s:bg_none.s:fmt_bold
exe 'hi! pandocSuperscriptHeading'           .s:fg_phead .s:bg_none.s:fmt_bold
exe 'hi! pandocSubscriptHeading'             .s:fg_phead .s:bg_none.s:fmt_bold

" Links
" ---------------------------------------------------------------------
exe 'hi! pandocLinkDelim'                .s:fg_base01 .s:bg_none   .s:fmt_none
exe 'hi! pandocLinkLabel'                .s:fg_blue   .s:bg_none   .s:fmt_undr
exe 'hi! pandocLinkText'                 .s:fg_blue   .s:bg_none   .s:fmt_undb
exe 'hi! pandocLinkURL'                  .s:fg_base00 .s:bg_none   .s:fmt_undr
exe 'hi! pandocLinkTitle'                .s:fg_base00 .s:bg_none   .s:fmt_undi
exe 'hi! pandocLinkTitleDelim'           .s:fg_base01 .s:bg_none   .s:fmt_undi   .s:sp_base00
exe 'hi! pandocLinkDefinition'           .s:fg_cyan   .s:bg_none   .s:fmt_undr   .s:sp_base00
exe 'hi! pandocLinkDefinitionID'         .s:fg_blue   .s:bg_none   .s:fmt_bold
exe 'hi! pandocImageCaption'             .s:fg_violet .s:bg_none   .s:fmt_undb
exe 'hi! pandocFootnoteLink'             .s:fg_green  .s:bg_none   .s:fmt_undr
exe 'hi! pandocFootnoteDefLink'          .s:fg_green  .s:bg_none   .s:fmt_bold
exe 'hi! pandocFootnoteInline'           .s:fg_green  .s:bg_none   .s:fmt_undb
exe 'hi! pandocFootnote'                 .s:fg_green  .s:bg_none   .s:fmt_none
exe 'hi! pandocCitationDelim'            .s:fg_magenta.s:bg_none   .s:fmt_none
exe 'hi! pandocCitation'                 .s:fg_magenta.s:bg_none   .s:fmt_none
exe 'hi! pandocCitationID'               .s:fg_magenta.s:bg_none   .s:fmt_undr
exe 'hi! pandocCitationRef'              .s:fg_magenta.s:bg_none   .s:fmt_none

" Main Styles
" ---------------------------------------------------------------------
exe 'hi! pandocStyleDelim'               .s:fg_base01 .s:bg_none  .s:fmt_none
exe 'hi! pandocEmphasis'                 .s:fg_base0  .s:bg_none  .s:fmt_ital
exe 'hi! pandocEmphasisNested'           .s:fg_base0  .s:bg_none  .s:fmt_bldi
exe 'hi! pandocStrongEmphasis'           .s:fg_base0  .s:bg_none  .s:fmt_bold
exe 'hi! pandocStrongEmphasisNested'     .s:fg_base0  .s:bg_none  .s:fmt_bldi
exe 'hi! pandocStrongEmphasisEmphasis'   .s:fg_base0  .s:bg_none  .s:fmt_bldi
exe 'hi! pandocStrikeout'                .s:fg_base01 .s:bg_none  .s:fmt_revr
exe 'hi! pandocVerbatimInline'           .s:fg_yellow .s:bg_none  .s:fmt_none
exe 'hi! pandocSuperscript'              .s:fg_violet .s:bg_none  .s:fmt_none
exe 'hi! pandocSubscript'                .s:fg_violet .s:bg_none  .s:fmt_none

exe 'hi! pandocRule'                     .s:fg_blue   .s:bg_none  .s:fmt_bold
exe 'hi! pandocRuleLine'                 .s:fg_blue   .s:bg_none  .s:fmt_bold
exe 'hi! pandocEscapePair'               .s:fg_red    .s:bg_none  .s:fmt_bold
exe 'hi! pandocCitationRef'              .s:fg_magenta.s:bg_none   .s:fmt_none
exe 'hi! pandocNonBreakingSpace'         . s:fg_red   .s:bg_none  .s:fmt_revr
hi! link pandocEscapedCharacter          pandocEscapePair
hi! link pandocLineBreak                 pandocEscapePair

" Embedded Code
" ---------------------------------------------------------------------
exe 'hi! pandocMetadataDelim'            .s:fg_base01 .s:bg_none   .s:fmt_none
exe 'hi! pandocMetadata'                 .s:fg_blue   .s:bg_none   .s:fmt_none
exe 'hi! pandocMetadataKey'              .s:fg_blue   .s:bg_none   .s:fmt_none
exe 'hi! pandocMetadata'                 .s:fg_blue   .s:bg_none   .s:fmt_bold
hi! link pandocMetadataTitle             pandocMetadata
"}}}
" Syntastic "{{{
exe 'hi! SyntasticWarningSign'           .s:fg_base1  .s:bg_base02 .s:fmt_bold
exe 'hi! SyntasticErrorSign'             .s:fg_red    .s:bg_base02 .s:fmt_bold
"}}}
" Neomake "{{{
exe 'hi! NeomakeWarningSign'             .s:fg_base1  .s:bg_base02 .s:fmt_bold
exe 'hi! NeomakeErrorSign'               .s:fg_red    .s:bg_base02 .s:fmt_bold
"}}}
" Ale "{{{
exe 'hi! ALEWarningSign'                 .s:fg_base1  .s:bg_base02 .s:fmt_bold
exe 'hi! ALEErrorSign'                   .s:fg_red    .s:bg_base02 .s:fmt_bold
"}}}
" Lightline "{{{
let g:lightline#colorscheme#breeze#palette = {
      \ 'normal': {
      \   'left': [[s:base03[1], s:blue[1],
      \             s:base03[0][s:mode], s:blue[0][s:mode]],
      \            [s:base03[1], s:base00[1],
      \             s:base03[0][s:mode], s:base00[0][s:mode]]],
      \   'right': [[s:base03[1], s:base1[1],
      \              s:base03[0][s:mode], s:base1[0][s:mode]],
      \             [s:base03[1], s:base00[1],
      \              s:base03[0][s:mode], s:base00[0][s:mode]]],
      \   'middle': [[s:base1[1], s:base02[1],
      \               s:base1[0][s:mode], s:base02[0][s:mode]]],
      \   'error': [[s:base03[1], s:red[1],
      \              s:base03[0][s:mode], s:red[0][s:mode]]],
      \   'warning': [[s:base03[1], s:yellow[1],
      \                s:base03[0][s:mode], s:yellow[0][s:mode]]],
      \ },
      \ 'tabline': {
      \   'left': [[s:base03[1], s:base00[1],
      \             s:base03[0][s:mode], s:base00[0][s:mode]]],
      \   'right': [[s:base03[1], s:base1[1],
      \              s:base03[0][s:mode], s:base1[0][s:mode]],
      \             [s:base03[1], s:base00[1],
      \              s:base03[0][s:mode], s:base00[0][s:mode]]],
      \   'middle': [[s:base0[1], s:base02[1],
      \               s:base0[0][s:mode], s:base02[0][s:mode]]],
      \   'tabsel': [[s:base03[1], s:base1[1],
      \               s:base03[0][s:mode], s:base1[0][s:mode]]],
      \ },
      \ 'inactive': {
      \   'left': [[s:base00[1], s:base02[1],
      \             s:base00[0][s:mode], s:base02[0][s:mode]],
      \            [s:base00[1], s:base02[1],
      \             s:base00[0][s:mode], s:base02[0][s:mode]]],
      \   'right': [[s:base03[1], s:base00[1],
      \              s:base03[0][s:mode], s:base00[0][s:mode]],
      \             [s:base00[1], s:base02[1],
      \              s:base00[0][s:mode], s:base02[0][s:mode]]],
      \   'middle': [[s:base00[1], s:base02[1],
      \               s:base00[0][s:mode], s:base02[0][s:mode]]],
      \ },
      \ 'insert': {
      \   'left': [[s:base03[1], s:green[1],
      \             s:base03[0][s:mode], s:green[0][s:mode]],
      \            [s:base03[1], s:base00[1],
      \             s:base03[0][s:mode], s:base00[0][s:mode]]],
      \ },
      \ 'replace': {
      \   'left': [[s:base03[1], s:red[1],
      \             s:base03[0][s:mode], s:red[0][s:mode]],
      \            [s:base03[1], s:base00[1],
      \             s:base03[0][s:mode], s:base00[0][s:mode]]],
      \ },
      \ 'visual': {
      \   'left': [[s:base03[1], s:magenta[1],
      \             s:base03[0][s:mode], s:magenta[0][s:mode]],
      \            [s:base03[1], s:base00[1],
      \             s:base03[0][s:mode], s:base00[0][s:mode]]],
      \ },
      \}
"}}}
set background=dark

" License "{{{
" ---------------------------------------------------------------------
"
" Copyright (c) 2011 Ethan Schoonover
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.
"}}}
" vim:set sw=2 ts=2 et tw=78 fdm=marker fdl=0:
