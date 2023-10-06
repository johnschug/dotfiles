local api = vim.api
local M = {}

local autocmd = {}

autocmd.add = api.nvim_create_autocmd
autocmd.del = api.nvim_del_autocmd
autocmd.clear = api.nvim_clear_autocmds
autocmd.get = api.nvim_get_autocmds

function autocmd.group(name, clear)
  local grp = api.nvim_create_augroup(name, {clear = clear or false})
  return setmetatable({}, {
    __index = {
      add = function(event, opts)
        return autocmd.add(event, vim.tbl_extend('keep', {group = grp}, opts or {}))
      end,
      clear = function(opts)
        return autocmd.clear(vim.tbl_extend('keep', {group = grp}, opts or {}))
      end,
    },
  })
end

M.autocmd = autocmd

return M
