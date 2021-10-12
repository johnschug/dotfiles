local api = vim.api
local trust = require('lsp-projs.trust')

local M = {}

local buf

local function buf_set_autocmd(bufnr, event, cmd)
  api.nvim_command(string.format('autocmd %s <buffer=%d> %s', event, bufnr, cmd))
end

function M.open()
  if not buf or buf == 0 then
    buf = api.nvim_create_buf(false, false)
    assert(buf ~= 0, 'buffer creation failed')

    buf_set_autocmd(buf, 'BufReadCmd', "lua require('lsp-projs.edit').update(true)")
    buf_set_autocmd(buf, 'BufWriteCmd', "lua require('lsp-projs.edit').save()")

    api.nvim_buf_set_option(buf, 'buftype', 'acwrite')
    api.nvim_buf_set_option(buf, 'modeline', false)
    api.nvim_buf_set_option(buf, 'swapfile', false)
    api.nvim_buf_set_option(buf, 'undofile', false)
    api.nvim_buf_set_name(buf, 'TRUSTED')
  end
  api.nvim_set_current_buf(buf)
  M.update()
end

local escape, unescape
do
  local cmap = {
    {['%'] = '%%', ['\n'] = '%\\n'},
    {['%%'] = '%', ['%\\n'] = '\n'},
  }
  escape = function(str)
    local res = str:gsub('.', cmap[1])
    return res
  end

  unescape = function(str)
    local res = str:gsub('%%.', cmap[2])
    return res
  end
end

---@param force boolean|nil
function M.update(force)
  if not buf or not api.nvim_buf_is_loaded(buf) then
    return
  end
  if not force and api.nvim_buf_get_option(buf, 'modified') then
    return
  end

  api.nvim_buf_set_option(buf, 'undolevels', -1)
  api.nvim_buf_set_lines(buf, 0, -1, false, vim.tbl_map(escape, trust.list()))
  api.nvim_buf_set_option(buf, 'modified', false)
  -- BUG(neovim#14670, neovim#15587): the neovim api sets the wrong value when clearing a buf/win local option
  -- use the default unset value as a workaround
  api.nvim_buf_set_option(buf, 'undolevels', -123456)
end

function M.save()
  if not buf or not api.nvim_buf_is_loaded(buf)
    or api.nvim_buf_get_option(buf, 'modified') == 0 then
    return
  end

  local paths = api.nvim_buf_get_lines(buf, 0, -1, false)
  paths = vim.tbl_map(unescape, paths)
  trust.update(paths)

  api.nvim_buf_set_option(buf, 'modified', false)
end

return M
