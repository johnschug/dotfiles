---@alias LspProjsMergeMode "'force'"|"'keep'"|"'error'"|"'overwrite'"

---@class LspProjsConfig
local defaults = {
  settings_file = 'nvim-lsp-settings.json',
  ---@type LspProjsMergeMode
  settings_merge_mode = 'force',
  trust_enabled = true,
  trust_store = vim.fn.stdpath('data')..'/lsp-proj-trusted.json'
}

---@type LspProjsConfig
local M = {}

---@type LspProjsConfig
M.defaults = vim.deepcopy(defaults)

---@param cfg? LspProjsConfig
function M.update(cfg)
  if type(cfg) ~= 'table' then
    return
  end

  for k, _ in pairs(defaults) do
    M[k] = cfg[k]
  end
end

setmetatable(M, {
  __index = defaults,
})

return M
