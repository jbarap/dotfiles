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

  -- Quick navigation
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = {
          enabled = false,
        },
        char = {
          enabled = false,
        },
      },
    },
    keys = {
      -- don't really use f and F, so I'm overriding them
      { "f", mode = "n", function() require("flash").jump() end, desc = "Flash" },
      { "F", mode = "n", function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    },
  },

  -- harpoon
  {
    "MeanderingProgrammer/harpoon-core.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<Leader>ma", function() require('harpoon-core.mark').add_file() end, desc = "Mark add" },
      { "<Leader>mx", function() require('harpoon-core.mark').rm_file() end, desc = "Mark remove" },
      { "<Leader>mm", function() require('harpoon-core.ui').toggle_quick_menu() end, desc = "Mark menu" },
      { "<Leader>mp", function() require('harpoon-core.ui').nav_file(vim.v.count) end, desc = "Mark pick" },
      { "<A-.>", function() require('harpoon-core.ui').nav_next() end, desc = "Mark next" },
      { "<A-,>", function() require('harpoon-core.ui').nav_prev() end, desc = "Mark previous" },
    },
    config = function()
      require('harpoon-core').setup({
        -- Make existing window active rather than creating a new window
        use_existing = true,
        -- Set marks specific to each git branch inside git repository
        mark_branch = false,
        -- Use the previous cursor position of marked files when opened
        use_cursor = true,
        -- Settings for popup window
        menu = {
          width = 60,
          height = 10,
        },
        -- Highlight groups to use for various components
        highlight_groups = {
          window = 'HarpoonWindow',
          border = 'HarpoonBorder',
        },
      })
    end,
  },

}
