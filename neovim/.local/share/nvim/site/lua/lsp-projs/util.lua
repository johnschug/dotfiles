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

---@param path string|nil
---@return string|nil
function M.get_base_path(path)
  if path then
    return assert(vim.loop.fs_realpath(path))
  else
    local result = vim.fn.expand('%:p:h')
    if #result ~= 0 then
      return result
    end
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
  file:close()
  assert(ok, err)
end

---@param path string
---@param contents table
function M.writejson(path, contents)
  M.writefile(path, vim.fn.json_encode(contents))
end

return M
