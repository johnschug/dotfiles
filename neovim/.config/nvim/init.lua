local vimconf = vim.fn.stdpath 'config'
local vimdata = vim.fn.stdpath 'data'

vim.cmd([[
  augroup vimrc
    autocmd!
  augroup END
]])

local LOCAL = (loadfile(vimconf .. '/local.lua') or function()
  return { finish = function() end }
end)()

-- General
vim.opt.hidden = true
vim.opt.path = vim.api.nvim_get_option_info('path').default
vim.opt.path:append {'**'}
vim.opt.fileformats = {'unix', 'dos', 'mac'}
vim.opt.modeline = false
vim.opt.viminfo = vim.api.nvim_get_option_info('viminfo').default
vim.opt.viminfo = "'100,s10,<0,/0,:0,@0,h,r/tmp,r/dev/shm,r/var/run,r/run,n" .. vimdata .. '/info'

vim.opt.backupskip = vim.api.nvim_get_option_info('backupskip').default
vim.opt.backupskip:append {'*/tmp/*', '/dev/shm/*', '/var/run/*', '/run/*'}
vim.opt.backupdir = vimdata..'/backup'
if vim.fn.isdirectory(vim.opt.backupdir:get()[1]) == 0 then
  vim.fn.mkdir(vim.opt.backupdir:get()[1], 'p')
end
vim.opt.undofile = true

