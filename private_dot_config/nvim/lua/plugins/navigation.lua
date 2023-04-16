return {
  -- Smooth scrolling
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    config = function()
      require("neoscroll").setup({
        cursor_scrolls_alone = true,
        hide_cursor = false,
      })
      require("neoscroll.config").set_mappings({
        ["<C-u>"] = { "scroll", { "-vim.wo.scroll", "true", "200" } },
        ["<C-d>"] = { "scroll", { "vim.wo.scroll", "true", "200" } },
      })
    end
  },

  -- Tmux integration
  {
    "aserowy/tmux.nvim",
    init = function()
      vim.keymap.set("n", "<Right>", function() require("tmux").resize_right() end, { desc = "Win resize right" })
      vim.keymap.set("n", "<Left>", function() require("tmux").resize_left() end, { desc = "Win resize left" })
      vim.keymap.set("n", "<Up>", function() require("tmux").resize_top() end, { desc = "Win resize top" })
      vim.keymap.set("n", "<Down>", function() require("tmux").resize_bottom() end, { desc = "Win resize bottom" })
    end,
    opts = {
      copy_sync = {
        enable = false,
      },
      navigation = {
        enable_default_keybindings = true,
      },
      resize = {
        enable_default_keybindings = false,
      },
    },
  },

}
