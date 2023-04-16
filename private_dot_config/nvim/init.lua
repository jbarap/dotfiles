local use_plugins = true

local utils = require("utils")

local modules = {
  "options", -- General nvim options
  "keymaps", -- Nvim keybinds
}

for _, mod in ipairs(modules) do
  utils.safe_load(mod)
end

if use_plugins then
  -- Bootstrap lazy.nvim
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)

  require("lazy").setup("plugins", {
    defaults = {
      lazy = false,
      version = false, -- Change it to respect Semver if plugins widely adopt it
    },
    change_detection = {
      enabled = false,
    },
    ui = {
      border = "rounded",
    },
  })
end
