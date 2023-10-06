local M = {}

---@param fn function
---@param timeout? number
local function debounce(fn, timeout)
  local timer = vim.loop.new_timer()
  return function(...)
    local argv = { ... }
    timer:start(timeout or 600, 0, function()
      timer:stop()
      vim.schedule_wrap(fn)(unpack(argv))
    end)
  end
end

M.update_loclist = debounce(function()
  vim.diagnostic.setloclist({ open = false })
end)

M.show_line_diagnostics = debounce(function()
  vim.diagnostic.open_float({ focusable = false })
end)

M.show_references = debounce(function()
  vim.lsp.buf.clear_references()
  vim.lsp.buf.document_highlight()
end)

M.show_code_actions = debounce(function()
  -- local context = {diagnostics = vim.lsp.diagnostic.get_line_diagnostics()}
  -- local params = vim.lsp.util.make_range_params()
  -- params.context = context
  -- vim.lsp.buf_request(0, 'textDocument/codeAction', params, function(err, _, result)
  -- end)
end)

local progress_cache = nil

function M.update_progress()
  local msgs = {}
  for _, msg in ipairs(vim.lsp.util.get_progress_messages()) do
    local name = msg.name
    if msg.progress then
      local contents = { msg.title }
      if msg.message then
        contents[#contents + 1] = msg.message
      end

      if msg.percentage and msg.percentage > 0 then
        contents[#contents + 1] = string.format('(%s%%%%)', math.ceil(msg.percentage))
      end

      if msg.done then
        vim.defer_fn(M.update_progress, 2000)
      end

      msgs[name] = table.concat(contents, ' ')
    else
      msgs[name] = msg.content
    end
  end
  progress_cache = msgs
  vim.cmd.redrawstatus()
end

function M.get_progress()
  if not progress_cache then
    M.update_progress()
  end
  return progress_cache or {}
end

return M
