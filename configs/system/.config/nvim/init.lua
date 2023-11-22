if vim.g.vscode then
  return
end

--------------------------------------------------------------------------------
-- Install lazyvim and plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

vim.g.mapleader = " " -- Set leader to spacebar
vim.g.maplocalleader = " " -- Set leader to spacebar

require("lazy").setup({
  'git@git.corp.stripe.com:nms/nvim-lspconfig-stripe.git' -- Stripe-specific LSP configs
  { "L3MON4D3/LuaSnip", dependencies = { "saadparwaiz1/cmp_luasnip" } },           -- Snippet Engine and Snippet Expansion
  "airblade/vim-gitgutter",           -- display git status in signcolumn
  "altercation/vim-colors-solarized", -- load solarized colorscheme
  "benmills/vimux",                   -- integrate vim with tmux
  "hrsh7th/cmp-buffer", -- nvim-cmp completions for file buffer
  "hrsh7th/cmp-nvim-lua", -- nvim-cmp completions for nvim lua
  "hrsh7th/cmp-path", --nvim-cmp completions for file path
  { "hrsh7th/nvim-cmp", dependencies = { "hrsh7th/cmp-nvim-lsp" } },               -- Autocompletion
  { "jose-elias-alvarez/null-ls.nvim", dependencies = { 'nvim-lua/plenary.nvim' } },  -- connect non-lsp sources to lsp (e.g. prettier, eslint, etc.)
  "jremmen/vim-ripgrep",              -- integration with ripgrep, support for :Rg
  "junegunn/fzf",                     --  base fzf integration repository, required by fzf.vim
  "junegunn/fzf.vim",                 -- better vim support for fzf
  "neovim/nvim-lspconfig",            -- Configurations for builtin lsp
  "onsails/lspkind-nvim",             -- Snazzy LSP icons (requires patched font)
  "tpope/vim-commentary",             -- comment out blocks of lines
  "tpope/vim-fugitive",               -- git integration
  "tpope/vim-rhubarb",                -- github-specific git integration
  "vim-scripts/ZoomWin",              -- ctrl+w o to zoom
})
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Appearance
--
vim.cmd("colorscheme solarized")
vim.cmd("set background=light")
vim.cmd("highlight ColorColumn ctermbg=lightgray")
vim.cmd("let &colorcolumn=join(range(81,999),',')")

-- Workaround a problem with solarized and vim-gitgutter.
-- https://github.com/airblade/vim-gitgutter/issues/696
vim.cmd("highlight! link SignColumn LineNr")
vim.cmd("autocmd ColorScheme * highlight! link SignColumn LineNr")
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Options
--
vim.opt.cmdheight = 2                                              -- increase the space for commands so the window doesn't feel jumpy
vim.opt.expandtab = true                                           -- when pressing tab, insert spaces
vim.opt.ignorecase = true                                          -- perform case-insensitive searches
vim.opt.list = true                                                -- show whitespace characters in listchars
vim.opt.listchars = "tab:> ,trail:.,extends:>,precedes:<,nbsp:+"   -- mark tabs, trailing spaces, non-breakable spaces
vim.opt.nrformats = "alpha,hex,bin"                                -- set alpha, 0x, and 0b to be incremented, disable octal because decimal is often zero-padded
vim.opt.number = true                                              -- display the line number in before each line
vim.opt.shiftwidth = 2                                             -- set indentation with >> to 2
vim.opt.signcolumn = "yes"                                         -- always show the signcolumn so it doesn't move when activated, vim-gitgutter & ale
vim.opt.smartcase = true                                           -- when a search query has a capital letter, do an exact match search
vim.opt.softtabstop = 2                                            -- set each tab to insert 2 spaces with expandtab
vim.opt.statusline = "%F"                                          -- display the filename in the statusline
vim.opt.tabstop = 2                                                -- display tabs as 2 spaces wide
vim.opt.updatetime = 100                                           -- write swp faster, to trigger faster git status reaction, vim-gitgutter
vim.opt.wrap = false                                               -- default to not wrapping long lines
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Mappings
--
function map(mode, shortcut, command)
  vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true })
end

function nmap(shortcut, command)
  map("n", shortcut, command)
end

nmap("<leader>w", ":w<cr>")
nmap("<leader>W", ":noautocmd w<cr>") -- Save without formatting
nmap("<leader>q", ":q<cr>")
nmap("<leader>x", ":x<cr>")
nmap("<leader>o", "o<esc>")
nmap("<leader>O", "O<esc>")
map("", "<leader>y", "\"+y")
map("", "<leader>p", "\"+p")
map("i", "jk", "<esc>") -- set jk to escape to normal mode
nmap("<leader>`", ":let &bg=(&bg=='light'?'dark':'light')<cr>") -- Toggle between light/dark background

