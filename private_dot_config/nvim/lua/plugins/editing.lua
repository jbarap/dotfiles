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
          { name = "nvim_lsp", keyword_length = 3 },
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
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,

            cmp.config.compare.recently_used,

            -- from cmp-under
            function(entry1, entry2)
              local _, entry1_under = entry1.completion_item.label:find "^_+"
              local _, entry2_under = entry2.completion_item.label:find "^_+"
              entry1_under = entry1_under or 0
              entry2_under = entry2_under or 0
              if entry1_under > entry2_under then
                return false
              elseif entry1_under < entry2_under then
                return true
              end
            end,

            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
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
    keys = {
      { "gc",
        function()
          -- from: https://github.com/numToStr/Comment.nvim/issues/22#issuecomment-1272569139
          local U = require("Comment.utils")
          local cl = vim.api.nvim_win_get_cursor(0)[1] -- current line
          local range = { srow = cl, scol = 0, erow = cl, ecol = 0 }
          local ctx = {
            ctype = U.ctype.linewise,
            range = range,
          }
          local cstr = require("Comment.ft").calculate(ctx) or vim.bo.commentstring
          local ll, rr = U.unwrap_cstr(cstr)
          local padding = true
          local is_commented = U.is_commented(ll, rr, padding)

          local line = vim.api.nvim_buf_get_lines(0, cl - 1, cl, false)
          if next(line) == nil or not is_commented(line[1]) then
            return
          end

          local rs, re = cl, cl -- range start and end
          repeat
            rs = rs - 1
            line = vim.api.nvim_buf_get_lines(0, rs - 1, rs, false)
          until next(line) == nil or not is_commented(line[1])
          rs = rs + 1
          repeat
            re = re + 1
            line = vim.api.nvim_buf_get_lines(0, re - 1, re, false)
          until next(line) == nil or not is_commented(line[1])
          re = re - 1

          vim.fn.execute("normal! " .. rs .. "GV" .. re .. "G")
        end,
        mode= "o", desc = "Comment textobject",
      },
    },
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
    keys = {
      { "zR", function()
          require("ufo").openAllFolds()
          require("indent_blankline").refresh(false)
        end
      },
      { "zM", function() require("ufo").closeAllFolds() end },
    },
    event = "BufRead",
    dependencies = { "kevinhwang91/promise-async" },
    config = function ()
      vim.o.foldcolumn = "0"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = ('  (%d lines) '):format(endLnum - lnum)
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
              suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
      end
      require("ufo").setup({
        fold_virt_text_handler = handler,
      })
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

}
