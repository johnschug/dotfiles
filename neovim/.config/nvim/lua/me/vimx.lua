local api = vim.api

---@class vimx.pos
---@field [1] integer
---@field [2] integer

---@alias vimx.attrs table<string, vimx.attr>

---@class vimx.attr
---@field get? function
---@field set? function

---@param attrs vimx.attrs
---@param statics vimx.attrs
---@param init function
---@return table
local function make_class(attrs, statics, init)
  local mt = {
    __index = function(self, key)
      local attr = attrs[key]
      if attr and attr.get then
        return attr.get(self)
      end
    end,
    __newindex = function(self, key, val)
      local attr = attrs[key]
      if attr and attr.set then
        attr.set(self, val)
      end
    end,
  }
  local cls = {
    __call = function(_, ...)
      return setmetatable(init(...), mt)
    end,
    __index = function(self, key)
      local attr = statics[key] or attrs[key]
      if attr and attr.get then
        return attr.get(self)
      end
    end,
    __newindex = function(self, key, val)
      local attr = statics[key] or attrs[key]
      if attr and attr.set then
        attr.set(self, val)
      end
    end
  }
  return setmetatable({}, cls)
end

---@generic T
---@param f fun(id: integer): T
---@return fun(self: table): T
local function unwrap(f)
  return function(self, ...)
    return f(self.id or 0, ...)
  end
end

local M = {}

---@type vimx.attrs
local buf_attrs = {
  -- properties
  is_valid = {get = unwrap(api.nvim_buf_is_valid)},
  is_loaded = {get = unwrap(api.nvim_buf_is_loaded)},
  name = {get = unwrap(api.nvim_buf_get_name), unwrap(api.nvim_buf_set_name)},
  line_count = {get = unwrap(api.nvim_buf_line_count)},
  changedtick = {get = unwrap(api.nvim_buf_get_changedtick)},
  mark = {get = function(buf)
    return setmetatable({}, {
      __index = function(_, key)
        return api.nvim_buf_get_mark(buf.id, key)
      end,
    })
  end},
  wins = {get = function(buf)
    return vim.tbl_map(M.win, vim.fn.win_findbuf(buf.id))
  end},
  opt = {get = function(buf)
    return vim.bo[buf.id or 0]
  end},
  var = {get = function(buf)
    return setmetatable({}, {
      __index = function(_, key)
        return api.nim_buf_set_var(buf.id or 0, key)
      end,
      __newindex = function(_, key, val)
        if not val then
          api.nvim_buf_del_var(buf.id or 0, key)
        else
          api.nvim_buf_set_var(buf.id or 0, key, val)
        end
      end,
    })
  end},
  -- methods
  apply = {get = function(buf)
    return function(f)
      return api.nvim_buf_call(buf.id or 0, f)
    end
  end},
  delete = {get = function(buf)
    return function(opts)
      api.nvim_buf_delete(buf.id or 0, opts or {})
    end
  end},
}

---@class vimx.buf
---@field id integer
---@field is_valid boolean
---@field is_loaded boolean
---@field name string
---@field line_count integer
---@field changedtick integer
---@field mark table<string, integer[]>
---@field opt table<string, any>
---@field var table<string, any>
---@field current vimx.buf|integer
---@field list vimx.buf[]
---@field apply fun(f: function): any
---@field delete fun(opts: table)
M.buf = make_class(buf_attrs, {
  current = {
    get = function()
      return M.buf(api.nvim_get_current_buf())
    end,
    set = function(_, buf)
      buf = (type(buf) == 'number') and buf or buf.id
      api.nvim_set_current_buf(buf)
    end,
  },
  list = {get = function()
    return vim.tbl_map(M.buf, api.nvim_list_bufs())
  end},
  create = {
    get = function()
      return function(listed, scratch)
        local id = api.nvim_create_buf(listed, scratch)
        return (id ~= 0) and M.buf(id) or nil
      end
    end,
  },
}, function(id)
  return {id = id}
end)

-- ---@param ns? integer
-- ---@param line_start? integer
-- ---@param line_end? integer
-- function M.buf:clear_namespace(ns, line_start, line_end)
--   local id = self and self.id or 0
--   api.nvim_buf_clear_namespace(id, ns or -1, line_start or 0, line_end or -1)
-- end
--
-- function M.buf:get_lines(line_start, line_end, strict)
--   local id = self and self.id or 0
--   api.nvim_buf_get_lines(id, line_start or 0, line_end or -1, strict or false)
-- end
--
-- function M.buf:set_lines(line_start, line_end, strict, val)
--   local id = self and self.id or 0
--   api.nvim_buf_set_lines(id, line_start or 0, line_end or -1, strict or false, val)
-- end

