local colors = vim.g.breeze_colors
return {
  normal = {
    a = {bg = colors.blue, fg = colors.bg0},
    b = {bg = colors.inactive, fg = colors.bg0},
    c = {bg = colors.bg1, fg = colors.base1},
    y = {bg = colors.inactive, fg = colors.bg0},
    z = {bg = colors.base1, fg = colors.bg0},
  },
  insert = {
    a = {bg = colors.green, fg = colors.bg0},
  },
  replace = {
    a = {bg = colors.red, fg = colors.bg0},
  },
  visual = {
    a = {bg = colors.magenta, fg = colors.bg0},
  },
  inactive = {
    a = {bg = colors.bg1, fg = colors.inactive},
    b = {bg = colors.bg1, fg = colors.inactive},
    c = {bg = colors.bg1, fg = colors.inactive},
    y = {bg = colors.bg1, fg = colors.inactive},
    z = {bg = colors.inactive, fg = colors.bg0},
  },
}
