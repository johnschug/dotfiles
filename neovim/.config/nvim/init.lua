local vimconf = vim.fn.stdpath('config')

local vimx = require('me.vimx')
local vimrc = vimx.autocmd.group('vimrc', true)

local LOCAL = (loadfile(vimconf .. '/local.lua') or function()
  return { finish = function() end }
end)()

-- General
vim.opt.path:append { '**' }
vim.opt.fileformats = { 'unix', 'dos', 'mac' }
vim.opt.modeline = false
vim.opt.shada = "'100,s10,<0,@0,h,r/tmp,r/dev/shm,r/var/run,r/run"

vim.opt.undofile = true
vim.opt.backupdir:remove('.')
vim.opt.backupskip:append { '/tmp/*', '*/tmp/*', '/dev/shm/*', '/var/run/*', '/run/*' }

vimrc.add({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, { command = 'silent! checktime' })
vimrc.add('BufWritePre',
  { pattern = { '/tmp/*', '*/tmp/*', '/dev/shm/*', '/var/run/*', '/run/*' }, command = 'setlocal noundofile' })
vimrc.add('BufRead',
  { pattern = { '/tmp/*', '*/tmp/*', '/dev/shm/*', '/var/run/*', '/run/*' }, command = 'setlocal noswapfile' })
vimrc.add('BufReadPost', { callback = function()
  if vim.o.filetype == 'commit' then
    return
  end
  local saved = vim.api.nvim_buf_get_mark(0, '"')
  if saved and saved[1] >= 1 and saved[1] <= vim.api.nvim_buf_line_count(0) then
    vim.api.nvim_win_set_cursor(0, { saved[1], 0 })
  end
end })

-- Interface
vim.opt.shortmess:append { ['a'] = true, ['c'] = true }
vim.opt.title = true
vim.opt.titlestring = '%t'
vim.opt.lazyredraw = true
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 10
vim.opt.list = true
vim.opt.listchars = { tab = '▸ ', nbsp = '␣', trail = '•', precedes = '…', extends = '…' }
vim.opt.number = true
vim.opt.colorcolumn = '+1'
vim.opt.showmode = false

vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.winminheight = 0
vim.opt.previewheight = 7

vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = '↪ '

vim.opt.foldlevel = 99
vim.opt.foldnestmax = 2
vim.opt.foldminlines = 5
vim.opt.foldcolumn = '1'
vim.opt.foldtext = "printf('%s ┄ (%d lines)', getline(v:foldstart), v:foldend - v:foldstart)"
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldopen:append 'insert'
vim.opt.fillchars = { diff = '⎼', fold = ' ' }

vim.opt.wrapscan = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.wildignorecase = true
vim.opt.wildmode = { 'longest:full', 'full' }
vim.opt.wildignore:append { '[._]*.s[a-z][a-z]', '*.bak', '.DS_Store', '._*', '*~' }
vim.opt.suffixes:append {
  '.lock$', '.pyc$', '.class$', '.jar$', '.rlib$', '.o$', '.a$', '.so$', '.lib$',
  '.dll$', '.pdb$', '.exe', ''
}

vim.opt.guicursor = ''
if vim.env['COLORTERM'] == 'truecolor' then
  vim.opt.termguicolors = true
end

vim.cmd.colorscheme('breeze')

vimrc.add('InsertEnter', { command = 'set norelativenumber' })
vimrc.add('InsertLeave', { command = 'set relativenumber' })
vimrc.add('BufWinEnter', { callback = function()
  if vim.o.buftype == 'help' then
    vim.api.nvim_command('wincmd L')
  end
end })
vimrc.add('FileType', { pattern = 'netrw', command = 'setlocal bufhidden=wipe' })
vimrc.add('FileType', { pattern = { 'qf', 'netrw' }, callback = function()
  vim.opt_local.cursorline = true
  vim.opt_local.cursorcolumn = false
  vim.keymap.set('n', 'q', '<C-W>c', { buffer = true, silent = true })
end })

-- Editing
vim.opt.timeoutlen = 500

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = -1
vim.opt.joinspaces = false

vim.opt.confirm = true
vim.opt.matchpairs:append { '<:>' }
vim.opt.formatoptions:append { ['l'] = true, ['1'] = true }
vim.opt.virtualedit = 'block'
vim.opt.copyindent = true
vim.opt.preserveindent = true
vim.opt.complete:append 'kspell'
vim.opt.completeopt = { 'menuone', 'noselect' }
vim.opt.spelllang = 'en_us'
vim.opt.dictionary:prepend 'spell'
if vim.fn.filereadable('/usr/share/dict/words') > 0 then
  vim.opt.dictionary:append '/usr/share/dict/words'
end
vim.opt.diffopt:append { 'iwhite', 'indent-heuristic', 'algorithm:histogram' }

-- Commands
_G.inspect = _G.inspect or function(...)
  local objs = {}
  for i = 1, select('#', ...) do
    table.insert(objs, vim.inspect(select(i, ...)))
  end
  print(table.concat(objs, '\n'))
  return ...
end

vim.cmd [[
command! -bar -nargs=+ EditSplit call v:lua.EditSplit(<q-mods>, <q-args>)
command! -bar -nargs=+ EditConfig call v:lua.EditConfig(<q-mods>, <f-args>)
]]
function EditSplit(mods, args)
  local cmd = 'split'
  if not vim.o.modified and vim.fn.line('$') == 1 and vim.fn.getline(1) == '' then
    cmd = 'edit'
  end
  pcall(vim.api.nvim_command, string.format('%s %s %s', mods, cmd, args))
end

function EditConfig(mods, what, typ)
  typ = typ or vim.o.filetype
  if not typ or typ == '' then
    return
  end

  local path = what .. '/' .. typ
  local writeable = vim.fn.filewritable
  if writeable(vimconf .. '/after/' .. path .. '.lua') ~= 0 then
    EditSplit(mods, vimconf .. '/after/' .. path .. '.lua')
  elseif writeable(vimconf .. '/after/' .. path .. '.vim') ~= 0 then
    EditSplit(mods, vimconf .. '/after/' .. path .. '.vim')
  elseif writeable(vimconf .. '/' .. path .. '.lua') ~= 0 then
    EditSplit(mods, vimconf .. '/' .. path .. '.lua')
  elseif writeable(vimconf .. '/' .. path .. '.vim') ~= 0 then
    EditSplit(mods, vimconf .. '/' .. path .. '.vim')
  elseif ((not vim.tbl_isempty(vim.api.nvim_get_runtime_file(path .. '.lua', false)))
      or (not vim.tbl_isempty(vim.api.nvim_get_runtime_file(path .. '.vim', false)))) then
    EditSplit(mods, vimconf .. '/after/' .. path .. '.lua')
  else
    EditSplit(mods, vimconf .. '/' .. path .. '.lua')
  end
end

function StripTrailingWhitespace()
  if vim.o.modifiable and not vim.o.binary then
    local view = vim.fn.winsaveview()
    pcall(vim.api.nvim_exec, [[%sm/\s\+$//e]], false)
    vim.fn.winrestview(view)
  end
end

if vim.fn.executable('rg') ~= 0 then
  vim.opt.grepprg = 'rg --vimgrep --no-heading -S'
  vim.opt.grepformat:prepend '%f:%l:%c:%m'
elseif vim.fn.executable('ag') ~= 0 then
  vim.opt.grepprg = 'ag --vimgrep'
  vim.opt.grepformat:prepend '%f:%l:%c:%m'
else
  vim.opt.grepprg = 'grep -srnH'
end

vimrc.add('BufWritePre', { callback = function()
  if (vim.b.strip_trailing or '1') == '1' then
    StripTrailingWhitespace()
  end

  local dir = vim.fn.expand('<afile>:p:h')
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
  end
end })
vimrc.add('QuickFixCmdPost', { pattern = '[^l]*', command = 'botright cwindow|redraw!', nested = true })
vimrc.add('QuickFixCmdPost', { pattern = 'l*', command = 'lwindow|redraw!', nested = true })

-- Mappings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set('n', '<Space>', '<Nop>')

local function mappings(maps)
  local modes = { terminal = 't', normal = 'n', insert = 'i', selection = 's' }
  for mode, mappings in pairs(maps) do
    for _, mapping in ipairs(mappings) do
      vim.keymap.set(modes[mode], unpack(mapping))
    end
  end
end

mappings {
  terminal = {
    { '<C-W>.', '<C-W>' },
    { '<C-W>:', '<C-\\><C-N>:' },
    { '<C-W>n', '<C-\\><C-N>' },
    { '<C-W>q', '<C-\\><C-N><C-W>q' },
    { '<C-W><C-W>', '<C-\\><C-N><C-W><C-W>' },
    { '<C-W>"', "<C-\\><C-N>\"'.nr2char(getchar()).'pi'", { expr = true } },
  },
  normal = {
    -- Navigation
    { 'gb', '<C-^>' },
    { 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true } },
    { 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true } },
    { '[g', '<Cmd>lua vim.diagnostic.goto_prev()<CR>' },
    { ']g', '<Cmd>lua vim.diagnostic.goto_next()<CR>' },
    { '<C-Space>', '<Cmd>Telescope buffers<CR>' },
    { '<C-p>', '<Cmd>Telescope find_files<CR>' },

    -- Manipulating options
    { 'cost', "<Cmd>let b:strip_trailing=!get(b:, 'strip_trailing', 1)<CR>" },
    { '[ts', '<Cmd>setlocal tabstop=4<CR>' },
    { ']ts', '<Cmd>setlocal tabstop=8<CR>' },
    { '[od', '<Cmd>diffthis<CR>' },
    { ']od', '<Cmd>diffoff<CR>' },
    { 'cod', "'<Cmd>'.(&diff?'diffoff':'diffthis').'<CR>'", { expr = true } },
    { '[oy', '<Cmd>setlocal syntax=ON<CR>' },
    { ']oy', '<Cmd>setlocal syntax=OFF<CR>' },
    { 'coy', "'<Cmd>setlocal syntax='.(&l:syntax==#'OFF'?'ON':'OFF').'<CR>'", { expr = true } },
    { '[ ', "<Cmd>put! =repeat(nr2char(10), v:count1)<CR>']+1" },
    { '] ', "<Cmd>put =repeat(nr2char(10), v:count1)<CR>']-1" },

    { 'ga', '<Plug>(UnicodeGA)' },
    { 'gs', '<Cmd>Telescope grep_string<CR>' },
    { 'g.', "'`['.strpart(getregtype(), 0, 1).'`]'", { expr = true } },
    { 'z=', '<Cmd>Telescope spell_suggest<CR>' },

    -- Leader mappings
    { '<Leader>c', '<Cmd>bd<CR>' },
    { '<Leader>w', '<Cmd>update<CR>' },
    { '<Leader>sv', '<Cmd>source $MYVIMRC<CR>' },
    { '<Leader>ev', '<Cmd>vertical EditSplit $MYVIMRC<CR>' },
    { '<Leader>el', '<Cmd>vertical EditSplit ' .. vimconf .. '/local.lua<CR>' },
    { '<Leader>ec', "'<Cmd>vertical EditConfig colors '.g:colors_name.'<CR>'", { expr = true } },
    { '<Leader>ef', '<Cmd>vertical EditConfig ftplugin<CR>' },
    { '<Leader>es', '<Cmd>vertical EditConfig syntax<CR>' },
    { '<Leader>so', '<Cmd>AerialToggle<CR>' },
    { 'gO', '<Cmd>AerialToggle<CR>' },
    { '<Leader>gs', '<Cmd>Gstatus<CR>' },
    { '<Leader>gb', '<Cmd>leftabove Gblame<CR><C-W>p' },
    { '<Leader>gl', '<Cmd>Gllog!<CR>' },
    { '<Leader>gd', '<Cmd>Gvdiff<CR>' },
    { '<Leader>gw', '<Cmd>Gwrite<CR>' },
  },
  insert = {
    { '<CR>', '<C-G>u<CR>' },

    { '<C-j>', "vsnip#available(1)?'<Plug>(vsnip-expand-or-jump)':'<C-j>'", { expr = true, remap = true } },
    { '<C-k>', "vsnip#jumpable(-1)?'<Plug>(vsnip-jump-prev)':'<C-k>'", { expr = true, remap = true } },
  },
  selection = {
    { '<C-j>', "vsnip#available(1)?'<Plug>(vsnip-expand-or-jump)':'<C-j>'", { expr = true, remap = true } },
    { '<C-k>', "vsnip#jumpable(-1)?'<Plug>(vsnip-jump-prev)':'<C-k>'", { expr = true, remap = true } },
  },
}

vim.cmd [[
cabbrev <expr> %% fnameescape(expand('%'))
cabbrev <expr> :: fnameescape(expand('%:h'))
]]

for k, c in pairs({ a = '', b = 'b', t = 't', q = 'c', l = 'l' }) do
  vim.keymap.set('n', '[' .. k, "'<Cmd>'.v:count1.'" .. c .. "prev<CR>'", { expr = true })
  vim.keymap.set('n', ']' .. k, "'<Cmd>'.v:count1.'" .. c .. "next<CR>'", { expr = true })
  vim.keymap.set('n', '[' .. k:upper(), '<Cmd>' .. c .. 'first<CR>')
  vim.keymap.set('n', ']' .. k:upper(), '<Cmd>' .. c .. 'last<CR>')
end
for k, o in pairs({ s = 'spell', et = 'expandtab', w = 'wrap', r = 'relativenumber', l = 'list' }) do
  vim.keymap.set('n', '[o' .. k, '<Cmd>setlocal ' .. o .. '<CR>')
  vim.keymap.set('n', ']o' .. k, '<Cmd>setlocal no' .. o .. '<CR>')
  vim.keymap.set('n', 'co' .. k, '<Cmd>setlocal ' .. o .. '!<CR>')
end

-- File Types
vim.g.load_doxygen_syntax = 1
vim.g.c_gnu = 1
vim.g.rust_fold = 1
vim.g.man_hardwrap = 1

if vim.fn.executable('rustup') ~= 0 then
  vim.g.rustfmt_command = 'rustfmt +nightly'
end

vimrc.add('FileType', { pattern = 'vim', command = 'setlocal keywordprg=:help' })
vimrc.add('FileType', { pattern = 'man', command = 'setlocal nolist noexpandtab sw=8 ts=8' })
vimrc.add('FileType', { pattern = { 'gitcommit', 'text', 'markdown', 'pandoc', 'html' }, command = 'setlocal spell' })
if vim.fn.executable('hindent') ~= 0 then
  vimrc.add('FileType', { pattern = 'haskell', command = 'setlocal equalprg=hindent' })
end

-- Projects
vim.opt.tagcase = 'smart'
vim.opt.tags = { './tags;', 'tags' }
vim.opt.sessionoptions:remove { 'curdir', 'options' }
vim.opt.sessionoptions:append { 'localoptions', 'sesdir' }

do
  local gitroot = vim.fn.systemlist('git rev-parse --show-toplevel')[1] or ''
  if vim.v.shell_error == 0 and string.len(gitroot) > 0 then
    vim.opt.path:append(gitroot .. '/**')
    vim.opt.tags:append(gitroot .. '/.git/tags')
  end
end

vimrc.add('FileType', { command = "let &l:tags = &tags.','.expand(stdpath('state').'/tags/').&ft" })

-- Plugins
vim.g.delimitMate_expand_space = 1
vim.g.delimitMate_expand_cr = 1
vim.g.delimitMate_jump_expansion = 1

vim.g.EditorConfig_disable_rules = { 'trim_trailing_whitespace' }

vim.g.netrw_hide = 1
vim.g.netrw_list_hide = [[\(^\|\s\s\)\zs\.\S\+]]
vim.g.netrw_sizestyle = 'H'
vim.g.netrw_sort_options = 'i'

vim.g.signify_priority = 5
vim.g.signify_vcs_list = { 'git' }

vim.g.vsnip_snippet_dir = vimconf .. '/vsnip'

-- Diagnostics
vim.diagnostic.config {
  severity_sort = true,
}

vimrc.add('DiagnosticChanged', { callback = require('me.utils').update_loclist })
vimrc.add({ 'CursorMoved', 'CursorHold' }, { callback = require('me.utils').show_line_diagnostics })

-- Aerial
require('aerial').setup {
  filter_kind = {
    "Module",
    "Namespace",
    "Package",
    "Enum",
    "Struct",
    "Class",
    "Interface",
    "Constructor",
    "Method",
    "Function",
    "Field",
    -- "Property",
    "EnumMember",
    -- "Constant",
  },
}

-- Completion
do
  local cmp = require('cmp')
  cmp.setup {
    snippet = {
      expand = function(args)
        vim.fn['vsnip#anonymous'](args.body)
      end
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
      { name = 'vsnip' },
      { name = 'nvim_lsp' },
      { name = 'buffer' },
      { name = 'path' },
    }),
  }

  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' },
    },
  })

  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'path' },
      { name = 'cmdline' },
    },
  })
