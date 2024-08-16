return {
  {
    "nvim-telescope/telescope.nvim",
    lazy = true,
    cmd = { "Telescope" },
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local actions = require("telescope.actions")
      local layout_actions = require("telescope.actions.layout")

      -- Helper functions for path_display
      local Path = require("plenary.path")
      local get_status = require("telescope.state").get_status

      local calc_result_length = function(truncate_len)
        local status = get_status(vim.api.nvim_get_current_buf())
        local len = vim.api.nvim_win_get_width(status.results_win) - status.picker.selection_caret:len() - 2
        return type(truncate_len) == "number" and len - truncate_len or len
      end

      --       telescope setup
      -- ──────────────────────────────
      require("telescope").setup({
        defaults = {
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--column",
            "--line-number",
            "--no-heading",
            "--smart-case",
            "--with-filename",
          },
          preview = {
            filesize_limit = 25, -- in MB
          },
          path_display = function(ctx, path)
            local cwd
            if ctx.cwd then
              cwd = ctx.cwd
              if not vim.in_fast_event() then
                cwd = vim.fn.expand(ctx.cwd)
              end
            else
              cwd = vim.loop.cwd()
            end

            if not ctx.__length then
              ctx.__length = calc_result_length()
            end

            local name = require("telescope.utils").path_tail(path)
            local directory = Path:new(path):parent():make_relative(cwd)

            -- compensate for both parenthesis (2) and the space (1) characters
            directory = require("plenary.strings").truncate(directory, math.max(ctx.__length - name:len() - 3, 0), nil,
              -1)

            return string.format("%s (%s)", name, directory)
          end,
          layout_strategy = "flex",
          sorting_strategy = "ascending",
          scroll_strategy = "limit",
          selection_caret= "➜ ",
          borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          winblend = 10,
          layout_config = {
            height = 0.97,
            width = 0.97,
            scroll_speed = 4,
            horizontal = {
              prompt_position = "top",
              preview_width = 0.4,
            },
            vertical = {
              preview_height = 0.6,
              preview_cutoff = 30,
            },
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,

              ["<C-p>"] = layout_actions.toggle_preview,

              ["<M-k>"] = actions.preview_scrolling_up,
              ["<M-j>"] = actions.preview_scrolling_down,

              -- Send to quickfix
              ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,

              -- Effectively remove normal mode
              ["<esc>"] = actions.close,

              -- Change bind for horizontal split
              ["<C-s>"] = actions.select_horizontal,
            },
            n = {
              ["<esc>"] = actions.close,
            },
          },
        },
        pickers = {
          live_grep = {
            entry_maker = require("plugins.telescope.custom_entry_maker").grep_displayer(),
            -- AND operator for live_grep like how fzf handles spaces with wildcards in rg
            on_input_filter_cb = function(prompt) return { prompt = prompt:gsub("%s", ".*") } end,
          },
          grep_string = {
            entry_maker = require("plugins.telescope.custom_entry_maker").grep_displayer(),
            -- AND operator for live_grep like how fzf handles spaces with wildcards in rg
            on_input_filter_cb = function(prompt) return { prompt = prompt:gsub("%s", ".*") } end,
          },
          find_files = {
            entry_maker = require("plugins.telescope.custom_entry_maker").file_displayer(),
            previewer = false,
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })

      require("telescope").load_extension("fzf")
    end,
  },
}
