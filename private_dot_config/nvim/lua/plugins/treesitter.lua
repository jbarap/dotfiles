return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      {
        "yioneko/nvim-yati",
        event = { "BufReadPost", "BufNewFile" },
      },
      { "nvim-treesitter/nvim-treesitter-textobjects" },
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

        -- Hardcoding this to false while I test performance on big files
        is_big = false

        if is_big and disabled_buffers[bufnr] == nil then
          vim.notify("File is greater than 5MB, disabling treesitter for improved performance.", vim.log.levels.INFO)
          disabled_buffers[bufnr] = true
        end

        return is_big
      end

      local function disable_for_lang(lang, black_list)
        return vim.tbl_contains(black_list, lang)
      end

      require("nvim-treesitter.configs").setup({
        ensure_installed = "all",
        ignore_install = { "comment" },

        -- highlight performance is slow on big files
        highlight = {
          enable = true,
          disable = function (lang, bufnr)
            return disable_on_big_file(lang, bufnr)
              or disable_for_lang(lang, { "dockerfile" })
          end,
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

        -- indenting with TS is really slow for some reason
        indent = {
          enable = false,
        },

        yati = {
          enable = true,
          disable = disable_on_big_file,
          default_lazy = true,
          default_fallback = "auto",
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
}
