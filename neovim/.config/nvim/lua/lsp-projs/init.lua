local lspconfig = require('lspconfig')
local config = require('lsp-projs.config')
local trust = require('lsp-projs.trust')
local util = require('lsp-projs.util')

local M = {
  config = config,
  trust = trust,
}

---@param root_dir string
function M.update_project_settings(root_dir)
  if type(root_dir) ~= 'string' or not trust.check(root_dir) then
    return
  end

  local decoded = util.readjson(root_dir..config.settings_file)
  rawset(M.settings, root_dir, decoded or {})
  if decoded then
    vim.notify('Loaded project lsp settings.', vim.log.levels.INFO)
  end
  return decoded or {}
end

---@param client table
---@param opts table
function M.update_client_settings(client, opts)
  local root_dir = client.config.root_dir
  local settings = M.settings[root_dir] and M.settings[root_dir][client.name]
  if not settings then
    return
  end

  local mode = opts and opts.merge_mode or config.settings_merge_mode
  if mode ~= 'overwrite' then
    settings = vim.tbl_deep_extend(mode, client.config.settings or {}, settings)
  end
  client.config.settings = settings

  if opts and opts.notify then
    client.notify("workspace/didChangeConfiguration")
  end
end

M.settings = setmetatable({}, {
  __index = function(_, key)
    return M.update_project_settings(key)
  end
})

local original_manager = lspconfig.util.server_per_root_dir_manager
local function trust_manager_wrapper(_make_config)
  local inner = original_manager(_make_config)
  local orig_add = inner.add
  function inner.add(root_dir, single_file)
    if not M.trust.check(root_dir) then
      vim.notify('Blocked starting lsp server: workspace directory is untrusted.', vim.log.levels.WARN)
      return
    end

    return orig_add(root_dir, single_file)
  end
  return inner
end


local function on_init(client)
  M.update_client_settings(client)
end

---@param opts? LspProjsConfig
function M.setup(opts)
  config.update(opts)

  if config.trust_enabled then
    lspconfig.util.server_per_root_dir_manager = trust_manager_wrapper
  end

  lspconfig.util.on_setup = lspconfig.util.add_hook_before(lspconfig.util.on_setup, function(cfg)
    if cfg.on_init ~= on_init then
      cfg.on_init = lspconfig.util.add_hook_after(cfg.on_init, on_init)
    end
  end)
end

vim.api.nvim_command[[command! LspTrustEdit lua require('lsp-projs.editor').open()]]
vim.api.nvim_command[[command! LspTrustStatus lua require('lsp-projs.bufeditor').open()]]
vim.api.nvim_command[[command! LspTrustReload lua require('lsp-projs').trust.load()]]
vim.api.nvim_command[[command! LspTrustClear lua require('lsp-projs').trust.clear()]]
vim.api.nvim_command[[command! -nargs=+ -complete=dir LspTrustAdd lua require('lsp-projs').trust.add(<f-args>)]]
vim.api.nvim_command[[command! -nargs=+ -complete=dir LspTrustRemove lua require('lsp-projs').trust.remove(<f-args>)]]

return M
