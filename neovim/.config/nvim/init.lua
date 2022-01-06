local vimconf = vim.fn.stdpath('config')

local au = require('me.au')
local vimrc = au.group('vimrc')
vimrc:clear()

local LOCAL = (loadfile(vimconf .. '/local.lua') or function()
  return { finish = function() end }
end)()

-- General
vim.opt.path:append {'**'}
vim.opt.fileformats = {'unix', 'dos', 'mac'}
vim.opt.modeline = false
vim.opt.shada = "'100,s10,<0,@0,h,r/tmp,r/dev/shm,r/var/run,r/run"

vim.opt.undofile = true
vim.opt.backupdir:remove('.')
vim.opt.backupskip:append {'/tmp/*', '*/tmp/*', '/dev/shm/*', '/var/run/*', '/run/*'}

vimrc[{'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI'}] = 'silent! checktime'
vimrc.BufWritePre[{'/tmp/*', '*/tmp/*', '/dev/shm/*', '/var/run/*', '/run/*'}] = 'setlocal noundofile'
vimrc.BufRead[{'/tmp/*', '*/tmp/*', '/dev/shm/*', '/var/run/*', '/run/*'}] = 'setlocal noswapfile'
vimrc.BufReadPost = function()
  if vim.o.filetype == 'commit' then
    return
  end
  local saved = vim.api.nvim_buf_get_mark(0, '"')
  if saved and saved[1] >= 1 and saved[1] <= vim.api.nvim_buf_line_count(0) then
    vim.api.nvim_win_set_cursor(0, {saved[1], 0})
  end
end

-- Interface
vim.opt.shortmess:append {['a'] = true, ['c'] = true}
vim.opt.titlestring = '%t'
vim.opt.title = true
vim.opt.lazyredraw = true
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 10
vim.opt.list = true
vim.opt.listchars = {tab = '▸ ', nbsp = '␣', trail = '•', precedes = '…', extends = '…'}
vim.opt.number = true
vim.opt.relativenumber = true
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

vim.opt.foldenable = false
vim.opt.foldmethod = 'syntax'
vim.opt.foldcolumn = '1'
vim.opt.foldminlines = 5
vim.opt.foldopen:append 'insert'
vim.opt.fillchars = {diff = '⎼', vert = '│', fold = '·'}

vim.opt.wrapscan = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.wildignorecase = true
vim.opt.wildmode = {'longest:full', 'full'}
vim.opt.wildignore:append {'[._]*.s[a-z][a-z]', '*.bak', '.DS_Store', '._*', '*~'}
vim.opt.suffixes:append {
  '.lock$', '.pyc$', '.class$', '.jar$', '.rlib$', '.o$', '.a$', '.so$', '.lib$',
  '.dll$', '.pdb$', '.exe', ''
}

vim.opt.guicursor = ''
if vim.env['COLORTERM'] == 'truecolor' then
  vim.opt.termguicolors = true
end

vim.cmd('colorscheme breeze')

vimrc.InsertEnter = 'set norelativenumber'
vimrc.InsertLeave = 'set relativenumber'
vimrc.BufWinEnter = function()
  if vim.o.buftype == 'help' then
    vim.api.nvim_command('wincmd L')
  end
end
vimrc.FileType.netrw = 'setlocal bufhidden=wipe'
vimrc.FileType[{'qf', 'netrw'}] = function()
  vim.opt_local.cursorline = true
  vim.opt_local.cursorcolumn = false
  vim.api.nvim_buf_set_keymap(0, 'n', 'q', '<C-W>c', { silent = true, noremap = true })
end

-- Editing
vim.opt.timeoutlen = 500

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = -1
vim.opt.joinspaces = false

vim.opt.confirm = true
vim.opt.matchpairs:append {'<:>'}
vim.opt.formatoptions:append {['l'] = true, ['1'] = true}
vim.opt.virtualedit = 'block'
vim.opt.copyindent = true
vim.opt.preserveindent = true
vim.opt.complete:append 'kspell'
vim.opt.completeopt = {'menuone', 'noselect'}
vim.opt.spelllang = 'en_us'
vim.opt.dictionary:prepend 'spell'
if vim.fn.filereadable('/usr/share/dict/words') > 0 then
  vim.opt.dictionary:append '/usr/share/dict/words'
