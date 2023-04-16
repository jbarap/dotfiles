local set_keymap = vim.keymap.set

-- Set mapleader to space
vim.g.mapleader = " "

--        Mappings
-- ──────────────────────────────
-- Exit insert
set_keymap("i", "jk", "<ESC>", { desc = "Exit insert mode" })
set_keymap("i", "JK", "<ESC>", { desc = "Exit insert mode" })

set_keymap("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit insert mode from terminal" })

-- Buffer nagivation
set_keymap("n", "<Leader>b.", "<cmd>bnext<CR>", { desc = "Buffer next" })
set_keymap("n", "<Leader>b,", "<cmd>bprev<CR>", { desc = "Buffer prev" })
set_keymap("n", "<Leader>bd", require("utils").buffer_delete, { desc = "Buffer delete" })

-- Tab navigation
set_keymap("n", "<Leader>t.", "<cmd>tabnext<CR>", { desc = "Tab next" })
set_keymap("n", "<Leader>t,", "<cmd>tabprev<CR>", { desc = "Tab prev" })
set_keymap("n", "<Leader>tn", "<cmd>tabnew<CR>", { desc = "Tab new" })

-- Screen navigation
set_keymap({ "n", "v" }, "<A-j>", "<C-d>", { remap = true, desc = "Move screen up" })
set_keymap({ "n", "v" }, "<A-S-j>", "<C-e>", { remap = false, desc = "Move screen up (one line)" })
set_keymap({ "n", "v" }, "<A-k>", "<C-u>", { remap = true, desc = "Move screen down" })
set_keymap({ "n", "v" }, "<A-S-k>", "<C-y>", { remap = false, desc = "Move screen down (one line)" })

-- Goto window above/below/left/right
set_keymap("n", "<C-h>", "<cmd>wincmd h<CR>", { desc = "Win move to left" })
set_keymap("n", "<C-j>", "<cmd>wincmd j<CR>", { desc = "Win move down" })
set_keymap("n", "<C-k>", "<cmd>wincmd k<CR>", { desc = "Win move up" })
set_keymap("n", "<C-l>", "<cmd>wincmd l<CR>", { desc = "Win move to right" })

-- QuickFix
set_keymap("n", "]q", "<cmd>cn<CR>", { desc = "Quickfix next" })
set_keymap("n", "[q", "<cmd>cp<CR>", { desc = "Quickfix prev" })
set_keymap("n", "<Leader>qq", require("utils").toggle_quickfix, { desc = "Quickfix toggle" })

-- Diff
set_keymap({ "n", "v" }, "<Leader>dp", "<cmd>diffput<CR>", { desc = "Diff put" })
set_keymap({ "n", "v" }, "<Leader>dg", "<cmd>diffget<CR>", { desc = "Diff get" })

-- Vim config
set_keymap("n", "<Leader>ve", "<cmd>edit $MYVIMRC<CR>", { desc = "Vim edit config" })

-- Smart dd
set_keymap({ "n" }, "dd", function()
  if vim.api.nvim_get_current_line():match("^%s*$") then
    return '"_dd'
  else
    return "dd"
  end
end, { remap = false, expr = true }, { desc = "Delete line (don't yank if empty)" })

set_keymap("v", "<C-j>", ":m '>+1<CR>gv=gv")
set_keymap("v", "<C-k>", ":m '<-2<CR>gv=gv")

-- Center screen on cursor move
set_keymap("n", "<C-o>", "<C-o>zz", { remap = false }, { desc = "Jumplist prev" })
set_keymap("n", "<C-i>", "<C-i>zz", { remap = false }, { desc = "Jumplist next" })
set_keymap("n", "n", "nzz", { remap = false }, { desc = "Next search result" })
set_keymap("n", "N", "Nzz", { remap = false }, { desc = "Prev search result" })

-- Replace
set_keymap("n", "<Leader>cs", ":%s/", { desc = "Code substitute" })
set_keymap("v", "<Leader>cs", ":s/", { desc = "Code substitute (within selection)" })

-- Convenience
set_keymap("n", "U", "<C-r>", { desc = "Redo" })

set_keymap({ "n", "v" }, "<Leader>y", '"+y', { desc = "Yank to clipboard" })
set_keymap("n", "<Leader>Y", '"+y$', { desc = "Yank to clipboard ('til EOL)" })

set_keymap("n", "gp", "a<CR><Esc>PkJJxx", { desc = "Paste inline" })

set_keymap("n", "<Leader><CR>", "<cmd>nohlsearch<cr>", { desc = "Clear hlsearch" })
set_keymap("v", "<Leader><CR>", "<Esc>", { desc = "Exit visual mode" })

set_keymap("n", "<Leader>fw", require("utils").search_word_under_cursor, { desc = "Find word under cursor" })
set_keymap("x", "<Leader>fw", require("utils").search_selected_word, { desc = "Find selected word" })

set_keymap("s", "<BS>", "<BS>a", { desc = "Delete and insert" })

set_keymap("", "<S-h>", "^", { desc = "End on line" })
set_keymap("", "<S-l>", "$", { desc = "Beginning of line" })

set_keymap("n", "<M-o>", "<cmd>keepjumps normal <C-^><CR>", { desc = "Buffer pair" })

--        Commands
-- ──────────────────────────────
-- Save files with sudo
vim.api.nvim_create_user_command("WSudo", function() require("utils").sudo_write() end, {})

