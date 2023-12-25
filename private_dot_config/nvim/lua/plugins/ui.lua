return {
  -- colorscheme
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function ()
      require('kanagawa').setup({
        undercurl = true,
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        variablebuiltinStyle = { bold = true },
        specialReturn = true,
        specialException = true,
        transparent = false,
        dimInactive = false,
        colors = {
          palette = {
            fugiWhite = "#c9c9c9",
            fujiGray= "#666666",

            sumiInk0 = "#101010",
            sumiInk1 = "#111111",
            sumiInk2 = "#131313",
            sumiInk3 = "#151515", -- Normal bg
            sumiInk4 = "#181818", -- Gutter gb
            sumiInk5 = "#23232e",
            sumiInk6 = "#54546d", -- Used as darkish fg
          },
          theme = {
            wave = {
              diff = {
                add = "#0a2b2b",
                delete = "#331523",
                change = "#1c2536",
                text = "#1f3b70",
              },
              vcs = {
                added = "#1f6f6f",
                removed = "#812e52",
                changed = "#33415b",
              },
              syn = {
                preproc = "#ffa066",
                special1 = "#957fb8",
              },
            },
          },
        },
        overrides = function (colors)
          return {
            NormalNC = { bg = colors.palette.sumiInk2 },
            -- Cursor
            CursorLine = { bg = colors.palette.sumiInk4 },
            ColorColumn = { bg = colors.palette.sumiInk4 },

            Folded = { bg = colors.palette.sumiInk5 },

            QuickFixLine = { bg = "#252525" },
            -- Search
            Search = { bg = "#1c284a" },
            Substitute = { bg = "#4d1d28" },
            -- Diffs
            DiffDelete = { fg = "NONE" },
            -- Windows
            WinSeparator = { fg = "#252525" },

            -- Telescope
            TelescopeSelection = { bg = "#202020" },
            TelescopeMatching = { fg = "#7fb4ca" },

            -- Cmp
            Pmenu = { bg = "#0a0a0a" },
            PmenuSbar = { bg = "#252525" },

            -- Diffview
            DiffviewCursorLine = { bg = "#252525" },
          }
        end,
      })
      vim.cmd([[colorscheme kanagawa]])
    end
  },

  -- color picker
  {
    "uga-rosa/ccc.nvim",
    cmd = { "CccPick", "CccConvert", "CccHighlighterToggle" },
    config = true,
  },

  {
    "nanozuki/tabby.nvim",
    lazy = false,
    keys = {
      { "<Leader>tr", function()
        vim.ui.input({ prompt = "Enter new tab name: " }, function(input)
          if input == nil or input == "" then
            return
          end
          vim.cmd(string.format("TabRename %s", input))
        end)
      end, desc = "Tab rename" },
    },
    config = function ()

      vim.o.showtabline = 2

      local theme = {
        fill = 'TabLineFill',
        head = "TabLine",
        current_tab = { fg="#000000", bg="#7e9cd8", style="bold" },
        tab = 'TabLine',
        win = 'TabLine',
        tail = 'TabLine',
      }

      require('tabby.tabline').set(
        function(line)
          return {
            {
              { ' ⧉ ', hl = theme.head },
              line.sep('', theme.head, theme.fill),
            },
            line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
              local hl = win.is_current() and theme.current_tab or theme.tab

              return {
                line.sep('', hl, theme.fill),
                win.is_current() and '' or '',
                win.buf_name(),
                win.buf().is_changed() and '🞱' or "",
                line.sep('', hl, theme.fill),
                hl = hl,
                margin = ' ',
              }
            end),
            line.spacer(),
            line.tabs().foreach(function(tab)
              local hl = tab.is_current() and theme.current_tab or theme.tab
              return {
                line.sep('', hl, theme.fill),
                tab.is_current() and '' or '󰆣',
                tab.number(),
                tab.name(),
                line.sep('', hl, theme.fill),
                hl = hl,
                margin = ' ',
              }
            end),
            {
              line.sep('', theme.tail, theme.fill),
              { '  ', hl = theme.tail },
            },
            hl = theme.fill,
          }
        end
      )

    end
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    config = function ()
      vim.g.mkdp_auto_close = 0
    end,
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  -- Statusline/Winbar
  {
    "MunifTanjim/nougat.nvim",
    event = "VeryLazy",
    config = function ()
      local nougat = require("nougat")
      local core = require("nougat.core")
      local Bar = require("nougat.bar")
      local Item = require("nougat.item")
      local sep = require("nougat.separator")

      local nut = {
        buf = {
          diagnostic_count = require("nougat.nut.buf.diagnostic_count").create,
          filename = require("nougat.nut.buf.filename").create,
          filestatus = require("nougat.nut.buf.filestatus").create,
          filetype = require("nougat.nut.buf.filetype").create,
        },
        git = {
          branch = require("nougat.nut.git.branch").create,
          status = require("nougat.nut.git.status"),
        },
        tab = {
          tablist = {
            tabs = require("nougat.nut.tab.tablist").create,
            close = require("nougat.nut.tab.tablist.close").create,
            icon = require("nougat.nut.tab.tablist.icon").create,
            label = require("nougat.nut.tab.tablist.label").create,
            modified = require("nougat.nut.tab.tablist.modified").create,
          },
        },
        mode = require("nougat.nut.mode").create,
        spacer = require("nougat.nut.spacer").create,
        truncation_point = require("nougat.nut.truncation_point").create,
      }

      ---@type nougat.color
      local color = {
        fg = "#abb2bf",
        faded_fg = "#8b95a7",
        bg = "#1e2024",
        green = "#98c379",
        yellow = "#e5c07b",
        purple = "#c678dd",
        orange = "#d19a66",
        peanut = "#f6d5a4",
        red = "#e06c75",
        aqua = "#61afef",
        darkblue = "#282c34",
        dark_red = "#f75f5f",
      }

      local mode_colors = {
        normal = color.green,
        visual = color.purple,
        insert = color.yellow,
        replace = color.red,
        commandline = color.aqua,
        terminal = color.dark_red,
        inactive = color.green,
      }
      local mode_highlights = {}
      for mode, col in pairs(mode_colors) do
        mode_highlights[mode] = {
          fg = col,
          bg = color.darkblue,
          bold = true,
        }
      end

      local stl = Bar("statusline", {
        hl = { fg = color.fg, bg = color.bg, bold = true },
      })

      -- vim mode
      stl:add_item(nut.mode({
        prefix = " ",
        sep_right = sep.right_lower_triangle_solid(true),
        config = {
          highlight = mode_highlights,
        },
      }))

      -- git branch
      stl:add_item(nut.git.branch({
        hl = { bg = color.darkblue, fg = color.aqua },
        prefix = "  ",
        suffix = " ",
        sep_right = sep.right_upper_triangle_solid(true),
      }))

      -- git lines status
      stl:add_item(nut.git.status.create({
        hl = { fg = color.bg },
        content = {
          nut.git.status.count("added", {
            hl = { fg = color.green, bg = color.darkblue  },
            prefix = "+",
            sep_right = sep.right_upper_triangle_solid(true),
          }),
          nut.git.status.count("changed", {
            hl = { fg = color.yellow, bg = color.darkblue  },
            prefix = "~",
            sep_right = sep.right_upper_triangle_solid(true),
          }),
          nut.git.status.count("removed", {
            hl = { fg = color.red, bg = color.darkblue  },
            prefix = "-",
            sep_right = sep.right_upper_triangle_solid(true),
          }),
        },
      }))
      --
      -- filename
      stl:add_item(nut.buf.filename({
        hl = { fg = color.fg, bg = color.bg, bold = true },
        prefix = " ",
        suffix = " ",
      }))

      -- file modifier
      stl:add_item(nut.buf.filestatus({
        hl = { fg = color.fg, bg = color.bg, bold = true },
        sep_right = sep.right_lower_triangle_solid(true),
        config = {
          modified = "󰏫",
          nomodifiable = "󰏯",
          readonly = "",
          sep = " ",
        },
      }))

      -- breadcrumbs
      stl:add_item(Item({
        hidden = function()
          return not require("nvim-navic").is_available()
        end,
        prefix = "➜ ",
        content = function()
          return require("nvim-navic").get_location()
        end,
      }))
      stl:add_item(nut.spacer())
      stl:add_item(nut.truncation_point())

      -- diagnostics
      stl:add_item(nut.buf.diagnostic_count({
        sep_left = sep.left_lower_triangle_solid(true),
        prefix = " ",
        suffix = " ",
        config = {
          error = { prefix = " ", fg = color.red },
          warn = { prefix = " ", fg = color.yellow },
          info = { prefix = " " },
          hint = { prefix = "󰌶 ", fg = color.aqua },
        },
      }))

      -- filetype
      stl:add_item(nut.buf.filetype({
        hl = { bg = color.darkblue, fg = color.purple },
        sep_left = sep.left_lower_triangle_solid(true),
        prefix = " ",
      }))

      -- python venv
      stl:add_item(Item({
        hl = { bg = color.darkblue, fg = color.purple },
        prefix = " ",
        cache = {
          scope = "buf",
        },
        hidden = function (_, ctx)
          return vim.api.nvim_get_option_value("filetype", { buf = ctx.bufnr }) ~= "python"
        end,
        content = function (_, _)
          -- only suppoorts conda for now
          local python_venv = vim.env.CONDA_DEFAULT_ENV
            if not python_venv then
              python_venv = "system"
            end

          return string.format("(%s)", python_venv)
        end,
      }))

      -- line:col
      stl:add_item(Item({
        hl = { bg = color.darkblue, fg = color.green },
        sep_left = sep.left_lower_triangle_solid(true),
        prefix = " ",
        content = core.group({
          core.code("l"),
          ":",
          core.code("c"),
        }),
        suffix = " ",
      }))

      -- file %
      stl:add_item(Item({
        hl = { bg = color.darkblue, fg = color.aqua },
        sep_left = sep.left_lower_triangle_solid(true),
        prefix = " ",
        content = core.code("P"),
        suffix = " ",
      }))

      nougat.set_statusline(stl)
    end
  },

  -- Indent lines
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    enabled = true,  -- FIXME: noticeable performance hit
    config = function()
      require("ibl").setup({
        debounce = 300,
        indent = {
          char = "▏",
          tab_char = "▏",
        },
        scope = {
          enabled = false,
        },
        exclude = {
          filetypes = {
            "aerial",
            "alpha",
            "dap-repl",
            "dashboard",
            "dockerfile",
            "FTerm",
            "help",
            "man",
            "neo-tree",
            "NeogitCommitView",
            "NeovitStatus",
            "NvimTree",
            "oil",
            "packer",
            "startup",
            "TelescopePrompt",
            "TelescopeResults",
            "toggleterm",
            "tsplayground",
            "qf",
          }
        }
      })
    end
  },

  -- Startup screen
  {
    'glepnir/dashboard-nvim',
    event = 'VimEnter',
    opts = {
      theme = "doom",
      config = {
        header = {
          "                 ",
          "                 ",
          "                 ",
          "                 ",
          "       ^ ^       ",
          "      (O,O)      ",
          "      (   )      ",
          '      -"-"-      ',
          "                 ",
          "                 ",
          "                 ",
        },
        center = {
          {
            icon = "  ",
            desc = "New File",
            key = "n",
            action = "enew",
          },
          {
            icon = "  ",
            desc = "File Tree",
            key = "t",
            action = "Oil",
          },
          {
            icon = "🕮  ",
            desc = "Find File",
            key = "f",
            action = "FzfLua files",
          },
          {
            icon = "🗛  ",
            desc = "Live Grep",
            key = "g",
            action = "FzfLua live_grep",
          },
        },
        footer = {
          "                      ",
          "                      ",
          "Better than yesterday.",
        },
      },
    },
    dependencies = { {'nvim-tree/nvim-web-devicons'}}
  },

  -- UI Sugar
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,

    opts = {
      select = {
        backend = { "telescope", "builtin" },
      },
    }
  },

  -- Diagnostics window
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
    keys = {
      { "<leader>so", "<cmd>TroubleToggle<cr>", desc = "Show diagnostics (outline)" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      mode = "document_diagnostics",
    },
  },

  -- Keymap hints
  -- FIXME: mapping <Leader><CR> works strangely because of clue's special keys
  -- TODO: Profile the performance impact compared to whichkey (not just startup)
  {
    "echasnovski/mini.clue",
    event = "VeryLazy",
    config = function ()
      local miniclue = require('mini.clue')

      miniclue.setup({
        triggers = {
          -- Leader triggers
          { mode = 'n', keys = '<Leader>' },
          { mode = 'x', keys = '<Leader>' },

          -- Built-in completion
          { mode = 'i', keys = '<C-x>' },

          -- `g` key
          { mode = 'n', keys = 'g' },
          { mode = 'x', keys = 'g' },

          -- Marks
          { mode = 'n', keys = "'" },
          { mode = 'n', keys = '`' },
          { mode = 'x', keys = "'" },
          { mode = 'x', keys = '`' },

          -- Registers
          { mode = 'n', keys = '"' },
          { mode = 'x', keys = '"' },
          { mode = 'i', keys = '<C-r>' },
          { mode = 'c', keys = '<C-r>' },

          -- Window commands
          { mode = 'n', keys = '<C-w>' },

          -- `z` key
          { mode = 'n', keys = 'z' },
          { mode = 'x', keys = 'z' },
        },

        clues = {
          -- mini.clue
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),

          -- custom
          { mode = 'n', keys = '<Leader>b', desc = '+Buffer' },
          { mode = 'n', keys = '<Leader>c', desc = '+Code' },
          { mode = 'n', keys = '<Leader>cd', desc = '+Documentation' },
          { mode = 'n', keys = '<Leader>d', desc = '+Debugging/Diff' },
          { mode = 'n', keys = '<Leader>dv', desc = '+Diffview' },
          { mode = 'n', keys = '<Leader>f', desc = '+Find/Files' },
          { mode = 'n', keys = '<Leader>g', desc = '+Git' },
          { mode = 'n', keys = '<Leader>gb', desc = '+Blame' },
          { mode = 'n', keys = '<Leader>gf', desc = '+Find' },
          { mode = 'n', keys = '<Leader>gh', desc = '+Hunk/Highlight' },
          { mode = 'n', keys = '<Leader>m', desc = '+Marks' },
          { mode = 'n', keys = '<Leader>q', desc = '+Quickfix' },
          { mode = 'n', keys = '<Leader>r', desc = '+Remote' },
          { mode = 'n', keys = '<Leader>s', desc = '+Show' },
          { mode = 'n', keys = '<Leader>t', desc = '+Tab' },
          { mode = 'n', keys = '<Leader>T', desc = '+Test' },
          { mode = 'n', keys = '<Leader>tR', desc = '+Test Run' },
          { mode = 'n', keys = '<Leader>td', desc = '+Test Debug' },
          { mode = 'n', keys = '<Leader>to', desc = '+Test Output' },
          { mode = 'n', keys = '<Leader>v', desc = '+Vim' },
          { mode = 'n', keys = '<Leader>w', desc = '+Workspace' },
        },

        window = {
          config = {
            anchor = "SW",
            row = 'auto',
            col = 'auto',
            width = 'auto',
          },
          delay = 800,
        }
      })
    end
  },

  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function ()
      require("notify").setup({
        timeout = 3000,
        max_height = function()
          return math.floor(vim.o.lines * 0.75)
        end,
        max_width = function()
          return math.floor(vim.o.columns * 0.75)
        end,
      })

      vim.notify = require("notify")

    end
  },

}