---@type vimx.attrs
local win_attrs = {
  -- properties
  is_valid = {get = unwrap(api.nvim_win_is_valid)},
  width = {get = unwrap(api.nvim_win_get_width), set = unwrap(api.nvim_win_set_width)},
  height = {get = unwrap(api.nvim_win_get_height), set = unwrap(api.nvim_win_set_height)},
  cursor = {get = unwrap(api.nvim_win_get_cursor), set = unwrap(api.nvim_win_set_cursor)},
  position = {get = unwrap(api.nvim_win_get_position)},
  config = {get = unwrap(api.nvim_win_get_config), set = unwrap(api.nvim_win_set_config)},
  type = {get = unwrap(vim.fn.win_gettype)},
  buf = {
    get = function(win)
      return M.buf(api.nvim_win_get_buf(win.id or 0))
    end,
    set = function(win, buf)
      buf = (type(buf) == 'number') and buf or buf.id
      api.nvim_win_set_buf(win.id or 0, buf)
    end,
  },
  opt = {get = function(win)
    return vim.wo[win.id or 0]
  end},
  var = {get = function(win)
    return setmetatable({}, {
      __index = function(_, key)
        return api.nvim_win_get_var(win.id or 0, key)
      end,
      __newindex = function(_, key, val)
        if not val then
          api.nvim_win_del_var(win.id or 0, key)
        else
          api.nvim_win_set_var(win.id or 0, key, val)
        end
      end,
    })
  end},
  -- methods
  apply = {get = function(win)
    return function(f)
      return api.nvim_win_call(win.id or 0, f)
    end
  end},
  hide = {get = function(win)
    return function()
      api.nvim_win_hide(win.id or 0)
    end
  end},
  close = {get = function(win)
    return function(force)
      api.nvim_win_close(win.id or 0, force or true)
    end
  end},
}

---@class vimx.win
---@field is_valid boolean
---@field id integer
---@field width integer
---@field height integer
---@field cursor vimx.pos
---@field position vimx.pos
---@field config table
---@field buf vimx.buf|integer
---@field opt table<string, any>
---@field var table<string, any>
---@field current vimx.win|integer
---@field list vimx.win[]
---@field apply fun(f: function): any
---@field hide fun()
---@field close fun(force: boolean)
M.win = make_class(win_attrs, {
  current = {
    get = function()
      return M.win(api.nvim_get_current_win())
    end,
    set = function(_, win)
      win = (type(win) == 'number') and win or win.id
      api.nvim_set_current_win(win)
    end,
  },
  list = {get = function()
    return vim.tbl_map(M.win, api.nvim_list_wins())
  end},
}, function(id)
  return {id = id}
end)

---@type vimx.attrs
local tab_attrs = {
  -- properties
  is_valid = {get = unwrap(api.nvim_tabpage_is_valid)},
  win = {get = function(tab)
    return M.win(api.nvim_tabpage_get_win(tab.id or 0))
  end},
  wins = {get = function(tab)
    return vim.tbl_map(M.win, api.nvim_tabpage_list_wins(tab.id or 0))
  end},
  var = {get = function(tab)
    return setmetatable({}, {
      __index = function(_, key)
        return api.nvim_tabpage_get_var(tab.id or 0, key)
      end,
      __newindex = function(_, key, val)
        if not val then
          api.nvim_tabpage_del_var(tab.id or 0, key)
        else
          api.nvim_tabpage_set_var(tab.id or 0, key, val)
        end
      end,
    })
  end},
}

---@class vimx.tabpage
---@field is_valid boolean
---@field id integer
---@field win vimx.win
---@field wins vimx.win[]
---@field var table<string, any>
---@field current vimx.tabpage|integer
---@field list vimx.tabpage[]
M.tabpage = make_class(tab_attrs, {
  current = {
    get = function()
      return M.tabpage(api.nvim_get_current_tabpage())
    end,
    set = function(_, tab)
      tab = (type(tab) == 'number') and tab or tab.id
      api.nvim_set_current_tabpage(tab)
    end,
  },
  list = {get = function()
    return vim.tbl_map(M.tabpage, api.nvim_list_tabpages())
  end},
}, function(id)
  return {id = id}
end)

return M
