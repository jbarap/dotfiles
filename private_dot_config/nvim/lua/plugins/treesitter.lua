return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      {
        "yioneko/nvim-yati",
      },
      {
        "yioneko/vim-tmindent",
        config = true,
      },
    },
    keys = {
      { "<CR>", desc = "Increment selection" },
      { "<S-CR>", desc = "Schrink selection", mode = "x" },
    },
    config = function()
      local disabled_buffers = {}

      local function disable_on_big_file(lang, bufnr)
        local stat = vim.loop.fs_stat(vim.api.nvim_buf_get_name(bufnr))
        if stat == nil then
          return false
        end

        local is_big = stat.size > 5000000 -- disable on files > 5MB

        if is_big and disabled_buffers[bufnr] == nil then
          vim.notify("File is greater than 5MB, disabling treesitter for improved performance.", vim.log.levels.INFO)
          disabled_buffers[bufnr] = true
        end

        return is_big
      end

      require("nvim-treesitter.configs").setup({
        ensure_installed = "all",
        ignore_install = { "comment" },

        -- highlight performance is slow on big files
        highlight = {
          enable = true,
          disable = disable_on_big_file,
        },

        playground = {
          enable = true,
          disable = disable_on_big_file,
        },

        incremental_selection = {
          enable = true,
          disable = disable_on_big_file,
          keymaps = {
            init_selection = "<CR>",
            scope_incremental = "<CR>",
            node_incremental = "<TAB>",
            node_decremental = "<S-TAB>",
          },
        },

        -- indenting with TS is really slow for some reason, look for alternatives
        indent = {
          enable = false,
          disable = disable_on_big_file,
        },

        yati = {
          enable = true,
          disable = disable_on_big_file,
          default_lazy = true,
          default_fallback = function(lnum, computed, bufnr)
            -- TODO: check what tmindent returns when it fails, and add default as second fallback
            return require("tmindent").get_indent(lnum, bufnr) + computed
          end,
        },

        textobjects = {
          select = {
            enable = true,
            disable = disable_on_big_file,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["aF"] = "@call.outer",
              ["iF"] = "@call.inner",
              ["ab"] = "@block.outer",
              ["ib"] = "@block.inner",
            },
            selection_modes = {
              ["@function.outer"] = "V",
              ["@class.outer"] = "V",
            },
          },
          move = {
            enable = true,
            disable = disable_on_big_file,
            set_jumps = false, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
              ["]b"] = "@block.outer",
              ["]a"] = "@parameter.inner",
            },
            goto_next_end = {
              ["]F"] = "@function.outer",
              ["]C"] = "@class.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
              ["[b"] = "@block.outer",
              ["[a"] = "@parameter.inner",
            },
            goto_previous_end = {
              ["[F"] = "@function.outer",
              ["[C"] = "@class.outer",
            },
          },

          lsp_interop = {
            enable = true,
            disable = disable_on_big_file,
            border = "rounded",
            peek_definition_code = {
              ["<leader>pd"] = "@function.outer",
            },
          },
        },

      })
    end
  },
  {
    "yioneko/nvim-yati",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "yioneko/vim-tmindent",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = true,
  },
}