nmap("<leader>v", ":vsp<cr><C-w>l")
nmap("<leader>s", ":sp<cr><C-w>j")
nmap("<leader><space>", "<C-w><C-w>")
nmap("<leader>h", "<C-w>h")
nmap("<leader>j", "<C-w>j")
nmap("<leader>k", "<C-w>k")
nmap("<leader>l", "<C-w>l")

nmap("<leader>n", ":n<cr>")
nmap("<leader>N", ":N<cr>")
nmap("<leader>cn", ":cnext<cr>")
nmap("<leader>cp", ":cprevious<cr>")

nmap("<leader>t", ":tabnew<cr>")

nmap("<leader>F", ":Find<space>") -- Start fzf search of contents, TODO- swtich to CR?
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- vimux
nmap("<leader>bb", ":VimuxCloseRunner<cr>")
nmap("<leader>bc", ":VimuxPromptCommand<cr>")
nmap("<leader>br", ":VimuxRunLastCommand<cr>")

-- local ruby_runner = "bundle exec rspec"
local ruby_runner = "pay test"
-- local javascript_runner = "yarn run jest"
local javascript_runner = "pay js:run jest"
local javascript_debug_runner = "node --inspect-brk node_modules/.bin/jest --runInBand"

local javascript_filetypes = {
  javascript = true,
  typescript = true,
  typescriptreact = true,
}

function RunTestFile()
  if javascript_filetypes[vim.bo.filetype] then
    vim.cmd([[call VimuxRunCommand("]] .. javascript_runner .. [[" . " " . bufname("%"))]])
  elseif vim.bo.filetype == "ruby" then
    vim.cmd([[call VimuxRunCommand("]] .. ruby_runner .. [[" . " " . bufname("%"))]])
  end
end

nmap("<leader>rf", "<cmd>lua RunTestFile()<cr>")

function RunTestLine()
  if javascript_filetypes[vim.bo.filetype] then
    vim.cmd([[call VimuxRunCommand("]] .. javascript_runner .. [[" . " " . bufname("%"))]])
  elseif vim.bo.filetype == "ruby" then
    vim.cmd([[call VimuxRunCommand("]] .. ruby_runner .. [[" . " " . bufname("%") . " -l " . line("."))]])
  end
end

nmap("<leader>rs", "<cmd>lua RunTestLine()<cr>")
-- local function RunTestLine
--   if &filetype ==# "javascript"
--     call VimuxRunCommand(s:javascript_runner . " " . bufname("%"))
--   elseif &filetype ==# "ruby"
--     call VimuxRunCommand(s:ruby_runner . " " . bufname("%") . ":" . line("."))
--   endif
-- endfunction

-- function RunTestDebugger()
--   if &filetype ==# "javascript"
--     call VimuxRunCommand(s:javascript_debug_runner . " " . bufname("%"))
--   endif
-- endfunction

-- function RunTestWatch()
--   if &filetype ==# "javascript"
--     call VimuxRunCommand(s:javascript_runner . " " . bufname("%") . " --watch")
--   endif
-- endfunction
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- fzf.vim
vim.g.fzf_layout = { down = "~20%" }

nmap("<C-P>", ":Files<cr>") -- Start fzf search of files
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- vim-ripgrep
vim.g.rg_highlight = 1 -- Highlight matches in results and opened file

nmap("<leader>f", ":Rg<space>") -- Start search with ripgrep
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- vim-commentary
map("x", "<leader>/", "<Plug>Commentary<cr>")
nmap("<leader>/", "<Plug>CommentaryLine<cr>")
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- vim-fugitive
map("", "<leader>GS", ":Git<cr>")
map("", "<leader>GB", ":Git blame<cr>")
map("", "<leader>GD", ":Git diff<cr>")
map("", "<leader>GV", ":Gvdiffsplit<cr>")
map("", "<leader>GA", ":Git add -p<cr>")
map("", "<leader>GC", ":Git commit<cr>")
map("", "<leader>GR", ":Git reset head<cr>")
-- TODO - create command to create a new branch
-- https://alpha2phi.medium.com/neovim-for-beginners-user-interface-568879ecfd6d
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- vim-rhubarb
map("", "<leader>GO", ":GBrowse<cr>") -- open file in browser at Github, also works with visual mode
map("", "<leader>GH", ":GBrowse <cword><cr>") -- open object in browser at Github, useful for commit sha
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- lsp config
local autoformat_group = vim.api.nvim_create_augroup("LspAutoformat", { clear = true })