end

-- Telescope
require('telescope').setup {
  defaults = require('telescope.themes').get_ivy({}),
  pickers = {
    buffers = {
      sort_mru = true,
    },
  },
}

-- LSP
vimrc.add('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    local function set_keymap(modes, lhs, rhs, opts)
      opts = vim.tbl_extend('force', { buffer = bufnr }, opts or {})
      vim.keymap.set(modes, lhs, rhs, opts)
    end

    local lsp_group = vimx.autocmd.group('vimrc_lsp')
    local function add_autocmd(events, action)
      lsp_group.add(events, { buffer = bufnr, command = action })
    end

    local telescope = require('telescope.builtin')
    set_keymap('n', 'K', vim.lsp.buf.hover)
    set_keymap('n', '<C-k>', vim.lsp.buf.signature_help)
    set_keymap('n', 'gd', telescope.lsp_definitions)
    set_keymap('n', 'gD', vim.lsp.buf.declaration)
    set_keymap('n', 'gi', telescope.lsp_implementations)
    set_keymap('n', 'gr', telescope.lsp_references)
    set_keymap('n', 'gs', telescope.lsp_dynamic_workspace_symbols)
    set_keymap({ 'n', 'v' }, 'gy', vim.lsp.buf.code_action)
    set_keymap('n', 'gY', vim.lsp.codelens.run)
    set_keymap('n', '<Leader>rn', vim.lsp.buf.rename)
    set_keymap('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder)
    set_keymap('n', '<Leader>wa', vim.lsp.buf.remove_workspace_folder)
    set_keymap('n', '<Leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end)

    vim.api.nvim_buf_create_user_command(bufnr, 'LspRename', vim.lsp.buf.rename, {})

    lsp_group.clear({ buffer = bufnr })
    add_autocmd('BufEnter', "lua require('me.utils').update_loclist()")

    if client.supports_method("textDocument/formatting") then
      add_autocmd('BufWritePre', 'lua vim.lsp.buf.formatting_seq_sync(nil, 2000)')
    end
    if client.supports_method("textDocument/codeAction") then
      add_autocmd({ 'CursorMoved', 'CursorHold' }, "lua require('me.utils').show_code_actions()")
    end
    if client.supports_method("textDocument/codeLens") then
      add_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, 'lua vim.lsp.codelens.refresh()')
    end
    if client.supports_method("textDocument/documentHighlight") then
      add_autocmd({ 'InsertEnter', 'BufLeave', 'CursorMoved' }, 'lua vim.lsp.buf.clear_references()')
      add_autocmd({ 'CursorMoved', 'CursorHold' }, "lua require('me.utils').show_references()")
    end
  end,
})

