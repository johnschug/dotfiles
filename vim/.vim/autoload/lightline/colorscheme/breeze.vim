let s:mode = (min([get(g:, 'breeze_termcolors', 256), &t_Co]) < 256)?16:256
let s:colors = {}
for color in keys(g:breeze_colors)
  let s:colors[color] = [g:breeze_colors[color].gui, g:breeze_colors[color]['cterm'.s:mode]]
endfor

let s:red = s:colors.red
let s:green = s:colors.green
let s:search = s:colors.search
let s:blue = s:colors.blue
let s:magenta = s:colors.magenta
let s:cyan = s:colors.cyan
let s:orange = s:colors.orange
let s:violet = s:colors.violet
let s:white = s:colors.white
let s:black = s:colors.black
let s:charcoal_grey = s:colors.charcoal_grey
let s:comment_grey = s:colors.comment_grey
let s:inactive = s:colors.inactive
let s:normal = s:colors.normal
let s:base1 = s:colors.base1
let s:visual = s:colors.visual

let s:p = {'normal': {}, 'tabline': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}}
let s:p.normal.left = [[s:black, s:blue], [s:black, s:inactive]]
let s:p.normal.right = [[s:black, s:base1], [s:black, s:inactive]]
let s:p.normal.middle = [[s:base1, s:charcoal_grey]]
let s:p.normal.warning = [[s:black, s:orange]]
let s:p.normal.error = [[s:black, s:red]]
let s:p.inactive.left =  [[s:inactive, s:charcoal_grey], [s:inactive, s:charcoal_grey]]
let s:p.inactive.right = [[s:black, s:inactive], [s:inactive, s:charcoal_grey]]
let s:p.inactive.middle = [[s:inactive, s:charcoal_grey]]
let s:p.insert.left = [[s:black, s:green], [s:black, s:inactive]]
let s:p.replace.left = [[s:black, s:red], [s:black, s:inactive]]
let s:p.visual.left = [[s:black, s:magenta], [s:black, s:inactive]]
let s:p.tabline.left = [[s:black, s:inactive]]
let s:p.tabline.tabsel = [[s:black, s:base1]]
let s:p.tabline.middle = [[s:normal, s:charcoal_grey]]
let s:p.tabline.right = [[s:black, s:base1], [s:black, s:inactive]]
let g:lightline#colorscheme#breeze#palette = lightline#colorscheme#flatten(s:p)
