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

-- Windows
-- TODO: consider adding this if plugins handle it nicely
opt.winborder = "single"

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
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- If LSP client supports folding, use that one over treesitter
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then return end
    if client:supports_method('textDocument/foldingRange') then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
    end
  end,
})

-- Custom foldtext highlighted by treesitter + line numbers
local function fold_virt_text(result, s, lnum, coloff)
  if not coloff then
    coloff = 0
  end
  local text = ""
  local hl
  for i = 1, #s do
    local char = s:sub(i, i)
    local hls = vim.treesitter.get_captures_at_pos(0, lnum, coloff + i - 1)
    local _hl = hls[#hls]
    if _hl then
      local new_hl = "@" .. _hl.capture
      if new_hl ~= hl then
        table.insert(result, { text, hl })
        text = ""
        hl = nil
      end
      text = text .. char
      hl = new_hl
    else
      text = text .. char
    end
  end
  table.insert(result, { text, hl })
end

function _G.custom_foldtext()
  local result = {}

  -- Insert start line highlighted by treesitter
  local start_line_str = vim.fn.getline(vim.v.foldstart):gsub("\t", string.rep(" ", vim.o.tabstop))
  fold_virt_text(result, start_line_str, vim.v.foldstart - 1)
  table.insert(result, { " ... ", "Delimiter" })

  -- Insert number of lines folded (right-aligned)
  local buffer_lines = vim.api.nvim_buf_line_count(0)
  local folded_lines = vim.v.foldend - vim.v.foldstart

  local suffix = (" 󰁂 %d (%d%%)"):format(folded_lines, folded_lines / buffer_lines * 100)
  local suffix_width = vim.fn.strdisplaywidth(suffix)

  local target_width
  local text_width = vim.opt.textwidth["_value"]
  local colorcolumn = vim.opt.colorcolumn["_value"]
  if text_width ~= 0 and text_width then
    target_width = text_width
  elseif colorcolumn ~= 0 and colorcolumn then
    target_width = colorcolumn
  else
    target_width = vim.api.nvim_win_get_width(0)
  end

  local start_line_width = vim.fn.strdisplaywidth(start_line_str)

  -- 5 is the " ... " length
  suffix = (" "):rep(math.max(0, target_width - suffix_width - start_line_width - 5)) .. suffix

  table.insert(result, { suffix, "MoreMsg" })
  return result
end

vim.opt.foldtext = "v:lua.custom_foldtext()"


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
