return {
  -- Snippets
  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    config = function ()
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node

      ls.add_snippets("python", {
        s({ trig = "ifnameis", name = "If name is main" }, {
          t({ "if __name__ == '__main__':", "\t" }),
          i(1),
        }),

        s("env", {
          t({ "#!/usr/bin/env python", "" }),
        }),

        s("env3", {
          t({ "#!/usr/bin/env python3", "" }),
        }),

        s("pdb", {
          t({ "import pdb; pdb.set_trace()" }),
        }),

        s("ipdb", {
          t({ "import ipdb; ipdb.set_trace(context=5)" }),
        }),

        s("pudb", {
          t({ "import pudb; pudb.set_trace()" }),
        }),

        s("pprint", {
          t({ "import pprint; pprint.pprint(" }),
          i(1, "object_to_print"),
          t(")"),
        }),
      })

      ls.add_snippets("json", {
        s({ trig = "debugpython", name = "Python debug" }, {
          t({ "{" }),
          t({ "", '\t"configurations": [' }),
          t({ "", '\t\t{' }),
          t({ "", '\t\t\t"name": ' }), i(1, '"Project launch"'), t(","),
          t({ "", '\t\t\t"type": ' }), i(2, '"python_launch"'), t(","),
          t({ "", '\t\t\t"request": ' }), i(3, '"launch"'), t(","),
          t({ "", '\t\t\t"program": ' }), i(4, '"${workspaceFolder}/${file}"'), t(","),
          t({ "", '\t\t\t"args": [' }), i(5), t({ "]" }), t(","),
          t({ "", '\t\t\t"cwd": ' }), i(6, '"${workspaceFolder}"'), t(","),
          t({ "", '\t\t\t"env": {' }), i(7), t({ "}," }),
          t({ "", '\t\t\t"pathMappings": [{ ' }), i(0, '"localRoot": "${workspaceFolder}", "remoteRoot": "."'), t({ " }]" }),
          t({ "", '\t\t}' }),
          t({ "", '\t]' }),
          t({ "", "}" }),
          })
      })

    end
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")
      local autopairs_rule = require("nvim-autopairs.rule")
      local autopairs_cond = require('nvim-autopairs.conds')

      autopairs.setup({})

      -- note: careful, order of :with_pair seems to matter
      autopairs.add_rules({
        autopairs_rule("__", "__", "python"),

        autopairs_rule(' ', ' ', 'lua')
          :with_pair(autopairs_cond.not_after_regex_check("[^%}]", 1))
          :with_pair(autopairs_cond.before_text_check("{"))
      })
    end
  },

  -- Autocomplete
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      vim.o.completeopt = "menu,menuone,noselect"

      local cmp = require("cmp")
      local cmp_buffer = require('cmp_buffer')

      local kind_icons = {
        Text = "",
        Method = "",
        Function = "",
        Constructor = "",
        Field = "",
        Variable = "",
        Class = "",
        Interface = "",
        Module = "",
        Property = "",
        Unit = "",
        Value = "",
        Enum = "",
        Keyword = "",
        Snippet = "",
        Color = "",
        File = "",
        Reference = "",
        Folder = "",
        EnumMember = "",
        Constant = "",
        Struct = "",
        Event = "",
        Operator = "",
        TypeParameter = ""
      }

      cmp.setup({
        mapping = {
          ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
          ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
          ["<M-k>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<M-j>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),

          -- Toggle completion menu with <C-Space>
          ["<C-Space>"] = cmp.mapping(function(fallback)
            local action
            if not cmp.visible() then
              action = cmp.complete
            else
              action = cmp.close
            end

            if not action() then
              fallback()
            end
          end),

          ["<C-e>"] = cmp.mapping(cmp.mapping.close(), { "i", "c" }),

          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, {
            "i",
            "s",
          }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, {
            "i",
            "s",
          }),

          ["<CR>"] = cmp.mapping(cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
          }, {
            "i",
            "c",
          })),
        },

        sources = {
          { name = "nvim_lua" },
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
          {
            name = "buffer",
            option = {
              keyword_length = 5,
            },
            keyword_length = 5,
            max_item_count = 20,
          },
        },

        sorting = {
          comparators = {
            function(...) return cmp_buffer:compare_locality(...) end,
          }
        },

        formatting = {
          format = function(entry, vim_item)
            -- Kind icons
            vim_item.kind = kind_icons[vim_item.kind]

            -- Source
            vim_item.menu = ({
              buffer = "()",
              nvim_lsp = "()",
              nvim_lua = "()",
            })[entry.source.name]

            return vim_item
          end,
        },

        preselect = cmp.PreselectMode.None,

        window = {
          documentation = cmp.config.window.bordered({
            border = "rounded",
            winhighlight = 'NormalFloat:NormalFloat',
          }),
          completion = cmp.config.window.bordered({
            border = "none",
            winhighlight = 'Normal:NormalFloat,FloatBorder:Normal,CursorLine:Visual,Search:None',
          }),
        },

        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
      })

      -- autopairs support
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
    end
  },

  -- Commenting
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    opts = {
      ignore = "^$",
    },
  },

  -- Surround
  {
    "echasnovski/mini.surround",
    config = function ()
      require('mini.surround').setup({
        search_method = "cover_or_next",
        mappings = {
          add = 'ys',
          delete = 'ds',
          find = '',
          find_left = '',
          highlight = '',
          replace = 'cs',
          update_n_lines = '',

          -- Add this only if you don't want to use extended mappings
          suffix_last = '',
          suffix_next = '',
        },
      })

      -- Remap adding surrounding to Visual mode selection
      vim.api.nvim_del_keymap('x', 'ys')
      vim.api.nvim_set_keymap('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { noremap = true })

      -- Make special mapping for "add surrounding for line"
      vim.api.nvim_set_keymap('n', 'yss', 'ys_', { noremap = false })
    end,
  },

  -- Substitution
  {
    "gbprod/substitute.nvim",
    keys = {
      { "s", "<cmd>lua require('substitute').operator()<cr>", desc = "Substitute" },
      { "ss", "<cmd>lua require('substitute').line()<cr>", desc = "Substitute (line)" },
      { "S", "<cmd>lua require('substitute').eol()<cr>", desc = "Substitute ('til EOL)" },
      { "s", "<cmd>lua require('substitute').visual()<cr>", mode = "x", desc = "Substitute (selection)" },
    },
    config = true,
  },

  -- Repeat
  { "tpope/vim-repeat" },

  -- Text objects
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        init = function()
          require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
        end,
      },
    },
    config = function ()
      local ai = require("mini.ai")

      require("mini.ai").setup({
        n_lines = 500,
        search_method = 'cover_or_nearest',
        custom_textobjects = {
          a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
        },
      })
    end,
  },

  -- Better folding
  {
    "kevinhwang91/nvim-ufo",
    keys = { "za", "zc", "zo", "zR", "zM" },
    init = function ()
      vim.keymap.set("n", "zR", function ()
        if package.loaded["ufo"] then
          require("ufo").openAllFolds()
          vim.cmd("redraw")
          require("indent_blankline").refresh(false)
          return ""
        else
          return "zR"
        end
      end, { remap = false, expr = true })

      vim.keymap.set("n", "zM", function ()
        if package.loaded["ufo"] then
          require("ufo").closeAllFolds()
          vim.cmd("redraw")
          return ""
        else
          return "zM"
        end
      end, { remap = false, expr = true })
    end,
    dependencies = { "kevinhwang91/promise-async" },
    config = function ()
      vim.o.foldcolumn = '0'
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      require("ufo").setup()
    end,
  },

  -- Docstring generation
  {
    "danymat/neogen",
    lazy = true,
    keys = {
      { "<Leader>cdg", function() require("neogen").generate() end, desc = "Code docstring generate" },
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
    "kevinhwang91/nvim-bqf",
    opts = {
      auto_resize_height = false,
      func_map = {
        pscrollup = "<M-k>",
        pscrolldown = "<M-j>",
      }
    }
  },
  {
    "gabrielpoca/replacer.nvim",
    lazy = true,
    keys = {
      { "<leader>qe", function() require("replacer").run() end, nowait = true, desc = "Quickfix edit" },
    },
  },

  -- Scope buffers to tabs
  {
    "tiagovla/scope.nvim",
    event = "VeryLazy",
    config = true,
  },

}
