local lspconfig = require('lspconfig')
local config = require('lsp-projs.config')
local util = require('lsp-projs.util')

local M = {}

local get_trusted
do
  ---@type table<string, boolean>
  local trusted = {}
  local trust_loaded = false

  function M.load()
    local db = config.trust_store
    local decoded = util.readjson(db) or {}
    if not vim.tbl_islist(decoded) then
      return
    end
    trusted = util.make_set(decoded)
    trust_loaded = true
  end

  function M.clear()
    trusted = {}
    M.save()
  end

  function get_trusted()
    if not trust_loaded then
      M.load()
    end
    return trusted
  end
end

function M.save()
  local db = config.trust_store
  local list = vim.tbl_keys(get_trusted())
  table.sort(list)
  util.writejson(db, list)
end

---@param paths string|string[]|nil
function M.add(paths)
  if not paths then
    paths = {vim.fn.expand('%:p:h')}
  elseif type(paths) == 'string' then
    paths = {paths}
  end
  assert(vim.tbl_islist(paths))

  local dirty = false
  local trusted = get_trusted()
  for _, path in ipairs(paths) do
    path = vim.loop.fs_realpath(path)
    if path and not trusted[path] then
      trusted[path] = true
      dirty = true
    end
  end
  if dirty then
    M.save()
    vim.notify('Marked new directories as trusted.', vim.log.levels.INFO)
  end
end

---@param paths string|string[]
function M.update(paths)
  if type(paths) == 'string' then
    paths = {paths}
  end
  assert(vim.tbl_islist(paths))
  paths = util.make_set(vim.tbl_map(vim.loop.fs_realpath, paths))

  local dirty = false
  local trusted = get_trusted()
  for path, _ in pairs(trusted) do
    if not paths[path] then
      trusted[path] = nil
      dirty = true
    end
  end
  for path, _ in pairs(paths) do
    if not trusted[path] then
      trusted[path] = true
      dirty = true
    end
  end
  if dirty then
    M.save()
    vim.notify('Updated trusted directories.', vim.log.levels.INFO)
  end
end

---@return string[]
function M.list()
  local trusted = get_trusted()
  local result = vim.tbl_keys(trusted)
  table.sort(result)
  return result
end

---@param path string|nil
function M.is_trusted(path)
  if not config.trust_enabled then
    return true
  end
  path = util.get_base_path(path)

  local trusted = get_trusted()
  return lspconfig.util.search_ancestors(path, function(p)
    return trusted[p] == true
  end) ~= nil
end

local trust_asked = {}
---@param path string|nil
function M.check(path)
  if M.is_trusted(path) then
    return true
  end

  path = util.get_base_path(path)
  if trust_asked[path] then
    return false
  end

  local msg = string.format('This file is in an untrusted directory: %q. Do you wish to trust it?', path)
  local result = vim.fn.confirm(msg, '&Yes\n&No', 2) == 1
  pcall(vim.api.nvim_command, 'redraw')
  trust_asked[path] = true
  if result then
    M.add(path)
  end
  return result
end

return M
