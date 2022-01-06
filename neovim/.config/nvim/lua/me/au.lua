local cmd = vim.api.nvim_command

local mod_name = ...

---@type table<string, function>
local callbacks = {}

---@param fn function
---@return string action
local function register(fn)
  local id = string.format('%p', fn)
  callbacks[id] = fn
  return string.format("lua require('%s').run('%s')", mod_name, id)
end

local function autocmd(group, events, patterns, opts, action)
  group = group or ''
  events = type(events) == 'table' and table.concat(events, ',') or events or '*'
  patterns = type(patterns) == 'table' and table.concat(patterns, ',') or patterns
  action = type(action) == 'function' and register(action) or action
  vim.validate {
    group = {group, 'string'},
    events = {events, 'string'},
    patterns = {patterns, 'string'},
    action = {action, 'string', true},
  }
  local mods = {}
  if opts and opts.once then
    table.insert(mods, '++once')
  end
  if opts and opts.nested then
    table.insert(mods, '++nested')
  end
  mods = table.concat(mods, ' ')
  return group, events, patterns, mods, action
end

---@param group string|nil
---@param events? string|string[]
---@param patterns? string|string[]
---@param mods? table
local function nvim_del_autocmd(group, events, patterns, mods)
  group, events, patterns, mods = autocmd(group, events, patterns or '', mods, nil)
  cmd(string.format('autocmd! %s %s %s %s', group, events, patterns, mods))
end

---@param group? string
---@param events? string|string[]
---@param patterns? string|string[]
---@param action string|function
---@param mods? table
local function nvim_set_autocmd(group, events, patterns, action, mods)
  group, events, patterns, mods, action = autocmd(group, events, patterns or '*', mods, assert(action))
  cmd(string.format('autocmd %s %s %s %s %s', group, events, patterns, mods, action))
end

-- local function nvim_buf_set_autocmd(buffer, group, events, action, mods)
--   buffer = buffer == 0 and '<buffer>' or string.format('<buffer=%d>', buffer)
--   nvim_set_autocmd(group, events, buffer, action, mods)
-- end

---@class AutoCmd
---@field info table
local AutoCmd = {}

local mt = {
  __index = function(self, key)
    return AutoCmd[key] or AutoCmd.get(self, key)
  end,
  __newindex = function(self, key, val)
    if not val then
      AutoCmd.clear(AutoCmd.get(self, key))
    else
      AutoCmd.subscribe(AutoCmd.get(self, key), val)
    end
  end,
  __call = AutoCmd.get,
}

---@param init? table
---@param group? string
---@return AutoCmd
function AutoCmd.new(init, group)
  init = init or {}
  init.info = {group = group}
  return setmetatable(init, mt)
end

---@vararg string|table
---@return AutoCmd
function AutoCmd:get(item)
  local new = AutoCmd.new(nil, self.info.group)
  new.info.events, new.info.patterns = self.info.events, self.info.patterns
  if not new.info.events then
    new.info.events = item
  elseif not new.info.patterns then
    new.info.patterns = item
  elseif not new.info.mods then
    new.info.mods = item
  else
    error(string.format("unexpected item '%s'", item))
  end
  return new
end

function AutoCmd:clear()
  nvim_del_autocmd(self.info.group, self.info.events, self.info.patterns, self.info.mods)
end

---@param action string|function
---@return function unsubscriber
function AutoCmd:subscribe(action)
  nvim_set_autocmd(self.info.group, self.info.events, self.info.patterns, action, self.info.mods)
  return function()
    self.clear(action)
  end
end

---@class Au : AutoCmd
---@field group function
---@field run function
local M = AutoCmd.new({
  ---@param name string
  ---@return AutoCmd
  group = function(name)
    cmd(string.format('augroup %s | augroup END', name))
    return AutoCmd.new({}, name)
  end,
  ---@param id string
  run = function(id)
    callbacks[id]()
  end,
})

return M
