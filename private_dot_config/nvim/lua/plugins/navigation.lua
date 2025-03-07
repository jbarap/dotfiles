return {
  -- Smooth scrolling
  {
    "karb94/neoscroll.nvim",
    enabled = true,
    event = "VeryLazy",
    keys = {
      { "<C-u>", function() require("neoscroll").ctrl_u({ duration = 200}) end, mode = { "n", "v" }, desc = "Scroll up" },
      { "<C-d>", function() require("neoscroll").ctrl_d({ duration = 200}) end, mode = { "n", "v" }, desc = "Scroll down" },
    },
    config = function()
      require("neoscroll").setup({
        mappings = { "zz" },
        cursor_scrolls_alone = true,
        hide_cursor = false,
      })
    end
  },

  -- Tmux integration
  {
    "mrjones2014/smart-splits.nvim",
    keys = {
      -- Movement
      { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Resize right" },
      { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Resize left" },
      { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Resize up" },
      { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Resize down" },

      -- Resizing
      { "<Right>", function() require("smart-splits").resize_right() end, desc = "Resize right" },
      { "<Left>", function() require("smart-splits").resize_left() end, desc = "Resize left" },
      { "<Up>", function() require("smart-splits").resize_up() end, desc = "Resize up" },
      { "<Down>", function() require("smart-splits").resize_down() end, desc = "Resize down" },
    },
    config = function ()
      require('smart-splits').setup({})
    end,
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
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = { "TSContextEnable", "TSContextToggle" },
    opts = {
      multiwindow = true,
      -- mode = "topline",
      mode = "cursor",
    },
  },

}
