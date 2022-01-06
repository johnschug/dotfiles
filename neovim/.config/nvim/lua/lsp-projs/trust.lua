local lspconfig = require('lspconfig')
local config = require('lsp-projs.config')
local util = require('lsp-projs.util')

local M = {}

local trust_store = {
  loaded = false,
  dirty = false,
  paths = {},
}

function trust_store:ensure_loaded()
  if not self.loaded then
    self:load()
  end
end

function trust_store:get()
  self:ensure_loaded()
  return self.paths
end

function trust_store:clear()
  self:ensure_loaded()
  if not vim.tbl_isempty(self.paths) then
    self.paths = {}
    self.dirty = true
  end
end

function trust_store:add(path)
  self:ensure_loaded()
  path = vim.loop.fs_realpath(path)
  if path and not self.paths[path] then
    self.paths[path] = true
    self.dirty = true
  end
end

function trust_store:remove(path)
  self:ensure_loaded()
  if path and self.paths[path] then
    self.paths[path] = nil
    self.dirty = true
  end

  path = vim.loop.fs_realpath(path)
  if path and self.paths[path] then
    self.paths[path] = nil
    self.dirty = true
  end
end

function trust_store:load()
  local db = config.trust_store
  local decoded = util.readjson(db) or {}
  if not vim.tbl_islist(decoded) then
    return
  end
  self.paths = util.make_set(decoded)
  self.loaded = true
  self.dirty = false
end

function trust_store:save(force)
  self:ensure_loaded()
  if not self.dirty and not force then
    return
  end

  local db = config.trust_store
  local trusted = vim.tbl_keys(self.paths)
  table.sort(trusted)
  util.writejson(db, trusted)
  self.dirty = false

  vim.notify('Trusted directories updated.', vim.log.levels.INFO)
end

M.load = function() trust_store:load() end
M.save = function(force) trust_store:save(force) end

function M.clear()
  trust_store:clear()
  M.save()
end

---@vararg string|string[]
function M.add(...)
  local paths = vim.tbl_flatten({...})
  for _, path in ipairs(paths) do
    trust_store:add(path)
  end
  M.save()
end

---@vararg string|string[]
function M.remove(...)
  local paths = vim.tbl_flatten({...})
  for _, path in ipairs(paths) do
    trust_store:remove(path)
  end
  M.save()
end

---@vararg string|string[]
function M.update(...)
  local paths = vim.tbl_flatten({...})
  paths = util.make_set(vim.tbl_map(vim.loop.fs_realpath, paths))
  local trusted = trust_store:get()
  for path, _ in pairs(trusted) do
    if not paths[path] then
      trusted[path] = nil
      trust_store.dirty = true
    end
  end
  for path, _ in pairs(paths) do
    if path and not trusted[path] then
      trusted[path] = true
      trust_store.dirty = true
    end
  end
  M.save()
end

---@return string[]
function M.list()
  local result = vim.tbl_keys(trust_store:get())
  table.sort(result)
  return result
end

---@param path string
function M.is_trusted(path)
  if not config.trust_enabled then
    return true
  end
  path = vim.loop.fs_realpath(path)
  if not path then
    return false
  end

  local trusted = trust_store:get()
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

  path = vim.loop.fs_realpath(path)
  if not path or trust_asked[path] then
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
