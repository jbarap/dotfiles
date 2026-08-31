return {
  -- Git changes visualizer and hunk operations
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame_opts = {
        ignore_whitespace = true,
      },
      signs = {
        untracked = { text = '╎' },
      },
      signs_staged_enable = true,
      attach_to_untracked = true,
      trouble = true,
      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal({']c', bang = true})
          else
            gitsigns.nav_hunk('next')
          end
        end)


        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({'[c', bang = true})
          else
            gitsigns.nav_hunk('prev')
          end
        end)

        -- Actions
        map("n", '<leader>ghs', gitsigns.stage_hunk, { desc = "Git hunk stage" })
        map('v', '<leader>ghs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "Git hunk stage" })
        map("n", '<leader>ghx', gitsigns.reset_hunk, { desc = "Git hunk reset" })
        map('v', '<leader>ghx', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "Git hunk reset" })
        map('n', '<leader>ghX', gitsigns.reset_buffer, { desc = "Git hunk reset (buffer)" })
        map('n', '<leader>ghp', gitsigns.preview_hunk, { desc = "Git hunk preview" })
        map('n', '<leader>ghl', gitsigns.preview_hunk_inline, { desc = "Git hunk preview (inline)" })
        map('n', '<leader>ghh', function()
          gitsigns.toggle_numhl()
          gitsigns.toggle_linehl()
          gitsigns.toggle_word_diff()
        end, { desc = "Git highlight toggle" })
        map('n', '<leader>ghq', function()
          gitsigns.setqflist("attached")
          vim.cmd("copen")
        end, { desc = "Git hunk to quickfix" })
        map('n', '<leader>gbl', function() gitsigns.blame_line { full = true } end, { desc = "Git blame line" })
        map('n', '<leader>gbb', gitsigns.blame, { desc = "Git blame (toggle)" })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
      end,
    },
  },

  -- Commit and branch visualizer
  {
    "isakbm/gitgraph.nvim",
    dependencies = { "dlyongemallo/diffview-plus.nvim" },
    keys = {
      { "<leader>gl", function()
        require("gitgraph").draw({}, { all = true, max_count = 5000 })
      end, desc = "Git log" }
    },
    opts = {
      symbols = {
        merge_commit = '',
        commit = '',
        merge_commit_end = '',
        commit_end = '',

        -- Advanced symbols
        GVER = '',
        GHOR = '',
        GCLD = '',
        GCRD = '╭',
        GCLU = '',
        GCRU = '',
        GLRU = '',
        GLRD = '',
        GLUD = '',
        GRUD = '',
        GFORKU = '',
        GFORKD = '',
        GRUDCD = '',
        GRUDCU = '',
        GLUDCD = '',
        GLUDCU = '',
        GLRDCL = '',
        GLRDCR = '',
        GLRUCL = '',
        GLRUCR = '',
      },
      format = {
        timestamp = "%H:%M:%S %d-%m-%Y",
        fields = { "hash", "timestamp", "author", "branch_name", "tag" },
      },
      hooks = {
        on_select_commit = function(commit)
          vim.notify('DiffviewOpen ' .. commit.hash .. '^!')
          vim.cmd(':DiffviewOpen ' .. commit.hash .. '^!')
        end,
        on_select_range_commit = function(from, to)
          vim.notify('DiffviewOpen ' .. from.hash .. '~1..' .. to.hash)
          vim.cmd(':DiffviewOpen ' .. from.hash .. '~1..' .. to.hash)
        end,
      },
    },
  },


  -- Main git interactions
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<CR>", desc = "Git status" }
    },
    dependencies = { "nvim-lua/plenary.nvim", "ibhagwan/fzf-lua" },
    opts = {
      disable_hint = true,
      integrations = {
        diffview = true,
        fzf_lua = true,
      },
      graph_style = "kitty",
      mappings = {
        finder = {
          ["<c-j>"] = "Next",
          ["<c-k>"] = "Previous",
        },
      },
      highlight = {
        red = "#E06C75",
        orange = "#ffcb6b",
        yellow = "#FFE082",
        green = "#C3E88D",
        cyan = "#89ddff",
        blue = "#82AAFF",
        purple = "#C792EA",
      },
      status = {
        recent_commit_count = 5,
      },
      sections = {
        stashes = {
          folded = true
        },
        recent = {
          folded = false,
        },
      },
      signs = {
        section = { "🠚", "🠛" },
        item = { "●", "○" },
      },
    }
  },

  -- Diff comparison
  {
    "esmuellert/codediff.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    keys = {
      { "<leader>cd", function() vim.fn.feedkeys(":CodeDiff ") end, mode = { "n", "v" }, desc = "Code diff" },
    },
    cmd = "CodeDiff",
    opts = {
      highlights = {
        char_brightness = 1.7,
      },
      explorer = {
        view_mode = "tree",
      },
    },
  },
  {
    -- Maintained fork of: sindrets/diffview.nvim
    "dlyongemallo/diffview-plus.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>dvo", function() require("plugin_utils").toggle_diff_view("diff") end, mode = { "n", "v" }, desc = "Diffview open" },
      { "<leader>dvf", function() require("plugin_utils").toggle_diff_view("file") end, mode = { "n", "v" }, desc = "Diffview file history" },
      { "<leader>dvp", function() require("plugin_utils").toggle_diff_view("pr") end, mode = { "n", "v" }, desc = "Diffview PR" },
    },
    config = function()
      local actions = require("diffview.actions")
      require("diffview").setup({
        view = {
          default = {
            winbar_info = true,
          },
          merge_tool = {
            layout = "diff3_mixed",
            disable_diagnostics = true,
          },
          file_history = {
            winbar_info = true,
          },
        },
        diff_binaries = false,
        enhanced_diff_hl = true,
        use_icons = true,
        file_panel = {
          show_branch_name = true,
          always_show_sections = true,
          win_config = {
            position = "left",
            width = 35,
            height = 10,
          }
        },
        file_history_panel = {
          git = {
            log_options = {
              single_file = {
                follow = true,
                all = false,
              },
              multi_file = {
                all = false,
              },
            },
          },
        },
        key_bindings = {
          view = {
            { "n", "<tab>", actions.select_next_entry, { desc = "Next entry" } },
            { "n", "<s-tab>", actions.select_prev_entry, { desc = "Prev entry" } },
            { "n", "<leader>nf", actions.focus_files, { desc = "Focus files" } },
            { "n", "<leader>nn", actions.toggle_files, { desc = "Toggle files" } },
            { "n", "[x", actions.prev_conflict, { desc = "Prev conflict" } },
            { "n", "]x", actions.next_conflict, { desc = "Next conflict" } },
            { "n", "<leader>co", actions.conflict_choose("ours"), { desc = "Choose ours" } },
            { "n", "<leader>ct", actions.conflict_choose("theirs"), { desc = "Choose theirs" } },
            { "n", "<leader>cb", actions.conflict_choose("all"), { desc = "Choose both" } }, -- choose both
            { "n", "<leader>cB", actions.conflict_choose("base"), { desc = "Choose the base" } },
            { "n", "<leader>cx", actions.conflict_choose("none"), { desc = "Choose none" } },
          },
          file_panel = {
            { "n", "j", actions.next_entry, { desc = "Next entry" }},
            { "n", "k", actions.prev_entry, { desc = "Prev entry" }},
            { "n", "<cr>", actions.select_entry, { desc = "Select entry" }},
            { "n", "<c-r>", actions.refresh_files, { desc = "Refresh files" }},
            { "n", "<tab>", actions.select_next_entry, { desc = "Select next entry" }},
            { "n", "<s-tab>", actions.select_prev_entry, { desc = "Select prev entry" }},
            { "n", "<leader>nf", actions.focus_files, { desc = "Focus files" }},
            { "n", "<leader>nn", actions.toggle_files, { desc = "Toggle files" }},
          },
        },
        default_args = {
          DiffviewOpen = { "--untracked-files=no", "--imply-local" },
          -- DiffviewFileHistory = { "--base=LOCAL" }
        },
      })
    end
  },
  {
    -- TODO: lazy load. Fairly light though
    "emrearmagan/atlas.nvim",
    cmd = "Atlas",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      -- "MeanderingProgrammer/render-markdown.nvim", -- optional but recommended
      -- "esmuellert/codediff.nvim", -- optional (PullRequest diff)
      -- "sindrets/diffview.nvim", -- optional (PullRequest diff - alternative)
    },
    opts = {
    },
  }
}
