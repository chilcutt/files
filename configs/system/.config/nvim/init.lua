--------------------------------------------------------------------------------
-- Install packer and plugins
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  -- Waiting for https://github.com/wbthomason/packer.nvim/pull/1057
  -- vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
  vim.fn.execute("!git clone https://github.com/stevearc/packer.nvim --branch stevearc-git-env " .. install_path)
  vim.cmd([[packadd packer.nvim]])
end

require("packer").startup({function(use)
  use { "stevearc/packer.nvim", branch = "stevearc-git-env" } -- Package manager

  use { "L3MON4D3/LuaSnip", requires = { "saadparwaiz1/cmp_luasnip" } }           -- Snippet Engine and Snippet Expansion
  use { "airblade/vim-gitgutter" }           -- display git status in signcolumn
  use { "altercation/vim-colors-solarized" } -- load solarized colorscheme
  use { "benmills/vimux" }                   -- integrate vim with tmux
  use { "hrsh7th/nvim-cmp", requires = { "hrsh7th/cmp-nvim-lsp" } }               -- Autocompletion
  use { "jose-elias-alvarez/null-ls.nvim", requires = { 'nvim-lua/plenary.nvim' } }  -- connect non-lsp sources to lsp (e.g. prettier, eslint, etc.)
  use { "jremmen/vim-ripgrep" }              -- integration with ripgrep, support for :Rg
  use { "junegunn/fzf" }                     --  base fzf integration repository, required by fzf.vim
  use { "junegunn/fzf.vim" }                 -- better vim support for fzf
  use { "neovim/nvim-lspconfig" }            -- Configurations for builtin lsp
  use { "onsails/lspkind-nvim" }                                                     -- Snazzy LSP icons (requires patched font) 
  use { "tpope/vim-commentary" }             -- comment out blocks of lines
  use { "tpope/vim-fugitive" }               -- git integration
  use { "tpope/vim-rhubarb" }                -- github-specific git integration
  use { "vim-scripts/ZoomWin" }              -- ctrl+w o to zoom

  if is_bootstrap then
    require("packer").sync()
  end
end, config = {
  git = {
    env = {
      -- This is required to make git operations work on remote devboxes
      GIT_CONFIG_NOSYSTEM = "1"
    }
  }
}})

-- When we are bootstrapping a configuration, it doesn't
-- make sense to execute the rest of the init.lua.
--
-- Restart nvim, and then it will work.
if is_bootstrap then
  print("==================================")
  print("    Plugins are being installed")
  print("    Wait until Packer completes,")
  print("       then restart nvim")
  print("==================================")
  return
end

-- Automatically source and re-compile packer whenever you save this init.lua
local packer_group = vim.api.nvim_create_augroup("Packer", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
  command = "source <afile> | PackerCompile",
  group = packer_group,
  pattern = vim.fn.expand("$MYVIMRC"),
})
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Appearance
--
vim.cmd("colorscheme solarized")
vim.cmd("highlight ColorColumn ctermbg=black")
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

vim.g.mapleader = " " -- Set leader to spacebar
nmap("<leader>w", ":w<cr>")
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

nmap("<leader>t", ":tabnew<cr>")

nmap("<leader>F", ":Find<space>") -- Start fzf search of contents, TODO- swtich to CR?
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
map("", "<leader>gs", ":Git<cr>")
map("", "<leader>gb", ":Git blame<cr>")
map("", "<leader>gd", ":Git diff<cr>")
map("", "<leader>gv", ":Gvdiffsplit<cr>")
map("", "<leader>ga", ":Git add -p<cr>")
map("", "<leader>gc", ":Git commit<cr>")
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- vim-rhubarb
map("", "<leader>go", ":GBrowse<cr>") -- open file in browser at Github, also works with visual mode
map("", "<leader>gO", ":GBrowse <cword><cr>") -- open object in browser at Github, useful for commit sha
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
local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Set up typescript lsp
require("lspconfig")["tsserver"].setup({
  on_attach = on_attach,
  capabilities = capabilities,
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
