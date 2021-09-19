local M = {
  default_mode = 'force'
}

---@param root_dir string
function M.update_project_settings(root_dir)
  if not root_dir or type(root_dir) ~= 'string' then
    return nil
  end

  local file = io.open(root_dir..'/nvim-lsp-settings.json', 'r')
  if not file then
    return nil
  end

  local contents = file:read('*a')
  file:close()

  local ok, settings = pcall(vim.fn.json_decode, contents)
  if not ok or type(settings) ~= 'table' then
    return nil
  end
  rawset(M.settings, root_dir, settings)
  return settings
end

---@param client table
---@param opts table
function M.update_client_settings(client, opts)
  local root_dir = client.config.root_dir
  local settings = M.settings[root_dir] and M.settings[root_dir][client.name]
  if not settings then
    return
  end

  local mode = opts and opts.mode or M.default_mode
  if mode ~= 'overwrite' then
    settings = vim.tbl_deep_extend(mode, client.config.settings or {}, settings)
  end
  client.config.settings = settings

  if opts and opts.notify then
    client.notify("workspace/didChangeConfiguration")
  end
end

M.settings = setmetatable({}, {
  __index = function(table, key)
    return rawget(table, key) or M.update_project_settings(key)
  end
})

return M
