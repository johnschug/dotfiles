local M = {}

---@param timeout number
---@param fn function
local function debounce(timeout, fn)
  local timer = vim.loop.new_timer()
  return function(...)
    local argv = {...}
    timer:start(timeout, 0, function()
      timer:stop()
      vim.schedule_wrap(fn)(unpack(argv))
    end)
  end
end

local default_debounce = 600
M.update_loclist = debounce(default_debounce, function()
  vim.lsp.diagnostic.set_loclist({open_loclist = false})
end)

M.show_references = debounce(default_debounce, function()
  vim.lsp.buf.clear_references()
  vim.lsp.buf.document_highlight()
end)

M.show_code_actions = debounce(default_debounce, function()
  -- local context = {diagnostics = vim.lsp.diagnostic.get_line_diagnostics()}
  -- local params = vim.lsp.util.make_range_params()
  -- params.context = context
  -- vim.lsp.buf_request(0, 'textDocument/codeAction', params, function(err, _, result)
  -- end)
end)

M.show_line_diagnostics = debounce(default_debounce, function()
  vim.lsp.diagnostic.show_line_diagnostics({focusable = false})
end)

local clients = {}
local progress = {}

local function progress_callback(...)
  local msg = select(3, ...)
  local client_id = select(4, ...)
  if type(client_id) ~= 'number' then
    msg = select(2, ...)
    client_id = select(3, ...).client_id
  end

  if not clients[client_id] then
    clients[client_id] = {}
  end

  local val = msg.value
  if val and val.kind then
    progress = vim.tbl_filter(function(x) return x.client_id ~= client_id or x.token ~= msg.token end, progress)
    if val.kind == 'begin' then
      local server = vim.lsp.get_client_by_id(client_id).name
      clients[client_id][msg.token] = {
        client_id = client_id,
        server = server,
        token = msg.token,
        title = val.title,
        message = val.message,
        percentage = val.percentage,
      }
      table.insert(progress, clients[client_id][msg.token])
    elseif val.kind == 'end' then
      clients[client_id][msg.token] = nil
      if vim.tbl_isempty(clients[client_id]) then
        clients[client_id] = nil
      end
    elseif val.kind == 'report' and clients[client_id][msg.token] then
      clients[client_id][msg.token].message = val.message
      clients[client_id][msg.token].percentage = val.percentage
      table.insert(progress, clients[client_id][msg.token])
    end
  end
  vim.cmd [[doautocmd <nomodeline> User LspProgressUpdated]]
end

function M.register_progress()
  vim.lsp.handlers['$/progress'] = progress_callback
end

function M.get_progress()
  return vim.deepcopy(progress)
end

return M