vim.cmd [[
  autocmd vimrc FocusGained,BufEnter,CursorHold,CursorHoldI * silent! checktime
  autocmd vimrc BufWritePre /tmp/*,*/tmp/*,/dev/shm/*,/var/run/*,/run/* setlocal noundofile
  autocmd vimrc BufRead /tmp/*,*/tmp/*,/dev/shm/*,/var/run/*,/run/* setlocal noswapfile
  autocmd vimrc BufReadPost * if line("'\"") >= 1 && line("'\"") <= line('$') && &ft !~# 'commit' | execute "normal! g`\"" | endif
]]

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
vim.opt.wildignore = vim.api.nvim_get_option_info('wildignore').default
vim.opt.wildignore:append {'[._]*.s[a-z][a-z]', '*.bak', '.DS_Store', '._*', '*~'}
vim.opt.suffixes = vim.api.nvim_get_option_info('suffixes').default
vim.opt.suffixes:append {
  '.lock$', '.pyc$', '.class$', '.jar$', '.rlib$', '.o$', '.a$', '.so$', '.lib$',
  '.dll$', '.pdb$', '.exe', ''
}

vim.opt.guicursor = 'a:hor5-blinkon500-blinkoff500'
if vim.env['COLORTERM'] and vim.env['COLORTERM'] == 'truecolor' then
  vim.opt.termguicolors = true
end

vim.cmd [[
  colorscheme breeze

  autocmd vimrc InsertEnter * set norelativenumber
  autocmd vimrc InsertLeave * set relativenumber
  autocmd vimrc BufWinEnter * if &buftype ==# 'help' | wincmd L | endif
  autocmd vimrc FileType qf,netrw setlocal cursorline nocursorcolumn | nnoremap <silent> <buffer> q <C-W>c
  autocmd vimrc FileType netrw setlocal bufhidden=wipe
]]

-- Editing
vim.opt.timeoutlen = 500

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = -1

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
vim.opt.inccommand = 'nosplit'
vim.opt.diffopt:append {'iwhite', 'indent-heuristic', 'algorithm:histogram'}

-- Commands
vim.cmd [[
  command! -bar -nargs=+ EditSplit lua edit_split(<q-mods>, <q-args>)
  command! -bar -nargs=+ EditConfig lua edit_config(<q-mods>, <f-args>)
]]
function edit_split(mods, args)
  local cmd = 'split'
  if not vim.o.modified and vim.fn.line('$') == 1 and vim.fn.getline(1) == '' then
    cmd = 'edit'
  end
  pcall(vim.api.nvim_command, string.format('%s %s %s', mods, cmd, args))
end

function edit_config(mods, what, typ)
  local typ = typ or vim.o.filetype
  if not typ or typ == '' then
    return
  end

  local path = what..'/'..typ
  if vim.fn.filewritable(vimconf..'/after/'..path..'.lua') ~= 0 then
    edit_split(mods, vimconf..'/after/'..path..'.lua')
  elseif vim.fn.filewritable(vimconf..'/after/'..path..'.vim') ~= 0 then
    edit_split(mods, vimconf..'/after/'..path..'.vim')
  elseif (vim.fn.filewritable(vimconf..'/'..path..'.lua') == 0)
    and (vim.fn.filewritable(vimconf..'/'..path..'.vim') == 0)
    and ((not vim.tbl_isempty(vim.api.nvim_get_runtime_file(path..'.lua', false)))
    or  (not vim.tbl_isempty(vim.api.nvim_get_runtime_file(path..'.vim', false)))) then
    edit_split(mods, vimconf..'/after/'..path..'.lua')
  elseif vim.fn.filewritable(vimconf..'/'..path..'.vim') ~= 0 then
    edit_split(mods, vimconf..'/'..path..'.vim')
  else
    edit_split(mods, vimconf..'/'..path..'.lua')
  end
end

function strip_trailing_whitespace()
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

vim.cmd([[
  autocmd vimrc BufWritePre * if !isdirectory(expand('<afile>:p:h')) | call mkdir(expand('<afile>:p:h'), 'p') | endif
  autocmd vimrc BufWritePre * if get(b:, 'strip_trailing', 1) | call v:lua.strip_trailing_whitespace() | endif
  autocmd vimrc QuickFixCmdPost [^l]* nested botright cwindow|redraw!
  autocmd vimrc QuickFixCmdPost    l* nested lwindow|redraw!
]])

-- Mappings
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

    {'g.', "'`['.strpart(getregtype(), 0, 1).'`]'", {noremap = true, expr = true}},
    {'gs', "'<Cmd>silent! grep! -w -F '.shellescape(expand('<cword>'), 1).'<CR>'", {noremap = true, expr = true}},
    {'<C-L>', '<Cmd>nohlsearch|checktime|diffupdate<CR><C-L>', {noremap = true}},
    {'<Leader>d', '<Cmd>bd<CR>', {noremap = true}},
    {'<Leader>w', '<Cmd>update<CR>', {noremap = true}},
    {'<Leader>sv', '<Cmd>source $MYVIMRC<CR>', {noremap = true}},
    {'<Leader>ev', '<Cmd>vertical EditSplit $MYVIMRC<CR>', {noremap = true}},
    {'<Leader>el', '<Cmd>vertical EditSplit '..vimconf..'/local.lua<CR>', {noremap = true}},
    {'<Leader>ec', "'<Cmd>vertical EditConfig colors '.g:colors_name.'<CR>'", {noremap = true, expr = true}},
    {'<Leader>ef', '<Cmd>vertical EditConfig ftplugin<CR>', {noremap = true}},
    {'<Leader>es', '<Cmd>vertical EditConfig syntax<CR>', {noremap = true}},
    {'<Leader>ss', '<Cmd>syntax sync fromstart<CR>', {noremap = true}},

    {'ga', '<Plug>(UnicodeGA)'},
    {'<Leader>gs', '<Cmd>Gstatus<CR>', {noremap = true}},
    {'<Leader>gb', '<Cmd>leftabove Gblame<CR><C-W>p', {noremap = true}},
    {'<Leader>gl', '<Cmd>Gllog!<CR>', {noremap = true}},
    {'<Leader>gd', '<Cmd>Gvdiff<CR>', {noremap = true}},
    {'<Leader>gw', '<Cmd>Gwrite<CR>', {noremap = true}},
  },
  insert = {
    {'<CR>', '<C-G>u<CR>', {noremap = true}},
    {'<C-W>', '<C-G>u<C-W>', {noremap = true}},
    {'<C-U>', '<C-G>u<C-U>', {noremap = true}},

    {'<C-Space>', 'compe#complete()', {noremap = true, expr = true, silent = true}},
    {'<CR>', "compe#confirm({ 'keys': '<Plug>delimitMateCR', 'mode': '' })", {noremap = true, expr = true, silent = true}},
    {'<C-y>', "compe#confirm('<C-y>')", {noremap = true, expr = true, silent = true}},
    {'<C-e>', "compe#close('<C-e>')", {noremap = true, expr = true, silent = true}},
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

vim.cmd [[
  autocmd vimrc FileType vim setlocal keywordprg=:help
  autocmd vimrc FileType man setlocal nolist noexpandtab sw=8 ts=8
  autocmd vimrc FileType gitcommit,text,markdown,pandoc,html, setlocal spell
  if executable('hindent')
    autocmd vimrc FileType haskell setlocal equalprg=hindent
  endif
]]

-- Projects
vim.opt.tagcase = 'smart'
vim.opt.tags = {'./tags;', 'tags'}
vim.opt.sessionoptions:remove {'curdir', 'options'}
vim.opt.sessionoptions:append {'localoptions', 'unix', 'sesdir'}

local gitroot = vim.fn.systemlist('git rev-parse --show-toplevel')[1] or ''
if vim.v.shell_error == 0 and string.len(gitroot) > 0 then
  vim.opt.path:append(gitroot .. '/**')
  vim.opt.tags:append(gitroot .. '/.git/tags')
end

vim.cmd [[
  autocmd vimrc FileType * let &l:tags = &tags.','.expand(stdpath('data').'/tags/').&ft
]]

-- Plugins
vim.g.delimitMate_expand_space = 1
vim.g.delimitMate_expand_cr = 1
vim.g.delimitMate_jump_expansion = 1

vim.g.EditorConfig_disable_rules = {'trim_trailing_whitespace'}

vim.g.netrw_home = vimdata
vim.g.netrw_hide = 1
vim.g.netrw_list_hide = [[\(^\|\s\s\)\zs\.\S\+]]
vim.g.netrw_sizestyle = 'H'
vim.g.netrw_sort_options = 'i'

vim.g.signify_priority = 5
vim.g.signify_vcs_list = {'git'}

vim.g.vsnip_snippet_dir = vimconf..'/vsnip'

-- Completion
require 'compe'.setup {
  source = {
    buffer = true,
    path = true,
    nvim_lsp = true,
    vsnip = true,
  },
}

-- Telescope
require 'telescope'.setup {
  defaults = require 'telescope.themes'.get_ivy({}),
}

-- LSP
require 'lsp_progress'.register_progress()

local lsp = require 'lspconfig'
local function lsp_on_attach(client, bufnr)
  local function set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end
  local function set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
  -- if exists('+tagfunc')
  --   setlocal tagfunc=lsp#tagfunc
  -- endif

  local opts = {noremap = true}
  set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  set_keymap('n', 'gd', "<cmd>lua require'telescope.builtin'.lsp_definitions()<CR>", opts)
  set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  set_keymap('n', 'gi', "<cmd>lua require'telescope.builtin'.lsp_implementations()<CR>", opts)
  set_keymap('n', 'gr', "<cmd>lua require'telescope.builtin'.lsp_references()<CR>", opts)
  set_keymap('n', 'gs', "<cmd>lua require'telescope.builtin'.lsp_workspace_symbols()<CR>", opts)
  set_keymap('n', 'gy', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  set_keymap('n', '[g', '<cmd>lua vim.lsp.diagnostics.goto_prev()<CR>', opts)
  set_keymap('n', ']g', '<cmd>lua vim.lsp.diagnostics.goto_next()<CR>', opts)

  vim.cmd [[
    command! -buffer LspRename lua vim.lsp.buf.rename()

    augroup lsp_buf
      autocmd! * <buffer>
      autocmd BufEnter <buffer> lua vim.lsp.diagnostic.set_loclist({open_loclist = false})
    augroup END
  ]]

  if client.resolved_capabilities.document_formatting then
    vim.cmd [[
      command! -buffer Format lua vim.lsp.buf.formatting()
      autocmd lsp_buf BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync(nil, 2000)
    ]]
  end
  if client.resolved_capabilities.document_highlight then
    vim.cmd [[
      autocmd lsp_buf InsertEnter,BufLeave,CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      autocmd lsp_buf CursorHold <buffer> lua vim.lsp.buf.document_highlight()
    ]]
  end
end

local server_configs = {
  lua = require 'lua-dev'.setup({}),
  efm = {
    init_options = {
      documentFormatting = true,
      codeAction = true,
    },
    filetypes = {'vim', 'sh', 'markdown', 'yaml', 'fish'},
  },
}

local function setup_servers()
  require 'lspinstall'.setup()

  local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
  lsp_capabilities.textDocument.completion.completionItem.snippetSupport = true
  lsp_capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
      'documentation',
      'detail',
      'additionalTextEdits',
    }
  }

  local servers = require 'lspinstall'.installed_servers()
  table.insert(servers, 'rust_analyzer')
  table.insert(servers, 'clangd')
  table.insert(servers, 'efm')

  for _, server in pairs(servers) do
    local config = server_configs[server] or {}
    config.capabilities = lsp_capabilities
    config.on_attach = lsp_on_attach
    lsp[server].setup(config)
  end
end

setup_servers()
require 'lspinstall'.post_install_hook = function()
  setup_servers()
end

local function status_line_progress()
  local progress = require'lsp_progress'.get_progress()
  if vim.tbl_isempty(progress) then
    return ''
  end

  progress = progress[#progress]
  local message = (progress.message and (' '..progress.message)) or ''
  local percent = (progress.percentage and (' '..progress.percentage..'%%')) or ''
  return string.format('%%<%s: %s%s%s', progress.server, progress.title, message, percent)
end

-- Treesitter
require 'nvim-treesitter.configs'.setup {
  ensure_installed = 'maintained',
  highlight = {
    enable = true,
  },
}

-- lualine
require 'lualine'.setup {
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
    lualine_z = {{'location'}, {'diagnostics', sources = {'nvim_lsp'}, sections = {'error', 'warn'}, color = 'ErrorBar'}},
  },
  extensions = {'quickfix'},
}

vim.cmd [[
  autocmd vimrc User LspDiagnosticsChanged lua vim.lsp.diagnostic.set_loclist({open_loclist = false})
  autocmd vimrc User LspProgressUpdated redrawstatus
]]

LOCAL.finish()
