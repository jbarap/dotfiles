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
      { "s", mode = "n", function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = "n", function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    },
  },

  -- Buffer navigation
  {
    "ThePrimeagen/harpoon",
    requires = { {"nvim-lua/plenary.nvim"} },
    branch = "harpoon2",
    keys = {
      { "<Leader>ma", function() require("harpoon"):list():append() end, desc = "Mark add" },
      { "<Leader>mx", function() require("harpoon"):list():remove() end, desc = "Mark remove" },
      { "<Leader>mm", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Mark menu" },
      { "<Leader>mp", function() require("harpoon"):list():select(vim.v.count) end, desc = "Mark pick" },
      { "<A-.>", function() require("harpoon"):list():next() end, desc = "Mark next" },
      { "<A-,>", function() require("harpoon"):list():prev() end, desc = "Mark previous" },
    },
    config = function ()
      local harpoon = require("harpoon")
      harpoon:setup({
        settings = {
          save_on_toggle = true,
        },
      })
    end
  },

}
