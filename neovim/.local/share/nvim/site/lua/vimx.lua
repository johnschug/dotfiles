local api = vim.api

---@class vimx.Pos
---@field [1] integer
---@field [2] integer

---@alias vimx.Attrs table<string, vimx.Attr>

---@class vimx.Attr
---@field get? function
---@field set? function

---@param attrs vimx.Attrs
---@param statics vimx.Attrs
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
      return init(mt, ...)
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

---@type vimx.Attrs
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

---@class vimx.Buf
---@field id integer
---@field is_valid boolean
---@field is_loaded boolean
---@field name string
---@field line_count integer
---@field changedtick integer
---@field mark table<string, integer[]>
---@field opt table<string, any>
---@field var table<string, any>
---@field current vimx.Buf|integer
---@field list vimx.Buf[]
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
}, function(mt, id)
  return setmetatable({id = id}, mt)
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

---@type vimx.Attrs
local win_attrs = {
  -- properties
  is_valid = {get = unwrap(api.nvim_win_is_valid)},
  width = {get = unwrap(api.nvim_win_get_width), set = unwrap(api.nvim_win_set_width)},
  height = {get = unwrap(api.nvim_win_get_height), set = unwrap(api.nvim_win_set_height)},
  cursor = {get = unwrap(api.nvim_win_get_cursor), set = unwrap(api.nvim_win_set_cursor)},
  position = {get = unwrap(api.nvim_win_get_position)},
  config = {get = unwrap(api.nvim_win_get_config), set = unwrap(api.nvim_win_set_config)},
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

---@class vimx.Win
---@field is_valid boolean
---@field id integer
---@field width integer
---@field height integer
---@field cursor vimx.Pos
---@field position vimx.Pos
---@field config table
---@field buf vimx.Buf|integer
---@field opt table<string, any>
---@field var table<string, any>
---@field current vimx.Win|integer
---@field list vimx.Win[]
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
}, function(mt, id)
  return setmetatable({id = id}, mt)
end)

---@type vimx.Attrs
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

---@class vimx.TabPage
---@field is_valid boolean
---@field id integer
---@field win vimx.Win
---@field wins vimx.Win[]
---@field var table<string, any>
---@field current vimx.TabPage|integer
---@field list vimx.TabPage[]
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
}, function(mt, id)
  return setmetatable({id = id}, mt)
end)

return M
