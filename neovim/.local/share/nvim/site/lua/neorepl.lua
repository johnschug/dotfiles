local api = vim.api

local M = {}

M.config = {
  repls = {
    shell = {
      exe = vim.o.shell,
    },
    sh = {},
    bash = {},
    zsh = {},
    fish = {},
    irb = {},
    node = {},
    bpython = {},
    ipython = {},
    python = {},
    python2 = {},
    python3 = {},
    ocaml = {},
    utop = {},
    ghci = {},
    stack = { args = {'ghci'}},
    scala = {},
  },
  filetpes = {
    sh = 'sh',
    bash = 'bash',
    zsh = 'zsh',
    fish = 'fish',
    ruby = 'irb',
    javascript = 'node',
    python = {'bpython', 'ipython', 'python', 'python3', 'python2'},
    ocaml = {'utop', 'ocaml'},
    haskell = {'stack', 'ghci'},
  },
  default = 'shell',
  window = '15new',
}

---@class ReplTemplate
---@field exe string
---@field args string[]
---@field transform? function
local template = {}

local function open_win()
  api.nvim_command('silent '..M.config.window)
  vim.wo.winfixwidth = true
  vim.wo.winfixheight = true
  vim.bo.spell = false
  return api.nvim_get_current_win()
end

---@class NeoRepl
local active = {}

---@param name string
---@return Repl
function active.find(name)
  for _, repl in pairs(active) do
    if repl.name == name then
      return repl
    end
  end
end

---@class Repl : ReplTemplate
---@field name string
---@field type string
---@field cmd string
---@field buf number
---@field id number
local Repl = {}

---@param templ ReplTemplate
---@return Repl
function Repl.new(templ)
  local repl = setmetatable(vim.deepcopy(templ), {__index = Repl})
  repl.cmd = vim.deepcopy(repl.args)
  table.insert(repl.cmd, 0, repl.exe)
  repl.on_exit = function()
    repl:stop()
  end
  return repl
end

function Repl:stop()
  if self.id then
    vim.fn.jobstop(self.id)
  end
  if self.buf then
    if api.nvim_buf_is_valid(self.buf) then
      api.nvim_buf_delete(self.buf, {force = true})
    end
    active[self.buf] = nil
  end
end

function Repl:open()
  if self.buf and api.nvim_buf_is_valid(self.buf) then
    return
  end

  self.buf = api.nvim_create_buf(false, false)
  api.nvim_set_current_buf(self.buf)
  vim.bo.bufhidden = 'wipe'

  self.id = vim.fn.termopen(self.cmd, self)
  active[self.buf] = self

  local title = 'repl://'..vim.fn.fnameescape(self.type)
  if self.name ~= self.type then
    title = string.format('%s (%s)', title, vim.fn.fnameescape(self.name))
  end
  api.nvim_buf_set_name(self.buf, title)
  self:scroll()
end

function Repl:show()
  local win = vim.t.neorepl_win
  if not win or not api.nvim_win_is_valid(win) then
    win = open_win()
    vim.t.neorepl_win = win
  else
    api.nvim_set_current_win(win)
  end

  if not self.buf or not api.nvim_buf_is_valid(self.buf) then
    self:open()
  else
    api.nvim_set_current_buf(self.buf)
  end

  vim.t.neorepl_last = self.buf
  api.nvim_command('silent doautocmd <nomodeline> User NeoReplOpen')
end

function Repl:scroll()
  if not self.buf or api.nvim_win_get_buf(0) ~= self.buf then
    return
  end
  local last = api.nvim_buf_line_count(self.buf)
  api.nvim_win_set_cursor(0, {last, 0})
end

---@param lines string|string[]
function Repl:send(lines)
  if not self.id then
    return
  end

  local data
  if type(self.transform) == 'function' then
    data = self.transform(lines)
  else
    lines = vim.deepcopy(lines)
    table.insert(lines, '')
    data = lines
  end

  api.nvim_chan_send(self.id, data)
  self:scroll()
end

M._dump = function()
  print(vim.inspect(active))
end

M.get_repl = function(name, base)
  base = base or name
  if not name or name == '' then
    return
  end

  local templ = M.config.repls[base]
  if templ then
    templ = vim.deepcopy(templ)
    templ.name = name
    templ.type = base
    templ.exe = template.exe or name
    templ.args = template.args or {}
  end
  return templ
end

---@param name string|nil
---@param base string|nil
---@return Repl
M.open = function(name, base)
  name = name or ''
  base = base or name
  local ft = vim.bo.filetype
  local templ

  if base ~= '' then
    local repl = active.find(name)
    if repl and repl:show() then
      return repl
    end

    templ = M.get_repl(name, base)
    if not templ or (vim.fn.executable(templ.exe) == 0) then
      return
    end
  else
    local templs = M.config.filetypes[ft]
    for _, ty in templs do
      local repl = active.find(ty)
      if repl then
        repl:show()
        return repl
      end
    end
  end

  if templ then
    local repl = Repl.new(templ)
    repl:show()
    return repl
  end
end

M.open_last = function()
  local repl = vim.t.neorepl_last and active[vim.t.neorepl_last]
  if repl then
    repl:show()
    return repl
  end
end

M.close = function()
  local win = vim.t.neorepl_win
  if not win or not api.nvim_win_is_valid(win) then
    return
  end
  api.nvim_win_close(win, true)
  api.nvim_command('silent doautocmd <nomodeline> User NeoReplClose')
end

---@vararg string
M.stop = function(...)
  local names = table.pack(...)
  names = vim.tbl_filter(function (name)
    return type(name) == 'string' and name ~= ''
  end, names)

  if vim.tbl_isempty(names) then
    for _, repl in vim.deepcopy(active) do
      repl:stop()
    end
  else
    for _, repl in vim.deepcopy(active) do
      if vim.tbl_contains(names, repl.name) then
        repl:stop()
      end
    end
  end
end

---@param name? string
---@return Repl
M.reset = function(name)
  M.stop(name)
  return M.open(name)
end

---@param lines string|string[]
M.send = function(lines, ...)
  local repl = M.open(...)
  if not repl then
    return
  end

  repl:send(lines)
end

return M
