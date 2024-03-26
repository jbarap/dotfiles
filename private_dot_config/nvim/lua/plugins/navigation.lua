return {
  -- Smooth scrolling
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    config = function()
      require("neoscroll").setup({
        cursor_scrolls_alone = true,
        hide_cursor = false,
        pre_hook = function()
          vim.opt.eventignore:append({
            'WinScrolled',
            'CursorMoved',
          })
        end,
        post_hook = function()
          vim.opt.eventignore:remove({
            'WinScrolled',
            'CursorMoved',
          })
        end,
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
    event = "VeryLazy",
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

  -- Buffer navigation
  {
    "cbochs/grapple.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons", lazy = true },
    },
    cmd = "Grapple",
    keys = {
      { "<Leader>ma", function() require("grapple").tag() end, desc = "Mark add" },
      { "<Leader>mx", function() require("grapple").untag() end, desc = "Mark remove" },
      { "<Leader>mm", function() require("grapple").toggle_tags() end, desc = "Mark menu" },
      { "<Leader>mp", function() require("grapple").select({ index = vim.v.count }) end, desc = "Mark pick" },
      { "<A-.>", function() require("grapple").cycle("forward") end, desc = "Mark next" },
      { "<A-,>", function() require("grapple").cycle("backward") end, desc = "Mark previous" },
    },
    opts = {
      scope = "git_branch",
    },
  }

}
