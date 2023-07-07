return {
  -- File tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    keys = {
      { "<Leader>nn", "<cmd>Neotree filesystem focus left toggle<CR>", desc =  "Neotree toggle"  },
      { "<Leader>nf", "<cmd>Neotree filesystem focus reveal toggle<CR>", desc =  "Neotree toggle (focused on file)"  },
      { "<Leader>ng", "<cmd>Neotree git_status left<CR>", desc =  "Neotree git status"  },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    init = function ()
      -- load neo-tree on directory open so it hijacks netrw
      vim.cmd("silent! autocmd! FileExplorer *")
      vim.api.nvim_create_autocmd(
        { "BufEnter", "BufWinEnter" },
        {
          pattern = { "*" },
          callback = function ()
            local bufname = vim.api.nvim_buf_get_name(0)
            local stats = vim.loop.fs_stat(bufname)
            if not stats then
              return false
            end
            if stats.type ~= "directory" then
              return false
            end
            require("neo-tree")
          end
        }
      )
    end,
    opts = {
      close_if_last_window = false,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = false,
      default_component_configs = {
        indent = {
          indent_size = 2,
          padding = 1, -- extra padding on left hand side
          -- indent guides
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          highlight = "NeoTreeIndentMarker",
          -- expander config, needed for nesting files
          with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "ﰊ",
          default = "*",
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = false,
        },
        git_status = {
          symbols = {
            -- Change type
            added = "✚",
            deleted = "✖",
            modified = "",
            renamed = "",
            -- Status type
            untracked = "",
            ignored = "",
            unstaged = "",
            staged = "",
            conflict = "",
          },
        },
      },
      window = {
        position = "left",
        width = 40,
        mappings = {
          ["<space>"] = "",
          ["<2-LeftMouse>"] = "open",
          ["<cr>"] = "open",
          ["s"] = "open_split",
          ["v"] = "open_vsplit",
          ["C"] = "close_node",
          ["<bs>"] = "navigate_up",
          ["."] = "set_root",
          ["H"] = "toggle_hidden",
          ["R"] = "refresh",
          -- ["/"] = "fuzzy_finder",
          ["/"] = "",
          ["f"] = "filter_on_submit",
          ["w"] = "",
          ["<c-x>"] = "clear_filter",
          ["a"] = "add",
          ["A"] = "add_directory",
          ["d"] = "delete",
          ["r"] = "rename",
          ["y"] = function (state) -- copy absolute path to system clipboard
            local node = state.tree:get_node()
            vim.fn.setreg("+", node.path)
            print(string.format("Copied path '%s' to clipboard.", node.path))
          end,
          ["Y"] = "copy_to_clipboard", -- copy file to system clipboard
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["c"] = "copy", -- takes text input for destination
          ["m"] = "move", -- takes text input for destination
          ["q"] = "close_window",
        },
      },
      nesting_rules = {},
      filesystem = {
        filtered_items = {
          visible = true, -- when true, they will just be displayed differently than normal items
          hide_dotfiles = true,
          hide_gitignored = false,
          hide_by_name = {
            ".DS_Store",
            "thumbs.db",
          },
          never_show = { -- remains hidden even if visible is toggled to true
          },
        },
        follow_current_file = false,
        hijack_netrw_behavior = "open_default",
        use_libuv_file_watcher = true,
        --
        window = {
          mappings = {
            ["gu"] = "git_unstage_file",
            ["ga"] = "git_add_file",
            ["gx"] = "git_revert_file",
            ["gc"] = "git_commit",
            ["gp"] = "git_push",
            ["gg"] = "git_commit_and_push",
          },
        },
      },
      buffers = {
        show_unloaded = true,
        window = {
          mappings = {
            ["bd"] = "buffer_delete",
          },
        },
      },
      git_status = {
        window = {
          position = "float",
          mappings = {
            ["A"] = "git_add_all",
            ["gu"] = "git_unstage_file",
            ["ga"] = "git_add_file",
            ["gr"] = "git_revert_file",
            ["gc"] = "git_commit",
            ["gp"] = "git_push",
            ["gg"] = "git_commit_and_push",
          },
        },
      },
    }
  },

  -- Debugging
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    keys = {
      { "<Leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug breakpoint" },
      { "<Leader>dc", function() require("dap").continue() end, desc = "Debug continue (or start)" },
      { "<Leader>dj", function() require("dap").step_over() end, desc = "Debug step over" },
      { "<Leader>di", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Debug inspect" },
      { "<Leader>do", function() require("dapui").float_element() end, desc = "Debug open float" },
      { "<Leader>dl", function() require("dap").step_into() end, desc = "Debug step into" },
      { "<Leader>dh", function() require("dap").step_out() end, desc = "Debug step out" },
      { "<Leader>dr", function() require("dap").repl.open() end, desc = "Debug repl" },
      { "<Leader>ds", function() require("dap").close(); require("dapui").close() end, desc = "Debug stop (and close)" },
    },
    config = function ()
      local dap = require("dap")
      local dapui = require("dapui")

      vim.cmd("au FileType dap-repl lua require('dap.ext.autocompl').attach()")
      vim.fn.sign_define("DapBreakpoint", { text = "🔺", texthl = "", linehl = "", numhl = "" })

      -- TODO: add a check for debugpy installation in the current environment

      --          adapters
      -- ──────────────────────────────
      dap.adapters.python_launch = {
        type = "executable",
        command = vim.fn.expand("python3"),
        args = { "-m", "debugpy.adapter" },
        initialize_timeout_sec = 5,
      }
      dap.adapters.python_attach = function (callback, user_config)
        local address = vim.fn.input({ prompt = "Address (default 127.0.0.1:5678): "})
        local host
        local port

        if string.find(address, ":") ~= nil then
          host, port = unpack(vim.fn.split(address, ":"))
        else
          host = "127.0.0.1"
          port = "5678"
        end

        callback({
          type = "server",
          host = host,
          port = port,
        })
      end

      -- use python_launch as the default python adapter
      dap.adapters.python = dap.adapters.python_launch

      -- load launch.json
      require('dap.ext.vscode').load_launchjs(vim.fn.getcwd() .. '/.vscode/launch.json')

      --          configs
      -- ──────────────────────────────
      dap.configurations.python = {
        {
          name = "[Launch] script",
          type = "python_launch",
          request = "launch",
          program = "${file}",
          args = function ()
            local args = vim.fn.input({ prompt = "Script args: "})
            args = vim.fn.split(args, " ")
            return args
          end,
          cwd = "${workspaceFolder}",
          pythonPath = "python3",
        },
        {
          name = "[Launch] module",
          type = "python_launch",
          request = "launch",
          cwd = "${workspaceFolder}",
          module = function()
            local name = vim.fn.expand("%:r")
            name = string.gsub(name, "/", ".")
            name = string.gsub(name, "\\", ".")
            return name
          end,
          args = function ()
            local args = vim.fn.input({ prompt = "Module args: "})
            args = vim.fn.split(args, " ")
            return args
          end,
          pythonPath = "python3",
        },
        {
          name = "[Attach] to running app",
          type = "python_attach",
          request = "attach",
        },
      }

      --          dapui
      -- ──────────────────────────────
      dapui.setup({
        icons = {
          expanded = "―",
          collapsed = "=",
        },
        mappings = {
          expand = { "<Tab>", "<2-LeftMouse>" },
          open = "<CR>",
          remove = "dd",
          edit = "e",
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.4 },
              { id = "breakpoints", size = 0.1 },
              { id = "stacks", size = 0.2 },
              { id = "watches" , size = 0.2 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 1 },
            },
            size = 10,
            position = "bottom",
          }
        },
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "",
            play = "",
            step_into = "",
            step_over = "",
            step_out = "",
            step_back = "",
            run_last = "",
            terminate = "",
          },
        },
        floating = {
          max_height = nil, -- These can be integers or a float between 0 and 1.
          max_width = nil, -- Floats will be treated as percentage of your screen.
        },
      })

      -- load launch.json
      require('dap.ext.vscode').load_launchjs(
        vim.fn.getcwd() .. '/.vscode/launch.json',
        {
          python_launch = { "python" },
          python_attach = { "python" },
        }
      )

      -- start ui automatically
      dap.listeners.after["event_initialized"]["custom_dapui"] = function()
        dapui.open()
      end
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    lazy = true,
    dependencies = { "mfussenegger/nvim-dap" },
  },

  -- check "dccsillag/magma-nvim"
  -- check ahmedkhalf/jupyter-nvim

  -- Tests
  {
    "nvim-neotest/neotest",
    lazy = true,
    keys = {
      -- run
      { "<Leader>trf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test run (file)" },
      { "<Leader>trn", function() require("neotest").run.run() end, desc = "Test run (nearest)" },
      { "<Leader>trs", function() require("neotest").run.run({ suite = true }) end, desc = "Test run (full suite)" },
      { "<Leader>trl", function() require("neotest").run.run_last() end, desc = "Test run (last)" },
      -- debug
      { "<Leader>tdf", function() require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" }) end, desc = "Test debug (file)" },
      { "<Leader>tdn", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Test debug (nearest)" },
      { "<Leader>tds", function() require("neotest").run.run({ suite = true, strategy = "dap" }) end, desc = "Test debug (full suite)" },
      -- stop
      { "<Leader>ts", function() require("neotest").run.stop() end, desc = "Test stop" },
      -- output
      { "<Leader>too", function() require("neotest").output.open({ enter = true }) end, desc = "Test output open" },
      { "<Leader>top", function() require("neotest").output_panel.toggle() end, desc = "Test output panel" },
      { "<Leader>tos", function() require("neotest").summary.toggle() end, desc = "Test output summary" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-python",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
          }),
        },
      })
    end
  },

  -- Terminal
  {
    "numToStr/FTerm.nvim",
    init = function ()
      vim.api.nvim_create_user_command(
        "ChezmoiApply",
        function() require('FTerm').scratch({ cmd = "chezmoi apply -v $(chezmoi target-path .)" }) end, {}
      )
    end,
    keys = {
      { "<Leader>ce", function() require("plugin_utils").run_code() end, desc = "Code execute" },
      { "<c-_>", function() require("FTerm").toggle() end, mode = { "n", "t" }, desc = "Terminal toggle" },
    },
    opts = {
      border = 'rounded',
      blend = 3,
      dimensions  = {
        height = 0.9,
        width = 0.9,
      },
    },
  },

  -- Remote
  {
    "kenn7/vim-arsync",
    init = function ()
      vim.keymap.set("n", "<Leader>rP", "<cmd>ARsyncUp<CR>", { desc = "Remote push (rsync)" })
      vim.keymap.set("n", "<Leader>rp", "<cmd>ARsyncDown<CR>", { desc = "Remote pull (rsync)" })
    end,
    cmd = { "ARshowConf", "ARsyncUp", "ARsyncDown" },
  },
  -- check: https://github.com/chipsenkbeil/distant.nvim
  -- check: https://github.com/miversen33/netman.nvim

  -- Fzf lua
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      -- files
      { "<Leader>ff", function() require("fzf-lua").files({
        cmd = "fd --type f --ignore --follow",
      }) end, desc = "Find files" },
      { "<Leader>fF", function()
        require("fzf-lua").files({
          cmd = "fd --type f --hidden --no-ignore --follow",
        })
      end,
        desc = "Find files (all)",
      },

      -- grep
      { "<Leader>fg", function() require("fzf-lua").live_grep({
        cmd = "rg --column --line-number --no-heading --color=always --smart-case --max-columns=4096",
      }) end, desc = "Find grep" },
      { "<Leader>fG", function()
        require("fzf-lua").live_grep({
        cmd = "rg --column --line-number --no-heading --color=always --smart-case --max-columns=4096 " ..
          "--no-ignore --hidden",
        })
      end, desc = "Find grep (all)" },

      { "<Leader>f<C-g>", function() require("plugin_utils").rg_dir() end, desc = "Find grep (in dir)" },
      { "<Leader>fW", function() require("fzf-lua").grep_cword() end,
        desc = "Find word under cursor (in project)",
        mode = { "n" },
      },
      { "<Leader>fW", function() require("fzf-lua").grep_visual() end,
        desc = "Find word under cursor (in project)",
        mode = { "v" },
      },

      -- git
      { "<Leader>gff", function() require("fzf-lua").git_files() end, desc = "Git find files" },
      { "<Leader>gfc", function() require("fzf-lua").git_bcommits() end, desc = "Git find commits (buffer)" },
      { "<Leader>gfC", function() require("fzf-lua").git_commits() end, desc = "Git find commits (all)" },
      { "<Leader>gfb", function() require("fzf-lua").git_branches() end, desc = "Git find branches (all)" },

      -- extra
      { "<Leader>fb", function() require("fzf-lua").buffers() end, desc = "Find buffers" },
      -- TODO: replace with fzf implementation if it gets pretty
      { "<Leader>fz", function() require("telescope.builtin").current_buffer_fuzzy_find() end, desc = "Find fuZzy (in buffer)" },
    },
    cmd = "FzfLua",
    config = function()
      local actions = require("fzf-lua.actions")

      require("fzf-lua").setup({
        "borderless_full",
        global_git_icons = true,
        winopts = {
          height = 0.97,
          width = 0.97,

          on_create = function()
            vim.wo.winblend = 10
          end,

          preview = {
            delay = 80,
            title_pos = "center",
          },
        },

        fzf_opts = {
          ["--layout"] = "reverse",
          ["--pointer"] = "➜ ",
        },

        fzf_colors = {
          ["hl"] = { "fg", "TelescopeMatching" },
          ["hl+"] = { "fg", "TelescopeMatching" },

          ["fg+"] = { "fg", "TelescopeSelection" },
          ["bg+"] = { "bg", "TelescopeSelection" },

          ["pointer"] = { "fg", "TelescopeSelectionCaret" },
          ["marker"] = { "fg", "TelescopeSelectionCaret" },
        },

        files = {
          cwd_prompt_shorten_val = 5,
          git_icons = true,
        },

        grep = {
          rg_glob = true,
        },

        keymap = {
          builtin = {
            ["<F1>"] = "toggle-help",
            ["<F2>"] = "toggle-fullscreen",
            -- Only valid with the 'builtin' previewer
            ["<F3>"] = "toggle-preview-wrap",
            ["<C-p>"] = "toggle-preview",
            ["<C-r>"] = "toggle-preview-ccw",
            ["<F6>"] = "toggle-preview-cw",
            ["<A-j>"] = "preview-page-down",
            ["<A-k>"] = "preview-page-up",
            ["<S-left>"] = "preview-page-reset",
          },
          fzf = {
            ["ctrl-z"] = "abort",
            ["ctrl-f"] = "half-page-down",
            ["ctrl-b"] = "half-page-up",
            ["ctrl-a"] = "beginning-of-line",
            ["ctrl-e"] = "end-of-line",
            ["alt-a"] = "toggle-all",
            -- Only valid with fzf previewers (bat/cat/git/etc)
            ["f3"] = "toggle-preview-wrap",
            ["ctrl-p"] = "toggle-preview",
            ["ctrl-d"] = "preview-page-down",
            ["ctrl-u"] = "preview-page-up",
            ["ctrl-q"] = "select-all+accept",
          },
        },

        actions = {
          files = {
            ["default"] = actions.file_edit_or_qf,
            ["ctrl-s"] = actions.file_split,
            ["ctrl-v"] = actions.file_vsplit,
            ["ctrl-t"] = actions.file_tabedit,
            ["ctrl-q"] = actions.file_sel_to_qf,
            ["alt-l"] = actions.file_sel_to_ll,
          },
          buffers = {
            ["default"] = actions.buf_edit,
            ["ctrl-x"] = actions.buf_split,
            ["ctrl-v"] = actions.buf_vsplit,
            ["ctrl-t"] = actions.buf_tabedit,
          }
        },

      })
    end,
  },
}
