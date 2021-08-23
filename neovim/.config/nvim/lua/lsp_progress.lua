local clients = {}
local progress = {}

local function progress_callback(_, _, msg, client_id)
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

local function register_progress()
  vim.lsp.handlers['$/progress'] = progress_callback
end

local function get_progress()
  return vim.deepcopy(progress)
end

local M = {
  register_progress = register_progress,
  get_progress = get_progress,
}

return M
