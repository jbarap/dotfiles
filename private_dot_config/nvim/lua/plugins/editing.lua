return {
  -- Autopairs
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    config = function ()
      require("mini.pairs").setup({
      })
    end
  },

  -- Autocomplete
  {
    "saghen/blink.cmp",
    enabled = true,
    event = "InsertEnter",

    -- TODO: change this if building becomes easier
    build = "rustup run nightly cargo build --release",

    config = function ()
      require("blink.cmp").setup(
        {
          keymap = {
            ["<CR>"] = { "accept", "fallback" },
            ["<C-space>"] = { "show", "hide" },
            ["<C-j>"] = { "select_next", "fallback" },
            ["<C-k>"] = { "select_prev", "fallback" },
            ["<M-k>"] = { "scroll_documentation_up", "fallback" },
            ["<M-j>"] = { "scroll_documentation_down", "fallback" },
            ["<Tab>"] = { "snippet_forward", "fallback" },
            ["<S-Tab>"] = { "snippet_backward", "fallback" },
          },

          sources = {
            default = { "lsp", "path", "snippets", "buffer" },
          },

          cmdline = {
            enabled = false
          },

          appearance = {
            nerd_font_variant = "mono",
            kind_icons = {
              Text = "󰉿",
              Method = "󰊕",
              Function = "󰊕",
              Constructor = "󰒓",

              Field = "󰜢",
              Property = "󰜢",
              Variable = "󰀫",

              Class = "󰠱",
              Interface = "",
              Struct = "󰙅",
              Module = "",

              Unit = "󰑭",
              Value = "󰎠",
              Enum = "",
              EnumMember = "",

              Keyword = "󰌋",
              Constant = "󰏿",

              Snippet = "",
              Color = "󰏘",
              File = "󰈙",
              Reference = "󰈇",
              Folder = "󰉋",
              Event = "",
              Operator = "󰆕",
              TypeParameter = "󰬛",
            }
          },

          completion = {
            documentation = {
              auto_show = true,
              window = {
                border = "rounded",
                max_width = 100,
              },
            },
            list = {
              selection = {
                preselect = false,
                auto_insert = true,
              },
            },
            menu = {
              winblend = 10,
              border = "rounded",
              winhighlight = "Normal:BlinkCmpMenu,FloatBorder:FloatBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
              draw = {
                treesitter = {"lsp"},  -- quite nice, but slower
              },
            },
          },
        }
      )
    end,
  },

  -- Surround
  {
    "echasnovski/mini.surround",
    config = function ()
      require("mini.surround").setup({
        custom_surroundings = {
          -- don't insert space on opening brackets
          ["("] = { output = { left = "(", right = ")" } },
          ["["] = { output = { left = "[", right = "]" } },
          ["{"] = { output = { left = "{", right = "}" } },
          ["<"] = { output = { left = "<", right = ">" } },
        },
        search_method = "cover_or_next",
        mappings = {
          add = 'ys',
          delete = 'ds',
          find = '',
          find_left = '',
          highlight = '',
          replace = 'cs',
          update_n_lines = '',
          suffix_last = '',
          suffix_next = '',
        },
      })

      vim.api.nvim_del_keymap('x', 'ys')
      vim.api.nvim_set_keymap('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { noremap = true })
      vim.api.nvim_set_keymap('n', 'yss', 'ys_', { noremap = false })
    end,
  },

  -- Substitution
  {
    "gbprod/substitute.nvim",
    keys = {
      { "s", function() require("substitute").operator() end, desc = "Substitute" },
      { "ss", function() require('substitute').line() end, desc = "Substitute (line)" },
      { "S", function() require('substitute').eol() end, desc = "Substitute ('til EOL)" },
      { "s", function() require('substitute').visual() end, mode = "x", desc = "Substitute (selection)" },
    },
    config = true,
  },

  -- Text objects
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    config = function ()
      require("mini.ai").setup({
        n_lines = 500,
        search_method = 'cover_or_nearest',
        custom_textobjects = {
          g = function ()
            local from = { line = 1, col = 1 }
            local to = {
              line = vim.fn.line("$"),
              col = math.max(vim.fn.getline("$"):len(), 1)
            }
            return { from = from, to = to }
          end
        },
      })
    end,
  },

  -- Better folding
  {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    enabled = true,
    keys = {
      { "zR", function()
          require("ufo").openAllFolds()
        end,
        desc = "Open all folds",
      },
      { "zM", function()
          require("ufo").closeAllFolds()
        end,
        desc = "Close all folds",
      },
      { "zp", function()
          require("ufo").peekFoldedLinesUnderCursor()
        end,
        desc = "Peek fold under cursor",
      },
      -- For hover, see LSP's hover mapping
    },
    opts = {
      provider_selector = function(bufnr, filetype, buftype)
        return { "treesitter", "indent" }
      end,
    },
    init = function()
      -- folding options setup to make ufo work
      vim.o.foldcolumn = "0"
      vim.o.foldlevel = 99 -- Using ufo provider needs a large value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    config = function(_, opts)
      -- pretty handler that aligns virtual text with textwidth, colorcolumn, or win width
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local align_limiter
        local text_width = vim.opt.textwidth["_value"]
        local colorcolumn = vim.opt.colorcolumn["_value"]
        if text_width ~= 0 and text_width then
          align_limiter = text_width
        elseif colorcolumn ~= 0 and colorcolumn then
          align_limiter = colorcolumn
        else
          align_limiter = vim.api.nvim_win_get_width(0)
        end

        local newVirtText = {}
        local totalLines = vim.api.nvim_buf_line_count(0)
        local foldedLines = endLnum - lnum
        local suffix = (" 󰁂 %d (%d%%)"):format(foldedLines, foldedLines / totalLines * 100)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        local rAlignAppndx = math.max(math.min(align_limiter, width - 1) - curWidth - sufWidth, 0)
        suffix = (" "):rep(rAlignAppndx) .. suffix
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end
      opts["fold_virt_text_handler"] = handler
      require("ufo").setup(opts)
    end,
  },

  -- Docstring generation
  {
    "danymat/neogen",
    lazy = true,
    cmd = { "Neogen" },
    keys = {
      { "<Leader>cdg", function()
        if vim.bo.filetype == "python" then
          vim.ui.select({ "google_docstrings", "numpydoc", "reST" }, { prompt = "Enter docstring type:" },
            function(input)
              if input == nil or input == "" then
                return
              end
              require("neogen").generate({
                annotation_convention = { python = input }
              })
            end)
        else
          require("neogen").generate()
        end
      end, desc = "Code docstring generate" },
      { "<Leader>cd.", function() require("neogen").jump_next() end, desc = "Code docstring next field" },
      { "<Leader>cd,", function() require("neogen").jump_prev() end, desc = "Code docstring prev field" },
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      input_after_comment = true,
      languages = {
        lua = {
          template = {
            annotation_convention = "emmylua"
          },
        },
        python = {
          template = {
            annotation_convention = "google_docstrings"
          },
        },
      },
    }
  },

  -- Quickfix improvements
  {
    "stevearc/quicker.nvim",
    opts = {
      highlight = {
        lsp = false,
        load_buffers = false,
      },
    },
  },

  -- Formatters
  {
    "stevearc/conform.nvim",
    keys = {
      { "<Leader>cf", function() require("conform").format({
        lsp_fallback = true,
      }) end, mode = { "n", "v" }, desc = "Code format" },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "ruff_format" },
        markdown = { "prettier" },
        json = { "biome" },
        yaml = { "yamlfmt" },
      },
    },
  },

}
