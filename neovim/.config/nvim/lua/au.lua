local cmd = vim.api.nvim_command

---@type table<string, function>
local callbacks = {}

---@param fn function
---@return string action
local function register(fn)
  local id = string.format('%p', fn)
  callbacks[id] = fn
  return string.format("lua require('au').run('%s')", id)
end

---@param group string
---@param event string|string[]
---@param pattern string|string[]
---@param action string|function
---@param opts? table
local function nvim_set_autocmd(group, event, pattern, action, opts)
  event = type(event) == 'table' and table.concat(event, ',') or event
  pattern = type(pattern) == 'table' and table.concat(pattern, ',') or pattern
  action = type(action) == 'function' and register(action) or action
  vim.validate {
    group = {group, 'string'},
    event = {event, 'string'},
    patern = {pattern, 'string'},
    action = {action, 'string'},
  }
  local mods = {}
  if opts and opts.once then
    table.insert(mods, '++once')
  end
  if opts and opts.nested then
    table.insert(mods, '++nested')
  end
  mods = table.concat(mods, ' ')
  cmd(string.format('autocmd %s %s %s %s %s', group, event, pattern, mods, action))
end

local function nvim_buf_set_autocmd(buffer, group, event, action, opts)
  buffer = buffer == 0 and '<buffer>' or string.format('<buffer=%d>', buffer)
  nvim_set_autocmd(group, event, buffer, action, opts)
end

---@class AuCmd
---@field group string
---@field event string|string[]
---@field pattern string|string[]
---@field action string
local Command = {}

---@param event string|string[]
---@param spec string|function|table
---@param group? string
function Command.new(event, spec, group)
  event = type(event) == 'table' and table.concat(event, ',') or event
  local is_table = type(spec) == 'table'
  local pattern = is_table and spec[1] or '*'
  pattern = type(pattern) == 'table' and table.concat(pattern, ',') or pattern
  local action = is_table and spec[2] or spec
  if type(action) == 'function' then
    action = register(action)
  end
  local self = setmetatable({group = group, event = event, pattern = pattern, action = action}, { __index = Command })
  self:register()
  return self
end

function Command:clear()
  cmd(string.format('autocmd! %s %s %s %s', self.group, self.event, self.pattern, self.action))
end

function Command:register()
  cmd(string.format('autocmd %s %s %s %s', self.group, self.event, self.pattern, self.action))
end

---@class AuGroup
---@field name string
local Group = {}

---@param name string
---@return AuGroup
function Group.new(name)
  vim.validate {
    name={name, 'string'},
  }
  cmd(string.format('augroup %s', name))
  cmd('augroup END')
  return setmetatable({name = name}, {
    __index = Group,
    __newindex = Group.register,
    __call = Group.register,
  })
end

---@param event? string|string[]
---@param pattern? string|string[]
function Group:clear(event, pattern)
  event = type(event) == 'table' and table.concat(event, ',') or event or '*'
  pattern = type(pattern) == 'table' and table.concat(pattern, ',') or pattern or ''
  cmd(string.format('autocmd! %s %s %s', self.name, event, pattern))
end

---@param event string|string[]
---@param spec string|function|table
function Group:register(event, spec)
  return Command.new(event, spec, self.name)
end

local M = {}

---@param id string
function M.run(id)
  callbacks[id]()
end

---@param name string
---@param cmds? function|table<string, table>
function M.group(name, cmds)
  local grp = Group.new(name)
  if type(cmds) == 'function' then
    cmds(grp)
  elseif type(cmds) == 'table' then
    for _, au in ipairs(cmds) do
      grp:register(au[1], { au[2], au[3] })
    end
  end
  return grp
end

local function autocmd(_, event, spec)
  return Command.new(event, spec)
end

return setmetatable(M, {
  __newindex = autocmd,
  __call = autocmd,
})
