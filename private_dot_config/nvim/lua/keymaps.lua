local set_keymap = vim.keymap.set

-- Set mapleader to space
vim.g.mapleader = " "
vim.g.maplocalleader = ","

--        Mappings
-- ──────────────────────────────
-- Exit insert
set_keymap("i", "jk", "<ESC>", { desc = "Exit insert mode" })
set_keymap("i", "JK", "<ESC>", { desc = "Exit insert mode" })

-- Indent
set_keymap("i", "<S-Tab>", "<C-d>", { desc = "Remove an indent level", remap = true })


-- Buffer nagivation
set_keymap("n", "<Leader>b.", "<cmd>bnext<CR>", { desc = "Buffer next" })
set_keymap("n", "<Leader>b,", "<cmd>bprev<CR>", { desc = "Buffer prev" })
set_keymap("n", "<Leader>bd", require("utils").buffer_delete, { desc = "Buffer delete" })

-- Tab navigation
set_keymap("n", "<A->>", "<cmd>tabnext<CR>", { desc = "Tab next" })
set_keymap("n", "<A-<>", "<cmd>tabprev<CR>", { desc = "Tab prev" })
set_keymap("n", "<Leader>ta", "<cmd>tabnew<CR>", { desc = "Tab add" })
set_keymap("n", "<Leader>tx", "<cmd>tabclose<CR>", { desc = "Tab close" })
set_keymap("n", "<Leader>tmh", "<cmd>-tabmove<CR>", { desc = "Tab move left" })
set_keymap("n", "<Leader>tml", "<cmd>+tabmove<CR>", { desc = "Tab move right" })

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
set_keymap("n", "<Leader>qq", require("utils").toggle_quickfix, { desc = "Quickfix toggle" })

-- Diff
set_keymap({ "n", "v" }, "<Leader>dp", "<cmd>diffput<CR>", { desc = "Diff put" })
set_keymap({ "n", "v" }, "<Leader>dg", "<cmd>diffget<CR>", { desc = "Diff get" })
set_keymap({ "n", "v" }, "<Leader>dt", "<cmd>diffthis<CR>", { desc = "Diff this" })

-- Diagnostics
set_keymap("n", "<Leader>sl",  function() vim.diagnostic.open_float({ scope = "line", }) end, { desc = "Show diagnostics (line)" })
set_keymap("n", "gl",  function() vim.diagnostic.open_float({ scope = "line", }) end, { desc = "Show diagnostics (line)" })
set_keymap("n", "gK",  function()
  local virt_lines = vim.diagnostic.config().virtual_lines
  if virt_lines == false then
    virt_lines = { current_line = true }
  else
    virt_lines = false
  end
  vim.diagnostic.config({ virtual_lines = virt_lines })
  end, { desc = "Toggle diagnostics in virtual lines" }
)

local function jump_with_virt_line(jump_count)
  -- prevent autocmd for repeated jumps
  pcall(vim.api.nvim_del_augroup_by_name, "jumpWithVirtLineDiags")

  vim.diagnostic.jump({ count = jump_count })
  vim.diagnostic.config({ virtual_lines = { current_line = true } })

  -- deferred to not be triggered by the jump itself
  vim.defer_fn(function()
    vim.api.nvim_create_autocmd("CursorMoved", {
      desc = "User(once): Reset diagnostics virtual lines.",
      once = true,
      group = vim.api.nvim_create_augroup("jumpWithVirtLineDiags", {}),
      callback = function()
        vim.diagnostic.config({ virtual_lines = false })
      end,
    })
  end, 1)
end

set_keymap("n", "]d", function()
  -- vim.diagnostic.jump({count = 1, float = true})
  jump_with_virt_line(1)
end, { desc = "Next diagnostic" })
set_keymap("n", "[d", function()
  -- vim.diagnostic.jump({count = -1, float = true})
  jump_with_virt_line(-1)
end, { desc = "Prev diagnostic" })


-- Vim config
set_keymap("n", "<Leader>ve", "<cmd>edit $MYVIMRC<CR>", { desc = "Vim edit config" })

-- Smart dd
set_keymap({ "n" }, "dd", function()
  if vim.api.nvim_get_current_line():match("^%s*$") then
    return '"_dd'
  else
    return "dd"
  end
end, { remap = false, expr = true, desc = "Delete line (don't yank if empty)" } )

set_keymap("v", "<C-j>", ":m '>+1<CR>gv=gv")
set_keymap("v", "<C-k>", ":m '<-2<CR>gv=gv")

-- Replace
set_keymap("n", "<Leader>cs", ":%s/", { desc = "Code substitute" })
set_keymap("v", "<Leader>cs", ":s/", { desc = "Code substitute (within selection)" })

-- Convenience
set_keymap("n", "U", "<C-r>", { desc = "Redo" })

set_keymap({ "n", "v" }, "<Leader>y", '"+y', { desc = "Yank to clipboard" })
set_keymap("n", "<Leader>Y", '"+y$', { desc = "Yank to clipboard ('til EOL)" })

set_keymap("n", "gp", "a<CR><Esc>PkJJxx", { desc = "Paste inline" })

set_keymap("n", "<Leader>/", "<cmd>nohlsearch<cr>", { desc = "Clear hlsearch" })
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

