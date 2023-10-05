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
      { "<Leader>tn", function()
        vim.ui.input({ prompt = "Enter new tab name: " }, function(input)
          if input == nil or input == "" then
            return
          end
          vim.cmd(string.format("TabRename %s", input))
        end)
      end, desc = "Tab (re)name" },
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
              { '  ', hl = theme.head },
              line.sep('', theme.head, theme.fill),
            },
            line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
              local hl = win.is_current() and theme.current_tab or theme.tab

              return {
                line.sep('', hl, theme.fill),
                win.is_current() and '' or '',
                win.buf_name(),
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
              { '  ', hl = theme.tail },
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
    "freddiehaddad/feline.nvim",
    event = "VeryLazy",
    config = function ()
      local feline_ok, feline = pcall(require, "feline")
      if not feline_ok then
        return
      end

      local navic_ok, navic = pcall(require, "nvim-navic")
      if not navic_ok then
        return
      end

      local one_monokai = {
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

      local vi_mode_colors = {
        NORMAL = "green",
        OP = "green",
        INSERT = "yellow",
        VISUAL = "purple",
        LINES = "orange",
        BLOCK = "dark_red",
        REPLACE = "red",
        COMMAND = "aqua",
      }

      local all_components = {
        vim_mode = {
          provider = {
            name = "vi_mode",
            opts = {
              show_mode_name = true,
            },
          },
          hl = function()
            return {
              fg = require("feline.providers.vi_mode").get_mode_color(),
              bg = "darkblue",
              style = "bold",
              name = "FelineModeColor",
            }
          end,
          left_sep = "block",
          right_sep = "block",
          icon = "",
        },
        git_branch = {
          provider = "git_branch",
          hl = {
            fg = "aqua",
            bg = "darkblue",
            style = "NONE",
          },
          left_sep = "block",
          right_sep = "block",
        },
        git_diff_added = {
          provider = "git_diff_added",
          hl = {
            fg = "green",
            bg = "darkblue",
          },
          left_sep = "block",
          right_sep = "block",
          icon = "+"
        },
        git_diff_removed = {
          provider = "git_diff_removed",
          hl = {
            fg = "red",
            bg = "darkblue",
          },
          left_sep = "block",
          right_sep = "block",
          icon = "𐆑"
        },
        git_diff_changed = {
          provider = "git_diff_changed",
          hl = {
            fg = "yellow",
            bg = "darkblue",
          },
          left_sep = "block",
          right_sep = "right_filled",
          icon = "𐅼"
        },
        separator = {
          provider = "",
        },
        file_info = {
          provider = {
            name = "file_info",
            opts = {
              type = "relative",
            },
          },
          hl = {
            style = "bold",
          },
          left_sep = " ",
          right_sep = " ",
          priority = 1,
        },
        diagnostic_errors = {
          provider = "diagnostic_errors",
          hl = {
            fg = "red",
          },
        },
        diagnostic_warnings = {
          provider = "diagnostic_warnings",
          hl = {
            fg = "yellow",
          },
        },
        diagnostic_hints = {
          provider = "diagnostic_hints",
          hl = {
            fg = "aqua",
          },
        },
        diagnostic_info = {
          provider = "diagnostic_info",
        },
        file_type = {
          provider = {
            name = "file_type",
            opts = {
              filetype_icon = true,
              case = "titlecase",
            },
          },
          hl = {
            fg = "red",
            bg = "darkblue",
            style = "NONE",
          },
          left_sep = "block",
          right_sep = "block",
        },
        position = {
          provider = "position",
          hl = {
            fg = "green",
            bg = "darkblue",
            style = "NONE",
          },
          left_sep = "block",
          right_sep = "block",
        },
        line_percentage = {
          provider = "line_percentage",
          hl = {
            fg = "aqua",
            bg = "darkblue",
            style = "NONE",
          },
          left_sep = "block",
          right_sep = "block",
        },
        navic = {
          provider = function()
            return navic.get_location()
          end,
          enabled = function()
            return navic.is_available()
          end,
          hl = {
            fg = "faded_fg"
          },
        },
        python_venv = {
          provider = "python_venv",
          update = { "DirChanged", "BufEnter" },
          hl = {
            bg = "darkblue",
            style = "NONE",
          },
        },
      }

      local left = {
        all_components.vim_mode,
        all_components.git_branch,
        all_components.git_diff_added,
        all_components.git_diff_removed,
        all_components.git_diff_changed,
        all_components.separator,
        all_components.diagnostic_hints,
        all_components.diagnostic_info,
        all_components.diagnostic_warnings,
        all_components.diagnostic_errors,
        all_components.file_info,
        all_components.navic,
      }

      local right = {
        all_components.python_venv,
        all_components.file_type,
        all_components.position,
        all_components.line_percentage,
      }

      local components = {
        active = {
          left,
          right,
        },
        inactive = {
          left,
          right,
        },
      }

      feline.setup({
        components = components,
        custom_providers = {
          python_venv = function()
            local ftype = vim.bo.filetype
            if ftype ~= "python" then
              return ""
            end

            local python_venv = vim.env.CONDA_DEFAULT_ENV
            if not python_venv then
              python_venv = "system"
            end

            return python_venv
          end
        },
        theme = one_monokai,
        vi_mode_colors = vi_mode_colors,
      })
    end,
  },

  -- Indent lines
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
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
            "dashboard",
            "help",
            "toggleterm",
            "packer",
            "aerial",
            "alpha",
            "FTerm",
            "man",
            "TelescopePrompt",
            "TelescopeResults",
            "NeogitCommitView",
            "neo-tree",
            "dockerfile",
            "NvimTree",
            "NeovitStatus",
            "tsplayground",
            "startup",
            "dap-repl",
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
            action = "Neotree toggle",
          },
          {
            icon = "  ",
            desc = "Find File",
            key = "f",
            action = "FzfLua files",
          },
          {
            icon = "󰈭  ",
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
          { mode = 'n', keys = '<Leader>n', desc = '+Neotree' },
          { mode = 'n', keys = '<Leader>q', desc = '+Quickfix' },
          { mode = 'n', keys = '<Leader>r', desc = '+Remote' },
          { mode = 'n', keys = '<Leader>s', desc = '+Show' },
          { mode = 'n', keys = '<Leader>t', desc = '+Test/Tab' },
          { mode = 'n', keys = '<Leader>tr', desc = '+Test Run' },
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
