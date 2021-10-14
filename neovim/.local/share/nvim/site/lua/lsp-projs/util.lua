local api = vim.api

local M = {}

---@generic T
---@param list T[]
---@return table<T, boolean>
function M.make_set(list)
  vim.validate {list={list, vim.tbl_islist, 'a list'}}

  local result = {}
  for _, v in pairs(list) do
    result[v] = true
  end
  return result
end

do
  local cmap = {
    {['%'] = '%%', ['\n'] = '%\\n'},
    {['%%'] = '%', ['%\\n'] = '\n'},
  }
  M.escape = function(str)
    local res = str:gsub('.', cmap[1])
    return res
  end

  M.unescape = function(str)
    local res = str:gsub('%%.', cmap[2])
    return res
  end
end

---@param path string
---@return string|nil
function M.readfile(path)
  vim.validate {
    path = {path, 'string'}
  }

  local file = io.open(path, 'r')
  if not file then
    return
  end

  local contents = file:read('*a')
  file:close()
  return contents
end

---@param path string
---@return table|nil
function M.readjson(path)
  local contents = M.readfile(path)
  if not contents then
    return
  end

  local ok, decoded = pcall(vim.fn.json_decode, contents)
  return ok and decoded or nil
end

---@param path string
---@param contents string
function M.writefile(path, contents)
  vim.validate {
    path = {path, 'string'}
  }

  local file = assert(io.open(path, 'w'))
  local ok, err = file:write(contents)
  assert(file:close())
  assert(ok, err)
end

---@param path string
---@param contents table
function M.writejson(path, contents)
  M.writefile(path, vim.fn.json_encode(contents))
end

---@param bufnr number
---@param events string|string[]
---@param cmd string
function M.buf_set_autocmd(bufnr, events, cmd)
  events = type(events) == 'table' and events or {events}
  events = table.concat(vim.tbl_flatten(events), ',')
  api.nvim_command(string.format('autocmd %s <buffer=%d> %s', events, bufnr, cmd))
end

function M.input(opts, on_confirm)
  if vim.ui and vim.ui.input then
    return vim.ui.input(opts, on_confirm)
  end
  vim.validate {on_confirm = {on_confirm, 'c'}}

  on_confirm(vim.fn.input(opts))
end

return M