-- Automatically format on save
local on_attach = function(client, bufnr)
  if
    client.server_capabilities.documentFormattingProvider
  then
    -- Remove prior autocmds so this only triggers once
    vim.api.nvim_clear_autocmds({
      group = autoformat_group,
      buffer = bufnr,
    })
    vim.api.nvim_create_autocmd("BufWritePre", {
      callback = function()
        vim.lsp.buf.format({
          bufnr = bufnr
        })
      end,
      group = autoformat_group,
      buffer = bufnr,
    })
  end
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- nvim-lspconfig
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Set up typescript lsp
require("lspconfig")["tsserver"].setup({
  on_attach = on_attach,
  capabilities = capabilities,
})
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- nvim-lspconfig-stripe
require("lspconfig_stripe")

require("lspconfig").payserver_sorbet.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  flags = {
    debounce_text_changes = 200,
  },
})
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- null-ls.nvim
local util = require("lspconfig.util")
local function eslint_cwd(params)
  return util.root_pattern(".eslintrc.*")(params.bufname)
end

local null_ls = require("null-ls")
null_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  sources = {
    null_ls.builtins.formatting.prettierd,

    null_ls.builtins.code_actions.eslint_d.with({
      cwd = eslint_cwd
    }),
    null_ls.builtins.diagnostics.eslint_d.with({
      cwd = eslint_cwd
    }),
    null_ls.builtins.formatting.eslint_d.with({
      cwd = eslint_cwd
    }),

    null_ls.builtins.diagnostics.stylelint,
    null_ls.builtins.formatting.stylelint,
  },
})
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- nvim-cmp, LuaSnip, lspkind-nvim
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  completion = {
    autocomplete = false, -- Disable automatic autocomplete, use manual trigger
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      elseif cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  formatting = {
    format = require("lspkind").cmp_format({
      mode = "text",
      menu = {
        buffer = "[buf]",
        nvim_lsp = "[LSP]",
        nvim_lua = "[api]",
        path = "[path]",
        luasnip = "[snip]",
      },
    }),
  },
  sources = {
    { name = "nvim_lua" }, -- Shows suggestions for lua
    { name = "nvim_lsp" }, -- Shows suggestions based on the response of a language server
    { name = "luasnip" }, -- Suggests available snippets and expands them if chosen
    { name = "buffer", keyword_length = 5 }, -- Suggests words found in the current buffer
  },
})

-- Toggle insert mode autocompletion on/off
vim.g.nvim_cmp_autocomplete_enabled = false
function toggleAutocomplete()
  vim.g.nvim_cmp_autocomplete_enabled = not vim.g.nvim_cmp_autocomplete_enabled
  if vim.g.nvim_cmp_autocomplete_enabled then
    cmp.setup({
      completion = {
        autocomplete = { require('cmp.types').cmp.TriggerEvent.TextChanged }
      }
    })
  else
    cmp.setup({
      completion = {
        autocomplete = false
      }
    })
  end
end

function FixPrevError()
  vim.diagnostic.goto_prev()
  vim.api.nvim_feedkeys("zz", "n", true)
  vim.lsp.buf.code_action()
end

function FixNextError()
  vim.diagnostic.goto_next()
  vim.api.nvim_feedkeys("zz", "n", true)
  vim.lsp.buf.code_action()
end

map("i", "<C-Space>", "<cmd>lua require('cmp').complete()<cr>") -- Trigger completion in insert-mode with ctrl+space
nmap("<leader>LA", "<cmd>lua vim.lsp.buf.code_action()<cr>") -- Trigger code action under cursor
nmap("<leader>LP", "<cmd>lua FixPrevError()<cr>") -- Go to previous lsp issue and launch code action
nmap("<leader>LN", "<cmd>lua FixNextError()<cr>") -- Go to next lsp issue and launch code action
nmap("<leader>LC", "<cmd>lua toggleAutocomplete()<cr>") -- Toggle autocomplete
nmap("<leader>LR", "<cmd>lua vim.lsp.buf.rename()<cr>") -- Rename references

nmap("<leader>gd", "<cmd>lua vim.lsp.buf.definition()<cr>") -- Jump to definition (ctrl+t to go back)
nmap("<leader>gr", "<cmd>lua vim.lsp.buf.references()<cr>") -- Open references

nmap("<leader>K", "<cmd>lua vim.lsp.buf.hover()<cr>") -- Show hover documentation
--------------------------------------------------------------------------------