local server_configs = {
  efm = {
    filetypes = { 'vim', 'sh', 'markdown', 'yaml', 'fish' },
    init_options = {
      documentFormatting = true,
      codeAction = true,
    },
  },
}

require('neodev').setup {}
require('mason').setup()
require('mason-lspconfig').setup()
require('mason-lspconfig').setup_handlers {
  function(server_name)
    local config = server_configs[server_name] or {}
    config.capabilities = require('cmp_nvim_lsp').default_capabilities()
    require('lspconfig')[server_name].setup(config)
  end,
}

vimrc.add('User', { pattern = 'LspProgressUpdate', callback = require('me.utils').update_progress })

-- Treesitter
require('nvim-treesitter.configs').setup {
  auto_install = true,
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<CR>',
      node_incremental = '<CR>',
      node_decremental = '<BS>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
        ['ip'] = '@parameter.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
        [']p'] = '@parameter.inner',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
        [']P'] = '@parameter.inner',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
        ['[p'] = '@parameter.inner',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
        ['[P'] = '@parameter.inner',
      },
    },
  },
}

-- lualine
local function status_line_progress()
  local progress = require('me.utils').get_progress()
  if vim.tbl_isempty(progress) then
    return ''
  end

  local result = {}
  for name, msg in pairs(progress) do
    result[#result + 1] = string.format('[%s] %s', name, msg)
  end

  return '%<' .. table.concat(result, '; ')
end

require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = 'breeze',
    section_separators = '',
    component_separators = '|',
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', { 'diff', colored = false } },
    lualine_c = { { 'filename', path = 1 }, status_line_progress },
    lualine_x = { { 'bo:spelllang', condition = function() return vim.o.spell end },
      'filetype', 'encoding', 'fileformat' },
    lualine_y = { 'progress' },
    lualine_z = { { 'location', separator = '' }, {
      'diagnostics',
      sections = { 'error', 'warn' },
      diagnostics_color = {
        error = 'DiagnosticStatusError',
        warn = 'DiagnosticStatusWarn',
      },
    } },
  },
  extensions = { 'quickfix' },
}

LOCAL.finish()
