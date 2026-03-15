-- ╔══════════════════════════════════════════════════════════════╗
-- ║               Neovim Config                                 ║
-- ╚══════════════════════════════════════════════════════════════╝

-- Leader (must be before lazy.nvim)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ── Options ─────────────────────────────────────────────────
local o = vim.opt
o.encoding = "utf-8"
o.fileencoding = "utf-8"
o.history = 1000
o.undolevels = 1000
o.undofile = true
o.undodir = vim.fn.expand("~/.vim/undodir")
o.swapfile = false
o.backup = false
o.autoread = true
o.hidden = true
o.clipboard = "unnamed"
o.mouse = "a"
o.backspace = "indent,eol,start"
o.timeoutlen = 500
o.updatetime = 250

-- UI
o.number = true
o.relativenumber = true
o.cursorline = true
o.showmatch = true
o.matchtime = 2
o.scrolloff = 8
o.sidescrolloff = 8
o.signcolumn = "yes"
o.colorcolumn = "120"
o.laststatus = 2
o.showcmd = true
o.showmode = true
o.ruler = true
o.wildmenu = true
o.wildmode = "longest:list,full"
o.title = true
o.termguicolors = true

-- Search
o.hlsearch = true
o.incsearch = true
o.ignorecase = true
o.smartcase = true

-- Indentation
o.autoindent = true
o.smartindent = true
o.expandtab = true
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.shiftround = true

-- Splits
o.splitbelow = true
o.splitright = true

-- Netrw (fallback file explorer)
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 4
vim.g.netrw_altv = 1
vim.g.netrw_winsize = 25

-- ── Keymaps ─────────────────────────────────────────────────
local map = vim.keymap.set

-- Clear search
map("n", "<Esc>", ":nohlsearch<CR>", { silent = true })

-- Split navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- File operations
map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")
map("n", "<leader>x", ":x<CR>")

-- Buffers
map("n", "<leader>bn", ":bnext<CR>")
map("n", "<leader>bp", ":bprevious<CR>")
map("n", "<leader>bd", ":bdelete<CR>")
map("n", "<leader>bl", ":ls<CR>")

-- Tabs
map("n", "<leader>tn", ":tabnext<CR>")
map("n", "<leader>tp", ":tabprevious<CR>")
map("n", "<leader>tc", ":tabnew<CR>")

-- Netrw
map("n", "<leader>e", ":Lexplore<CR>")

-- Edit/source config
map("n", "<leader>ev", ":edit $MYVIMRC<CR>")
map("n", "<leader>sv", ":source $MYVIMRC<CR>")

-- Move lines in visual mode
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Centered scrolling
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "G", "Gzz")

-- Keep selection when indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Y yanks to end of line
map("n", "Y", "y$")

-- Quick save
map("n", "<C-s>", ":w<CR>")
map("i", "<C-s>", "<Esc>:w<CR>a")

-- ── Filetype ────────────────────────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "dockerfile" },
  callback = function() vim.bo.tabstop = 4; vim.bo.shiftwidth = 4; vim.bo.softtabstop = 4 end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function() vim.bo.tabstop = 4; vim.bo.shiftwidth = 4; vim.bo.softtabstop = 4; vim.bo.expandtab = false end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "make",
  callback = function() vim.bo.expandtab = false end,
})

-- Strip trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, pos)
  end,
})

-- Auto-create parent directories on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function() vim.fn.mkdir(vim.fn.expand("<afile>:p:h"), "p") end,
})

-- ── Bootstrap lazy.nvim ─────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  change_detection = { notify = false },
})
