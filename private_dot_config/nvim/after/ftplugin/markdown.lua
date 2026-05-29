vim.opt_local.spell = true
vim.opt_local.wrap = true

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. "\n setlocal spell< wrap<"