end
vim.opt.diffopt:append {'iwhite', 'indent-heuristic', 'algorithm:histogram'}

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

  local path = what..'/'..typ
  local writeable = vim.fn.filewritable
  if writeable(vimconf..'/after/'..path..'.lua') ~= 0 then
    EditSplit(mods, vimconf..'/after/'..path..'.lua')
  elseif writeable(vimconf..'/after/'..path..'.vim') ~= 0 then
    EditSplit(mods, vimconf..'/after/'..path..'.vim')
  elseif writeable(vimconf..'/'..path..'.lua') ~= 0 then
    EditSplit(mods, vimconf..'/'..path..'.lua')
  elseif writeable(vimconf..'/'..path..'.vim') ~= 0 then
    EditSplit(mods, vimconf..'/'..path..'.vim')
  elseif ((not vim.tbl_isempty(vim.api.nvim_get_runtime_file(path..'.lua', false)))
    or  (not vim.tbl_isempty(vim.api.nvim_get_runtime_file(path..'.vim', false)))) then
    EditSplit(mods, vimconf..'/after/'..path..'.lua')
  else
    EditSplit(mods, vimconf..'/'..path..'.lua')
  end
end

function StripTrailingWhitespace()
  if vim.o.modifiable and not vim.o.binary then
    local view = vim.fn.winsaveview()
    pcall(vim.cmd, [[%sm/\s\+$//e]])
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

vimrc.BufWritePre = function()
  if (vim.b.strip_trailing or '1') == '1' then
    StripTrailingWhitespace()
  end

  local dir = vim.fn.expand('<afile>:p:h')
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
  end
end
vimrc.QuickFixCmdPost['[^l]*'][{nested = true}] = 'botright cwindow|redraw!'
vimrc.QuickFixCmdPost['l*'][{nested = true}] = 'lwindow|redraw!'

-- Mappings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.api.nvim_set_keymap('n', '<Space>', '<Nop>', {noremap = true})

local function mappings(maps)
  local modes = { terminal = 't', normal = 'n', insert = 'i', selection = 's' }
  for mode, mappings in pairs(maps) do
    for _, mapping in ipairs(mappings) do
      mapping[3] = mapping[3] or {}
      vim.api.nvim_set_keymap(modes[mode], unpack(mapping))
    end
  end
end

mappings {
  terminal = {
      {'<C-W>.', '<C-W>', {noremap = true}},
      {'<C-W>:', '<C-\\><C-N>:', {noremap = true}},
      {'<C-W>n', '<C-\\><C-N>', {noremap = true}},
      {'<C-W>q', '<C-\\><C-N><C-W>q', {noremap = true}},
      {'<C-W><C-W>', '<C-\\><C-N><C-W><C-W>', {noremap = true}},
      {'<C-W>"', "<C-\\><C-N>\"'.nr2char(getchar()).'pi'", {noremap = true, expr = true}},
  },
  normal = {
    -- Navigation
    {'gb', '<C-^>', {noremap = true}},
    {'<C-Space>', '<Cmd>Telescope buffers<CR>', {noremap = true}},
    {'<Leader>f', '<Cmd>Telescope find_files<CR>', {noremap = true}},
    {'<Leader>F', '<Cmd>Telescope oldfiles<CR>', {noremap = true}},
    {'j', "v:count == 0 ? 'gj' : 'j'", {noremap = true, expr = true}},
    {'k', "v:count == 0 ? 'gk' : 'k'", {noremap = true, expr = true}},
    {'[g', '<Cmd>lua vim.diagnostic.goto_prev()<CR>', {noremap = true}},
    {']g', '<Cmd>lua vim.diagnostic.goto_next()<CR>', {noremap = true}},

    -- Manipulating options
    {'cost', "<Cmd>let b:strip_trailing=!get(b:, 'strip_trailing', 1)<CR>", {noremap = true}},
    {'[ts', '<Cmd>setlocal tabstop=4<CR>', {noremap = true}},
    {']ts', '<Cmd>setlocal tabstop=8<CR>', {noremap = true}},
    {'[od', '<Cmd>diffthis<CR>', {noremap = true}},
    {']od', '<Cmd>diffoff<CR>', {noremap = true}},
    {'cod', "'<Cmd>'.(&diff?'diffoff':'diffthis').'<CR>'", {noremap = true, expr = true}},
    {'[oy', '<Cmd>setlocal syntax=ON<CR>', {noremap = true}},
    {']oy', '<Cmd>setlocal syntax=OFF<CR>', {noremap = true}},
    {'coy', "'<Cmd>setlocal syntax='.(&l:syntax==#'OFF'?'ON':'OFF').'<CR>'", {noremap = true, expr = true}},
    {'[ ', "<Cmd>put! =repeat(nr2char(10), v:count1)<CR>']+1", {noremap = true}},
    {'] ', "<Cmd>put =repeat(nr2char(10), v:count1)<CR>']-1", {noremap = true}},

    {'ga', '<Plug>(UnicodeGA)'},
    {'gs', '<Cmd>Telescope grep_string<CR>', {noremap = true}},
    {'g.', "'`['.strpart(getregtype(), 0, 1).'`]'", {noremap = true, expr = true}},
    {'z=', '<Cmd>Telescope spell_suggest<CR>', {noremap = true}},
    {'<C-L>', '<Cmd>nohlsearch|checktime|diffupdate<CR><C-L>', {noremap = true}},

    -- Leader mappings
    {'<Leader>c', '<Cmd>bd<CR>', {noremap = true}},
    {'<Leader>w', '<Cmd>update<CR>', {noremap = true}},
    {'<Leader>sv', '<Cmd>source $MYVIMRC<CR>', {noremap = true}},
    {'<Leader>ev', '<Cmd>vertical EditSplit $MYVIMRC<CR>', {noremap = true}},
    {'<Leader>el', '<Cmd>vertical EditSplit '..vimconf..'/local.lua<CR>', {noremap = true}},
    {'<Leader>ec', "'<Cmd>vertical EditConfig colors '.g:colors_name.'<CR>'", {noremap = true, expr = true}},
    {'<Leader>ef', '<Cmd>vertical EditConfig ftplugin<CR>', {noremap = true}},
    {'<Leader>es', '<Cmd>vertical EditConfig syntax<CR>', {noremap = true}},
    {'<Leader>ss', '<Cmd>SymbolsOutline<CR>', {noremap = true}},
    {'<Leader>gs', '<Cmd>Gstatus<CR>', {noremap = true}},
    {'<Leader>gb', '<Cmd>leftabove Gblame<CR><C-W>p', {noremap = true}},
    {'<Leader>gl', '<Cmd>Gllog!<CR>', {noremap = true}},
    {'<Leader>gd', '<Cmd>Gvdiff<CR>', {noremap = true}},
    {'<Leader>gw', '<Cmd>Gwrite<CR>', {noremap = true}},
  },
  insert = {
    {'<CR>', '<C-G>u<CR>', {noremap = true}},

    {'<C-j>', "vsnip#available(1)?'<Plug>(vsnip-expand-or-jump)':'<C-j>'", {expr = true}},
    {'<C-k>', "vsnip#jumpable(-1)?'<Plug>(vsnip-jump-prev)':'<C-k>'", {expr = true}},
  },
  selection = {
    {'<C-j>', "vsnip#available(1)?'<Plug>(vsnip-expand-or-jump)':'<C-j>'", {expr = true}},
    {'<C-k>', "vsnip#jumpable(-1)?'<Plug>(vsnip-jump-prev)':'<C-k>'", {expr = true}},
  },
}

vim.cmd [[
  cabbrev <expr> %% fnameescape(expand('%'))
  cabbrev <expr> :: fnameescape(expand('%:h'))
]]

for k, c in pairs({a = '', b = 'b', t = 't', q = 'c', l = 'l'}) do
  vim.api.nvim_set_keymap('n', '['..k, "'<Cmd>'.v:count1.'"..c.."prev<CR>'", {noremap = true, expr = true})
  vim.api.nvim_set_keymap('n', ']'..k, "'<Cmd>'.v:count1.'"..c.."next<CR>'", {noremap = true, expr = true})
  vim.api.nvim_set_keymap('n', '['..k:upper(), '<Cmd>'..c..'first<CR>', {noremap = true})
  vim.api.nvim_set_keymap('n', ']'..k:upper(), '<Cmd>'..c..'last<CR>', {noremap = true})
end
for k, o in pairs({s = 'spell', et = 'expandtab', w = 'wrap', r = 'relativenumber', l = 'list'}) do
  vim.api.nvim_set_keymap('n', '[o'..k, '<Cmd>setlocal '..o..'<CR>', {noremap = true})
  vim.api.nvim_set_keymap('n', ']o'..k, '<Cmd>setlocal no'..o..'<CR>', {noremap = true})
  vim.api.nvim_set_keymap('n', 'co'..k, '<Cmd>setlocal '..o..'!<CR>', {noremap = true})
end

-- File Types
vim.g.load_doxygen_syntax = 1
vim.g.c_gnu = 1
vim.g.rust_fold = 1
vim.g.man_hardwrap = 1

if vim.fn.executable('rustup') ~= 0 then
  vim.g.rustfmt_command = 'rustfmt +nightly'
end

vimrc.FileType.vim = 'setlocal keywordprg=:help'
vimrc.FileType.man = 'setlocal nolist noexpandtab sw=8 ts=8'
vimrc.FileType[{'gitcommit', 'text', 'markdown', 'pandoc', 'html'}] = 'setlocal spell'
if vim.fn.executable('hindent') ~= 0 then
  vimrc.FileType.haskell = 'setlocal equalprg=hindent'
end

-- Projects
vim.opt.tagcase = 'smart'
vim.opt.tags = {'./tags;', 'tags'}
vim.opt.sessionoptions:remove {'curdir', 'options'}
vim.opt.sessionoptions:append {'localoptions', 'sesdir'}

local gitroot = vim.fn.systemlist('git rev-parse --show-toplevel')[1] or ''
if vim.v.shell_error == 0 and string.len(gitroot) > 0 then
  vim.opt.path:append(gitroot .. '/**')
  vim.opt.tags:append(gitroot .. '/.git/tags')
end

vimrc.FileType = "let &l:tags = &tags.','.expand(stdpath('data').'/tags/').&ft"

-- Plugins
vim.g.delimitMate_expand_space = 1
vim.g.delimitMate_expand_cr = 1
vim.g.delimitMate_jump_expansion = 1

vim.g.EditorConfig_disable_rules = {'trim_trailing_whitespace'}

vim.g.netrw_hide = 1
vim.g.netrw_list_hide = [[\(^\|\s\s\)\zs\.\S\+]]
vim.g.netrw_sizestyle = 'H'
vim.g.netrw_sort_options = 'i'

vim.g.signify_priority = 5
vim.g.signify_vcs_list = {'git'}

vim.g.vsnip_snippet_dir = vimconf..'/vsnip'

-- Diagnostics
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = {
    format = function(diag)
      return string.format('● %s', diag.message)
    end,
  },
})

vimrc.DiagnosticChanged['*'] = "lua require('me.utils').update_loclist()"
vimrc[{'CursorMoved', 'CursorHold'}]['*'] = "lua require('me.utils').show_line_diagnostics()"

-- Completion
do
  local cmp = require 'cmp'
  cmp.setup {
    snippet = {
      expand = function(args)
        vim.fn['vsnip#anonymous'](args.body)
      end
    },
    mapping = {
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ['<C-y>'] = cmp.mapping.confirm({ select = true }),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = cmp.config.sources({
      { name = 'vsnip' },
      { name = 'nvim_lsp' },
      { name = 'buffer' },
      { name = 'path' },
    }),
  }

  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' },
    },
  })

  cmp.setup.cmdline(':', {
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
require('lsp-projs').setup()

local function lsp_on_attach(client, bufnr)
  local function set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end
  local function set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end

  set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
  set_option('tagfunc', 'v:lua.vim.lsp.tagfunc')
  set_option('formatexpr', 'v:lua.vim.lsp.formatexpr')

  local opts = {noremap = true}
  set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  set_keymap('n', '<C-k>', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  set_keymap('n', 'gd', "<Cmd>lua require('telescope.builtin').lsp_definitions()<CR>", opts)
  set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  set_keymap('n', 'gi', "<Cmd>lua require('telescope.builtin').lsp_implementations()<CR>", opts)
  set_keymap('n', 'gr', "<Cmd>lua require('telescope.builtin').lsp_references()<CR>", opts)
  set_keymap('n', 'gs', "<Cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<CR>", opts)
  set_keymap('n', 'gy', "<Cmd>lua require('telescope.builtin').lsp_code_actions()<CR>", opts)
  set_keymap('v', 'gy', "<Cmd>lua require('telescope.builtin').lsp_range_code_actions()<CR>", opts)
  set_keymap('n', 'gY', '<Cmd>lua vim.lsp.codelens.run()<CR>', opts)
  set_keymap('n', '<Leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
  set_keymap('n', '<Leader>wa', '<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  set_keymap('n', '<Leader>wa', '<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  set_keymap('n', '<Leader>wl', '<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)

  vim.cmd('command! -buffer LspRename lua vim.lsp.buf.rename()')

  local lsp_group = au.group('vimrc_lsp')
  lsp_group['*']['<buffer>']:clear()
  lsp_group.BufEnter['<buffer>'] = "lua require('me.utils').update_loclist()"
  lsp_group[{'CursorMoved', 'CursorHold'}] = "lua require('me.utils').show_code_actions()"

  if client.resolved_capabilities.code_lens then
    lsp_group[{'BufEnter', 'CursorHold', 'InsertLeave'}]['<buffer>'] = 'lua vim.lsp.codelens.refresh()'
  end
  if client.resolved_capabilities.document_formatting then
    lsp_group.BufWritePre['<buffer>'] = 'lua vim.lsp.buf.formatting_seq_sync(nil, 2000)'
  end
  if client.resolved_capabilities.document_highlight then
    lsp_group[{'InsertEnter', 'BufLeave', 'CursorMoved'}]['<buffer>'] = 'lua vim.lsp.buf.clear_references()'
    lsp_group[{'CursorMoved', 'CursorHold'}]['<buffer>'] = "lua require('me.utils').show_references()"
  end
end

local server_configs = {
  lua = require 'lua-dev'.setup({}),
  efm = {
    filetypes = {'vim', 'sh', 'markdown', 'yaml', 'fish'},
    init_options = {
      documentFormatting = true,
      codeAction = true,
    },
  },
}

require('nvim-lsp-installer').on_server_ready(function(server)
  local caps = vim.lsp.protocol.make_client_capabilities()
  caps = require('cmp_nvim_lsp').update_capabilities(caps)

  local config = server_configs[server.name] or {}
  config.capabilities = caps
  config.on_attach = lsp_on_attach
  server:setup(config)
end)

vimrc.User.LspProgressUpdate = "lua require('me.utils').update_progress()"

-- Treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = 'maintained',
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
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
    swap = {
      enable = true,
      swap_next = {
        ['<Leader>swp'] = '@parameter.inner',
        ['<Leader>sws'] = '@statement.outer',
      },
      swap_previous = {
        ['<Leader>swP'] = '@parameter.inner',
        ['<Leader>swS'] = '@statement.outer',
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
    result[#result+1] = string.format('[%s] %s', name, msg)
  end

  return '%<'..table.concat(result, '; ')
end

require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = 'breeze',
    section_separators = '',
    component_separators = '|',
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', {'diff', colored = false}},
    lualine_c = {{'filename', path = 1}, status_line_progress},
    lualine_x = {{'bo:spelllang', condition = function() return vim.o.spell end},
                  'filetype', 'encoding', 'fileformat'},
    lualine_y = {'progress'},
    lualine_z = {{'location', separator = ''}, {
      'diagnostics',
      sections = {'error', 'warn'},
      diagnostics_color = {
        error = 'DiagnosticStatusError',
        warn = 'DiagnosticStatusWarn',
      },
    }},
  },
  extensions = {'quickfix'},
}

LOCAL.finish()
