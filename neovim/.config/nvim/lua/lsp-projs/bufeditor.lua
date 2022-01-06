local api = vim.api
local lspconfig = require('lspconfig')
local trust = require('lsp-projs.trust')
local util = require('lsp-projs.util')

local M = {}

local root_buf
local control_buf
local control_win
local root_dirs

local ns = api.nvim_create_namespace('lsp_trust_status')

local function check_root_buf()
  if not api.nvim_buf_is_valid(root_buf) or root_buf == 0 then
    return false
  end

  local buftype = api.nvim_buf_get_option(root_buf, 'buftype')
  local bufft = api.nvim_buf_get_option(root_buf, 'filetype')
  if buftype ~= '' or not bufft or #bufft == 0 then
    return false
  end
  return true
end

function M.open(bufnr)
  root_buf = bufnr or api.nvim_get_current_buf()
  if not check_root_buf() then
    return
  end

  if not api.nvim_buf_is_valid(root_buf) or root_buf == 0 then
    return
  end

  if not control_buf or not api.nvim_buf_is_valid(control_buf) or control_buf == 0 then
    control_buf = api.nvim_create_buf(false, true)
    assert(control_buf ~= 0, 'buffer creation failed')

    util.buf_set_autocmd(control_buf, 'BufWinLeave', "lua require('lsp-projs.bufeditor').close()")
    util.buf_set_autocmd(control_buf, 'BufReadCmd', "lua require('lsp-projs.bufeditor').update()")

    api.nvim_buf_set_option(control_buf, 'buftype', 'nofile')
    api.nvim_buf_set_option(control_buf, 'bufhidden', 'wipe')
    api.nvim_buf_set_option(control_buf, 'modifiable', false)
    api.nvim_buf_set_option(control_buf, 'swapfile', false)
    api.nvim_buf_set_option(control_buf, 'undofile', false)
    api.nvim_buf_set_name(control_buf, 'WORKSPACE TRUST STATUS')

    api.nvim_buf_set_keymap(control_buf, 'n', '<CR>', "<Cmd>lua require('lsp-projs.bufeditor').toggle_trust()<CR>", {noremap = true, silent = true})
  end
  if not control_win or not api.nvim_win_is_valid(control_win) or control_win == 0 then
    api.nvim_command(string.format('sbuffer %d', control_buf))
    control_win = api.nvim_get_current_win()
    api.nvim_win_set_option(control_win, 'cursorcolumn', false)
    api.nvim_win_set_option(control_win, 'cursorline', true)
  else
    api.nvim_win_set_buf(control_win, control_buf)
    api.nvim_set_current_win(control_win)
  end
  M.update()
end

function M.close()
  vim.schedule(function()
    if control_win ~= 0 and api.nvim_win_is_valid(control_win) then
      api.nvim_win_close(control_win, true)
    end
    control_win = nil
    if control_buf ~= 0 and api.nvim_buf_is_valid(control_buf) then
      api.nvim_buf_delete(control_buf, {force = true})
    end
    control_buf = nil
  end)
end

function M.update()
  if not check_root_buf() then
    return
  end

  local roots = {}
  local add_server_root = function(cfg)
    local root_dir = cfg.get_root_dir(api.nvim_buf_get_name(root_buf), root_buf)
    if type(root_dir) == 'string' and #root_dir > 0 then
      roots[root_dir] = true
    end
  end

  local bufft = api.nvim_buf_get_option(root_buf, 'filetype')
  for _, server in pairs(lspconfig.available_servers()) do
    local cfg = lspconfig[server]
    if cfg.filetypes then
      for _, ft in ipairs(cfg.filetypes) do
        if ft == bufft then
          add_server_root(cfg)
        end
      end
    end
  end

  root_dirs = vim.tbl_keys(roots)
  table.sort(root_dirs)

  api.nvim_buf_clear_namespace(control_buf, ns, 0, -1)
  api.nvim_buf_set_option(control_buf, 'modifiable', true)
  api.nvim_buf_set_lines(control_buf, 0, -1, true, root_dirs)
  api.nvim_buf_set_option(control_buf, 'modifiable', false)

  local msg = {[false] = {'Untrusted', 'ErrorMsg'}, [true] = {'Trusted'}}
  for i, root in ipairs(root_dirs) do
    local trusted = trust.is_trusted(root)
    api.nvim_buf_set_virtual_text(control_buf, ns, i - 1, {msg[trusted]}, {})
  end
end

local function add_trust(root_dir)
  if trust.is_trusted(root_dir) then
    return
  end

  local on_confirm = function(choice)
    api.nvim_command('redraw')
    if choice and #choice > 0 then
      trust.add(choice)
    end
  end

  util.input({
    prompt = 'Add trusted directory: ',
    default = root_dir,
    completion = 'dir',
    cancelreturn = nil,
  }, on_confirm)
end

function M.toggle_trust()
  if not api.nvim_win_is_valid(control_win)
    or api.nvim_get_current_win() ~= control_win
    or api.nvim_win_get_buf(control_win) ~= control_buf then
    return
  end

  local choice = api.nvim_get_current_line()
  if not choice or #choice == 0 then
    return
  end

  if trust.is_trusted(choice) then
    trust.remove(choice)
  else
    add_trust(choice)
  end

  M.update()
end

return M
