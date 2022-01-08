local api = vim.api
local M = {}

local mod_name = ...

local callbacks = {}

function M.register_callback(f)
  local id = string.format('%p', f)
  callbacks[id] = f
  return string.format("lua require('%s').run('%s')", mod_name, id)
end

function M.run(id)
  callbacks[id]()
end

local keymap = {}
function keymap.set(modes, lhs, rhs, opts)
  vim.validate {
    lhs = {lhs, 's'},
    opts = {opts, 't', true},
  }

  opts = vim.deepcopy(opts) or {}
  modes = type(modes) == 'string' and {modes} or modes
  local is_rhs_luaref = type(rhs) == 'function'

  if is_rhs_luaref and opts.expr and opts.replace_keycodes ~= false then
    local user_rhs = rhs
    rhs = function()
      return api.nvim_replace_termcodes(user_rhs(), true, true, true)
    end
  end
   -- clear replace_keycodes from opts table
  opts.replace_keycodes = nil

  if opts.remap == nil then
    -- remap by default on <plug> mappings and don't otherwise.
    opts.noremap = is_rhs_luaref or rhs:lower():match("^<plug>") == nil
  else
    -- remaps behavior is opposite of noremap option.
    opts.noremap = not opts.remap
    opts.remap = nil
  end

  if is_rhs_luaref then
    rhs = M.register_callback(rhs)
  end

  if opts.buffer then
    local bufnr = opts.buffer == true and 0 or opts.buffer
    opts.buffer = nil
    for _, m in ipairs(modes) do
      api.nvim_buf_set_keymap(bufnr, m, lhs, rhs, opts)
    end
  else
    opts.buffer = nil
    for _, m in ipairs(modes) do
      api.nvim_set_keymap(m, lhs, rhs, opts)
    end
  end
end

function keymap.del(modes, lhs, opts)
  vim.validate {
    lhs = {lhs, 's'},
    opts = {opts, 't', true},
  }

  opts = opts or {}
  modes = type(modes) == 'string' and {modes} or modes

  local buffer = false
  if opts.buffer ~= nil then
    buffer = opts.buffer == true and 0 or opts.buffer
  end

  if buffer == false then
    for _, mode in ipairs(modes) do
      api.nvim_del_keymap(mode, lhs)
    end
  else
    for _, mode in ipairs(modes) do
      api.nvim_buf_del_keymap(buffer, mode, lhs)
    end
  end
end

M.keymap = vim.keymap or keymap

return M
