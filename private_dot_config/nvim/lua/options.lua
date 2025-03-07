local utils = require("utils")
local opt = vim.opt

-- Variables
vim.g.python3_host_prog = vim.env.HOME .. "/venvs/neovim/bin/python"

-- Colors
opt.termguicolors = true

-- Split direction
opt.splitbelow = true
opt.splitright = true

-- Resize sign column limit
opt.signcolumn = "yes:2"

-- Color line/column
opt.colorcolumn = "90"
opt.cursorline = true
-- opt.cmdheight = 0
opt.splitkeep = "topline"

-- Completion menu
opt.pumheight = 20
opt.pumblend = 10
opt.completeopt = "menu,menuone,noselect,popup,fuzzy"

-- Set encoding
opt.encoding = "utf-8"

-- Hidden buffers to switch buffers without saving
opt.hidden = true

-- Enable mouse support
opt.mouse = "a"
opt.mousemodel = "extend"

-- Auto read file changes
opt.autoread = true

-- Make last window always have a status line
opt.laststatus = 3

-- Indent
opt.tabstop = 4 -- visual spaces that a tab represents
opt.softtabstop = 4 -- editing spaces that a tab (and its backspace) represent
opt.shiftwidth = 4 -- spaces used in autoindent (<< and >>)
opt.expandtab = true -- turn spaces into tabs?
opt.autoindent = true
opt.smartindent = true

-- Wrap behavior
opt.wrap = false

-- Line numbers
opt.number = true

-- Folding
opt.foldlevel = 99
opt.foldenable = true
opt.foldtext = ""
-- could do: https://github.com/neovim/neovim/pull/30164#issuecomment-2315421660

-- Search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.wrapscan = true

-- Faster update time
opt.updatetime = 200
opt.termsync = false

-- Scroll offsets
opt.scrolloff = 10
opt.sidescrolloff = 4

-- Fillchars
opt.fillchars = "eob: ,fold: ,foldopen:,foldsep: ,foldclose:,diff:╱,msgsep:─"
opt.list = true
-- for some reason the help menu shows ^I if tab is not explicitly "  "
opt.listchars = { tab = "  ", space = " ", nbsp = " " }

-- Jumplist
opt.jumpoptions = "stack"

-- Use filetype in lua
vim.filetype.add({
  filename = {
    ["MLproject"] = "yaml",
  },
  pattern = {
    [".*%.json%.cfg"] = "json",
  },
})

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Diff options
-- oddly enough, this option isn't set as a table
opt.diffopt = "filler,vertical,closeoff,internal,indent-heuristic,algorithm:patience,linematch:100"

-- Highlight text on yank
utils.create_augroup("highlight_on_yank", {
  { "TextYankPost", "*", "silent!", "lua vim.highlight.on_yank({ higroup='IncSearch', timeout=150 })" },
})

-- Autocommands
-- don't list quickfix buffers in tabline
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.opt_local.buflisted = false
  end,
})

-- Diagnostics
vim.diagnostic.config({
  underline = true,
  virtual_text = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "󱈸",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
  update_in_insert = false,
  severity_sort = false,
  float = {
    border = "rounded",
    format = function(diagnostic)
      local info = {
        string.format("󰍩 [%s]", diagnostic.message)
      }

      if diagnostic.code ~= nil then
        table.insert(info, string.format(" [%s]", diagnostic.code))
      end

      if diagnostic.source ~= nil then
        table.insert(info, string.format("🗲 [%s]", diagnostic.source))
      end

      return table.concat(info, " ")
    end,
    suffix = "",
  },
})


-- EditorConfig
-- don't change textwidth, and change colorcolumn instead
require("editorconfig").properties.max_line_length = function(bufnr, val, opts)
  vim.api.nvim_set_option_value("colorcolumn", string.format("%s", val), {})
end
