local utils = require("utils")
local Highlight = utils.Highlight

---- dark color palette
local darker = "#111111"
local dark = "#131313"
local almost_dark = "#151515"
local mid_dark = "#191919"
local light_dark = "#202020"
local lighter_dark = "#252525"

if vim.g._colorscheme == "nightfox" or vim.g._colorscheme == "tokyonight" then
  --            neovim
  -- ──────────────────────────────
  -- Backgrounds
  Highlight("Normal"):set("guibg", dark):set("guifg", "#c9c9c9")
  Highlight("NormalNC"):set("guibg", dark)
  Highlight("EndOfBuffer"):set("guibg", dark)
  Highlight("TabLineFill"):set("guibg", dark)
  Highlight("DarkenedPanel"):set("guibg", darker)
  Highlight("DarkenedStatusline"):set("guibg", darker)
  Highlight("DarkenedStatuslineNC"):set("guibg", darker)

  -- Syntax
  Highlight("Search"):set("guibg", "#1c284a"):set("guifg", "NONE")
  Highlight("IncSearch"):set("guibg", "#42888a"):set("guifg", "NONE")
  Highlight("Substitute"):set("guibg", "#4d1d28"):set("guifg", "#c9c9c9")

  -- Treesitter
  Highlight("TSPunctSpecial"):set("guifg", "#89ddff")

  -- Diffs
  Highlight("DiffAdd"):set("guibg", "#212f25")
  Highlight("DiffText"):set("guibg", "#342917")
  Highlight("DiffChange"):set("guibg", "#1F2231")
  Highlight("DiffDelete"):set("guibg", "#37222C")

  -- folds
  Highlight("Folded"):set("guibg", "#1c202e"):set("guifg", "NONE")

  -- gitsigns
  Highlight("GitSignsAdd"):set("guibg", "NONE"):set("gui", "bold")
  Highlight("GitSignsChange"):set("guibg", "NONE"):set("gui", "bold")
  Highlight("GitSignsDelete"):set("guibg", "NONE"):set("gui", "bold")

  -- Sign column
  Highlight("SignColumn"):set("guibg", "NONE")
  Highlight("LineNr"):set("guibg", "NONE")

  -- Color column
  Highlight("ColorColumn"):set("guibg", almost_dark)
  Highlight("CursorLine"):set("guibg", almost_dark)

  -- floating windows
  Highlight("Pmenu"):set("guibg", light_dark)
  Highlight("PmenuSbar"):set("guibg", lighter_dark):set("guifg", "#ffffff")
  Highlight("NormalFloat"):set("guibg", mid_dark)
  Highlight("FloatBorder"):set("guibg", mid_dark)

  -- Lsp colors
  Highlight("DiagnosticDefaultHint"):set("guibg", "NONE")
  Highlight("DiagnosticDefaultWarning"):set("guibg", "NONE")
  Highlight("DiagnosticDefaultError"):set("guibg", "NONE")
  Highlight("DiagnosticVirtualTextInformation"):set("guibg", mid_dark)
  Highlight("DiagnosticVirtualTextWarning"):set("guibg", mid_dark)
  Highlight("DiagnosticVirtualTextError"):set("guibg", mid_dark)
  Highlight("DiagnosticVirtualTextHint"):set("guibg", mid_dark)

  -- Others
  Highlight("VertSplit"):set("guifg", light_dark)

  --            plugins
  -- ──────────────────────────────
  -- Barbar
  Highlight("BufferTabpageFill"):set("guibg", almost_dark)
  Highlight("BufferCurrent"):set("guibg", lighter_dark)
  Highlight("BufferCurrentSign"):set("guibg", lighter_dark)
  Highlight("BufferCurrentMod"):set("guibg", lighter_dark)
  Highlight("BufferInactive"):set("guibg", mid_dark)
  Highlight("BufferInactiveSign"):set("guibg", mid_dark)
  Highlight("BufferInactiveMod"):set("guibg", mid_dark)

  -- Dashboard
  Highlight("DashboardHeader"):set("guifg", "#6585ba")

  -- Telescope
  Highlight("TelescopeMatching"):set("guifg", "#6585ba"):set("gui", "bold")
  Highlight("TelescopeSelection"):set("guibg", "#12192b"):set("guifg", "#c9c9c9")
  Highlight("TelescopeNormal", true):set("guifg", "#919191")

  -- Which-key
  Highlight("WhichKeyFloat"):set("guibg", mid_dark)

  -- LSP Trouble
  Highlight("LspTroubleNormal"):set("guibg", dark)

  -- Nvim tree
  Highlight("NvimTreeNormal"):set("guibg", almost_dark)
  Highlight("NvimTreeEndOfBuffer"):set("guibg", almost_dark):set("guifg", almost_dark)

  -- Nvim cmp
  Highlight("CmpItemMenu"):set("guibg", light_dark):set("guifg", "#c9c9c9")
  Highlight("CmpItemAbbr"):set("guibg", light_dark):set("guifg", "#939393")
  Highlight("CmpItemAbbrDeprecated"):set("guibg", "NONE"):set("guifg", "#808080"):set("gui", "strikethrough")
  Highlight("CmpItemAbbrMatch"):set("guibg", "NONE"):set("guifg", "#569CD6")
  Highlight("CmpItemAbbrMatchFuzzy"):set("guibg", "NONE"):set("guifg", "#569CD6")
  Highlight("CmpItemKindVariable"):set("guibg", "NONE"):set("guifg", "#9CDCFE")
  Highlight("CmpItemKindInterface"):set("guibg", "NONE"):set("guifg", "#9CDCFE")
  Highlight("CmpItemKindText"):set("guibg", "NONE"):set("guifg", "#9CDCFE")
  Highlight("CmpItemKindFunction"):set("guibg", "NONE"):set("guifg", "#C586C0")
  Highlight("CmpItemKindMethod"):set("guibg", "NONE"):set("guifg", "#C586C0")
  Highlight("CmpItemKindKeyword"):set("guibg", "NONE"):set("guifg", "#D4D4D4")
  Highlight("CmpItemKindProperty"):set("guibg", "NONE"):set("guifg", "#D4D4D4")
  Highlight("CmpItemKindUnit"):set("guibg", "NONE"):set("guifg", "#D4D4D4")
end

