return {
  -- File explorer and modifier
  -- TODO: add support for image preview
  {
    "stevearc/oil.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Oil",
    keys = {
      {
        "<BS>",
        function()
          require("oil").open()
        end,
        desc = "Open buffer's directory",
      },
      {
        "-",
        function()
          require("oil").open()
        end,
        desc = "Open buffer's directory",
      },
    },
    -- lazy setup: https://github.com/folke/lazy.nvim/issues/533#issuecomment-1489174249
    init = function()
      if vim.fn.argc() == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        -- Capture the protocol and lazy load oil if it is "oil-ssh", besides also lazy
        -- loading it when the first argument is a directory.
        local adapter = string.match(vim.fn.argv(0), "^([%l-]*)://")
        if (stat and stat.type == "directory") or adapter == "oil-ssh" then
          require("lazy").load({ plugins = { "oil.nvim" } })
        end
      end
      if not require("lazy.core.config").plugins["oil.nvim"]._.loaded then
        vim.api.nvim_create_autocmd("BufNew", {
          callback = function()
            if vim.fn.isdirectory(vim.fn.expand("<afile>")) == 1 then
              require("lazy").load({ plugins = { "oil.nvim" } })
              -- Once oil is loaded, we can delete this autocmd
              return true
            end
          end,
        })
      end
    end,
    opts = {
      columns = {
        "icon",
      },
      lsp_file_methods = {
        timeout_ms = 5000,
      },
      delete_to_trash = false,
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-s>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-r>"] = "actions.refresh",
        ["<C-y>"] = "actions.yank_entry",
        ["<C-S-y>"] = "actions.copy_to_system_clipboard",
        ["<C-q>"] = "actions.add_to_qflist",
        ["<BS>"] = "actions.parent",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
      },
      use_default_keymaps = false,
      view_options = {
        show_hidden = true,
      },
    },
  },

  -- Debugging
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- check out: igorlfs/nvim-dap-view
      -- { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },
      {
        "igorlfs/nvim-dap-view",
        opts = {
          windows = {
            terminal = {
              start_hidden = true,
              hide = { "python", "python_launch", "python_attach" },
            },
          },
        },
      },
    },
    lazy = true,
    keys = {
      {
        "<Leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Debug breakpoint",
      },
      {
        "<Leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Debug continue (or start)",
      },
      {
        "<Leader>dj",
        function()
          require("dap").step_over()
        end,
        desc = "Debug step over",
      },
      {
        "<Leader>di",
        function()
          -- require("dapui").eval()
          require("dap.ui.widgets").hover(nil, { border = "rounded" })
        end,
        mode = { "n", "v" },
        desc = "Debug inspect",
      },
      {
        "<Leader>dw",
        "<cmd>DapViewWatch<CR>",
        mode = { "n", "v" },
        desc = "Debug inspect",
      },
      -- {
      --   "<Leader>do",
      --   function()
      --     require("dapui").float_element()
      --   end,
      --   desc = "Debug open float",
      -- },
      {
        "<Leader>dl",
        function()
          require("dap").step_into()
        end,
        desc = "Debug step into",
      },
      {
        "<Leader>dh",
        function()
          require("dap").step_out()
        end,
        desc = "Debug step out",
      },
      {
        "<Leader>dr",
        function()
          require("dap").repl.open()
        end,
        desc = "Debug repl",
      },
      {
        "<Leader>dz",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "Debug run to cursor",
      },
      {
        "<Leader>ds",
        function()
          require("dap-view").close()
          require("dap").close()
          -- require("dapui").close()
        end,
        desc = "Debug stop (and close)",
      },
    },
    config = function()
      local dap = require("dap")
      -- local dapui = require("dapui")

      vim.cmd("au FileType dap-repl lua require('dap.ext.autocompl').attach()")

      -- sign customization
      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "Error", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "Error", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "Error", linehl = "", numhl = "" })

      --          adapters
      -- ──────────────────────────────
      dap.adapters.python_launch = {
        type = "executable",
        command = vim.fn.expand("debugpy-adapter"), -- Installed by Mason, injected to PATH
        initialize_timeout_sec = 5,
      }
      dap.adapters.python_attach = function(callback, user_config)
        local address = vim.fn.input({ prompt = "Address (default 127.0.0.1:5678): " })
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

      --          configs
      -- ──────────────────────────────
      dap.configurations.python = {
        {
          name = "[Launch] script",
          type = "python_launch",
          request = "launch",
          program = "${file}",
          args = function()
            local args = vim.fn.input({ prompt = "Script args: " })
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
          args = function()
            local args = vim.fn.input({ prompt = "Module args: " })
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

      -- start ui automatically
      dap.listeners.after["event_initialized"]["custom_ui"] = function()
        -- dapui.open()
        require("dap-view").open()
      end
    end,
  },

  -- Python-specific
  -- check "benlubas/molten-nvim" and "jmbuhr/otter.nvim"
  {
    "GCBallesteros/jupytext.nvim",
    event = { "BufReadCmd *.ipynb" },
    config = function()
      require("jupytext").setup({
        style = "markdown",
        output_extension = "md",
        force_ft = "markdown",
      })

      -- Load treesitter, as it's lazy loaded on BufReadPost, but this plugin doesn't
      -- execute it, missing the highlights
      require("nvim-treesitter")
    end,
  },

  -- Tests
  {
    "nvim-neotest/neotest",
    lazy = true,
    keys = {
      -- run
      {
        "<Leader>Trf",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Test run (file)",
      },
      {
        "<Leader>Trn",
        function()
          require("neotest").run.run()
        end,
        desc = "Test run (nearest)",
      },
      {
        "<Leader>Trs",
        function()
          require("neotest").run.run({ suite = true })
        end,
        desc = "Test run (full suite)",
      },
      {
        "<Leader>Trl",
        function()
          require("neotest").run.run_last()
        end,
        desc = "Test run (last)",
      },
      -- debug
      {
        "<Leader>Tdf",
        function()
          require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" })
        end,
        desc = "Test debug (file)",
      },
      {
        "<Leader>Tdn",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "Test debug (nearest)",
      },
      {
        "<Leader>Tds",
        function()
          require("neotest").run.run({ suite = true, strategy = "dap" })
        end,
        desc = "Test debug (full suite)",
      },
      -- stop
      {
        "<Leader>Ts",
        function()
          require("neotest").run.stop()
        end,
        desc = "Test stop",
      },
      -- output
      {
        "<Leader>Too",
        function()
          require("neotest").output.open({ enter = true })
        end,
        desc = "Test output open",
      },
      {
        "<Leader>Top",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Test output panel",
      },
      {
        "<Leader>Tos",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Test output summary",
      },
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
    end,
  },

  -- Terminal
  {
    "numToStr/FTerm.nvim",
    cmd = "FTermToggle",
    keys = {
      {
        "<Leader>ce",
        function()
          require("plugin_utils").run_code()
        end,
        desc = "Code execute",
      },
      -- two mappings for toggle to allow support for kitty and tmux (which interpret keys differently)
      {
        "<c-_>",
        function()
          require("FTerm").toggle()
        end,
        mode = { "n", "t" },
        desc = "Terminal toggle",
      },
      {
        "<c-/>",
        function()
          require("FTerm").toggle()
        end,
        mode = { "n", "t" },
        desc = "Terminal toggle",
      },
    },
    init = function()
      vim.api.nvim_create_user_command("ChezmoiApply", function()
        local dir_is_managed = vim
          .system({
            "sh",
            "-c",
            'test -n "$(chezmoi managed $(chezmoi target-path .))"',
          })
          :wait().code == 0

        -- Fallback on applying on a file-basis
        local target = "."
        if not dir_is_managed then
          target = vim.fn.expand("%")
        end

        target = string.gsub(vim.system({ "chezmoi", "target-path", target }, { text = true }):wait().stdout, "\n", "")
        vim.notify(string.format("Applying changes to %s", target), vim.log.levels.INFO, { title = "Chezmoi" })

        require("FTerm").scratch({ cmd = string.format("chezmoi apply -v %s", target) })
      end, {})
      vim.api.nvim_create_user_command("FTermToggle", function()
        require("FTerm").toggle()
      end, { bang = true })
    end,
    opts = {
      border = "rounded",
      blend = 3,
      dimensions = {
        height = 0.9,
        width = 0.9,
      },
    },
  },

  -- Remote
  {
    "kenn7/vim-arsync",
    init = function()
      vim.keymap.set("n", "<Leader>rP", "<cmd>ARsyncUp<CR>", { desc = "Remote push (rsync)" })
      vim.keymap.set("n", "<Leader>rp", "<cmd>ARsyncDown<CR>", { desc = "Remote pull (rsync)" })
    end,
    cmd = { "ARshowConf", "ARsyncUp", "ARsyncDown" },
  },
  {
    "amitds1997/remote-nvim.nvim",
    cmd = { "RemoteStart", "RemoteStop", "RemoteCleanup", "RemoteConfigDel", "RemoteInfo" },
    enabled = false,
    -- version = "*",
    version = "v0.3.9", -- to mitigate bug where config copying fails
    dependencies = {
      "nvim-lua/plenary.nvim", -- For standard functions
      "MunifTanjim/nui.nvim", -- To build the plugin UI
      "nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
    },
    opts = {
      client_callback = function(port, workspace_config)
        local cmd = ("kitty -e nvim --server localhost:%s --remote-ui"):format(port)
        vim.fn.jobstart(cmd, {
          detach = true,
          on_exit = function(job_id, exit_code, event_type)
            -- This function will be called when the job exits
            print("Client", job_id, "exited with code", exit_code, "Event type:", event_type)
          end,
        })
      end,
    },
  },

  -- Diagnostics window
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>so", "<cmd>Trouble diagnostics<cr>", desc = "Show diagnostics (outline)" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      mode = "document_diagnostics",
    },
  },

  -- Fzf lua
  {
    "ibhagwan/fzf-lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-treesitter/nvim-treesitter",
    },
    init = function()
      _G._usr_fzflua_files = function(func_opts)
        local fzf_opts = {}
        local cmd_tbl = {
          "fd",
          "--color=never",
          "--type f",
          "--follow",
        }

        if func_opts.ignore then
          cmd_tbl[#cmd_tbl + 1] = "--ignore"
        else
          cmd_tbl[#cmd_tbl + 1] = "--no-ignore"
        end

        if func_opts.hidden then
          cmd_tbl[#cmd_tbl + 1] = "--hidden"
        else
          cmd_tbl[#cmd_tbl + 1] = "--no-hidden"
        end

        if func_opts.exclude then
          if type(func_opts.exclude) == "string" then
            func_opts.exclude = { func_opts.exclude }
          end
          for _, pattern in ipairs(func_opts.exclude) do
            cmd_tbl[#cmd_tbl + 1] = string.format([[--exclude '%s']], pattern)
          end
        end

        fzf_opts.cmd = table.concat(cmd_tbl, " ")
        require("fzf-lua").files(fzf_opts)
      end

      -- Use fzf-lua for vim.ui.select
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "fzf-lua" } })

        if not require("fzf-lua.providers.ui_select").is_registered() then
          require("fzf-lua").register_ui_select(function(_, items)
            local min_h, max_h = 0.15, 0.70
            local h = (#items + 4) / vim.o.lines
            if h < min_h then
              h = min_h
            elseif h > max_h then
              h = max_h
            end
            return { winopts = { height = h, width = 0.60, row = 0.40 } }
          end, true)
        end

        return vim.ui.select(...)
      end

    end,
    keys = {
      -- files
      {
        "<Leader><Leader>",
        "<cmd>FzfLua<cr>",
        desc = "Fzf menu",
      },
      {
        "<Leader>ff",
        function()
          _G._usr_fzflua_files({
            ignore = true,
            hidden = false,
            pretty = false,
          })
        end,
        desc = "Find files",
      },
      {
        "<Leader>fF",
        function()
          _G._usr_fzflua_files({
            ignore = false,
            hidden = true,
            pretty = false,
            exclude = { ".git/*", "**/.mypy_cache/*" },
          })
        end,
        desc = "Find files (all)",
      },
      {
        "<Leader>fd",
        function()
          require("fzf-lua").files({
            cwd = "~/Downloads/",
          })
        end,
        desc = "Find files (downloads)",
      },

      -- grep
      {
        "<Leader>fg",
        function()
          require("fzf-lua").live_grep({
            cmd = "rg --column --line-number --no-heading --color=always --smart-case --max-columns=4096",
          })
        end,
        desc = "Find grep",
      },
      {
        "<Leader>fG",
        function()
          require("fzf-lua").live_grep({
            cmd = "rg --column --line-number --no-heading --color=always --smart-case --max-columns=4096 "
              .. "--no-ignore --hidden",
          })
        end,
        desc = "Find grep (all)",
      },

      {
        "<Leader>f<C-g>",
        function()
          require("plugin_utils").rg_dir()
        end,
        desc = "Find grep (in dir)",
      },
      {
        "<Leader>fW",
        function()
          require("fzf-lua").grep_cword()
        end,
        desc = "Find word under cursor (in project)",
        mode = { "n" },
      },
      {
        "<Leader>fW",
        function()
          require("fzf-lua").grep_visual()
        end,
        desc = "Find word under cursor (in project)",
        mode = { "v" },
      },

      -- git
      {
        "<Leader>gff",
        function()
          require("fzf-lua").git_files()
        end,
        desc = "Git find files",
      },
      {
        "<Leader>gfc",
        function()
          require("fzf-lua").git_bcommits()
        end,
        desc = "Git find commits (buffer)",
      },
      {
        "<Leader>gfC",
        function()
          require("fzf-lua").git_commits()
        end,
        desc = "Git find commits (all)",
      },
      {
        "<Leader>gfb",
        function()
          require("fzf-lua").git_branches()
        end,
        desc = "Git find branches (all)",
      },

      -- extra
      {
        "<Leader>fb",
        function()
          require("fzf-lua").buffers({ sort_lastused = true })
        end,
        desc = "Find buffers",
      },
      {
        "<Leader>fz",
        function()
          require("fzf-lua").blines()
        end,
        desc = "Find fuZzy (in buffer)",
      },
    },
    cmd = "FzfLua",
    config = function()
      local actions = require("fzf-lua.actions")

      require("fzf-lua").setup({
        "borderless_full",

        defaults = {
          file_icons = true,
        },

        winopts = {
          height = 0.90,
          width = 0.90,

          on_create = function()
            vim.wo.winblend = 0
          end,

          preview = {
            delay = 80,
            title_pos = "center",
            layout = "horizontal",
            vertical = "down:60%",
          },
        },
        hls = {
          title = "Folded",
          preview_title = "Folded",
        },

        fzf_opts = {
          ["--layout"] = "reverse",
          ["--pointer"] = "󰁕",
        },

        fzf_colors = {
          ["hl"] = { "fg", "TelescopeMatching" },
          ["hl+"] = { "fg", "TelescopeMatching" },

          ["fg+"] = { "fg", "TelescopeSelection" },
          ["bg+"] = { "bg", "TelescopeSelection" },

          ["pointer"] = { "fg", "TelescopeSelectionCaret" },
          ["marker"] = { "fg", "TelescopeSelectionCaret" },
        },

        previewers = {
          builtin = {
            syntax_limit_b = 1024 * 1024 * 5,
          },
        },

        -- providers
        files = {
          cwd_prompt_shorten_val = 5,
          git_icons = true,
          formatter = "path.dirname_first",
        },

        grep = {
          rg_glob = true,
          formatter = "path.dirname_first",
        },

        lsp = {
          includeDeclaration = false,
          jump1 = false,
          symbols = {
            child_prefix = true,
          },
          code_actions = {
            previewer = "codeaction_native",
          },
        },

        buffers = {
          formatter = "path.dirname_first",
        },

        tabs = {
          formatter = "path.dirname_first",
        },

        -- keymaps
        keymap = {
          builtin = {
            ["<F1>"] = "toggle-help",
            ["<F2>"] = "toggle-fullscreen",
            -- Only valid with the 'builtin' previewer
            ["<F3>"] = "toggle-preview-wrap",
            ["<C-p>"] = "toggle-preview",
            ["<C-r>"] = "toggle-preview-ccw",
            ["<F6>"] = "toggle-preview-cw",
            ["<A-j>"] = "preview-down",
            ["<A-k>"] = "preview-up",
            ["<C-d>"] = "preview-page-down",
            ["<C-u>"] = "preview-page-up",
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
            ["alt-q"] = { fn = actions.file_sel_to_qf, prefix = "select-all+accept" },
            ["alt-l"] = actions.file_sel_to_ll,

            -- FIXME: Toggle functionality introduced in:
            -- https://github.com/ibhagwan/fzf-lua/commit/d1473afc7a617e6c66b5bb3caf10949499af8269
            -- However, if you want to disable the UI for them, title_flags=false doesn't
            -- work for some reason
            -- ["alt-i"] = actions.toggle_ignore,
            -- ["alt-h"] = actions.toggle_hidden,
            -- ["alt-f"] = actions.toggle_follow,
          },
          buffers = {
            ["default"] = actions.buf_edit,
            ["ctrl-x"] = actions.buf_split,
            ["ctrl-v"] = actions.buf_vsplit,
            ["ctrl-t"] = actions.buf_tabedit,
          },
        },
      })
    end,
  },

  -- Profilers
  {
    "t-troebst/perfanno.nvim",
    cmd = {
      "PerfLoadCallGraph",
      "PerfLoadFlameGraph",
      "PerfLuaProfileStart",
      "PerfPickEvent",
      "PerfCycleFormat",
      "PerfHottestLines",
    },
    config = function()
      local util = require("perfanno.util")
      local bgcolor = vim.fn.synIDattr(vim.fn.hlID("Normal"), "bg", "gui")

      require("perfanno").setup({
        line_highlights = util.make_bg_highlights(bgcolor, "#CC3300", 10),
        vt_highlight = util.make_fg_highlight("#CC3300"),
      })
    end,
  },
  {
    "stevearc/profile.nvim",
    priority = 1001, -- highest priority plugin, so it loads before the others
    -- low enough overhead to not really require lazy loading
    config = function()
      -- NVIM_PROFILE=1 nv to start nvim
      -- f1 to toggle start/stop
      -- outputs are HUGE
      local should_profile = os.getenv("NVIM_PROFILE")
      if should_profile then
        require("profile").instrument_autocmds()
        if should_profile:lower():match("^start") then
          require("profile").start("*")
        else
          require("profile").instrument("*")
        end
      end

      local function toggle_profile()
        local prof = require("profile")
        if prof.is_recording() then
          prof.stop()
          vim.ui.input(
            { prompt = "Save profile to:", completion = "file", default = "profile.json" },
            function(filename)
              if filename then
                prof.export(filename)
                vim.notify(string.format("Wrote %s", filename))
              end
            end
          )
        else
          prof.start("*")
        end
      end
      vim.keymap.set("", "<f1>", toggle_profile)
    end,
  },

  -- Find and replace
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    config = function()
      require("grug-far").setup({
        windowCreationCommand = "tab split",
        maxSearchMatches = 2000,
      })
    end,
  },

  -- AI stuff
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = { "CodeCompanionChat", "CodeCompanion", "CodeCompanionActions" },
    config = function ()
      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "gemini",
          },
          inline = {
            adapter = "gemini",
          },
          agent = {
            adapter = "gemini",
          },
        },
        display = {
          chat = {
            render_headers = false,
          },
        },
        adapters = {
          ollama = function()
            return require("codecompanion.adapters").extend("ollama", {
              schema = {
                model = {
                  default = "qwen2.5-coder",
                },
              },
            })
          end,
          gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
              env = {
                api_key = "cmd:cat ~/data/.creds/gemini_api_key",
              },
            })
          end,
          anthropic = function()
            return require("codecompanion.adapters").extend("anthropic", {
              env = {
                api_key = "cmd:cat ~/data/.creds/claude_api_key",
              },
            })
          end,
        },
      })

    end,
  },

  -- Misc goodies
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
      { "<leader>pp",  function() Snacks.toggle.profiler() end, desc = "Toggle profiler" },  -- FIXME: doesn't do anything
    },
    init = function ()
      vim.api.nvim_create_user_command("Notifications",
        function() Snacks.notifier.show_history() end,
        {}
      )
    end,
    opts = {
      quickfile = { enabled = false },
      bigfile = { enabled = false },
      image = {},
      indent = {
        indent = {
          char = "▏",
        },
        scope = {
          enabled = false,
        },
      },
      input = {},
      scope = {
        treesitter = {
          enabled = false,  -- slow on giant files
          injections = false,
        },
      },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      profiler = {
        pick = {
          picker = "trouble",
        },
        filter_mod = {
          -- ["^vim%."] = true,  -- Shows more data, but breaks it currently
        },
      },
      styles = {
        input = {
          keys = {
            i_esc = { "<esc>", "cancel", mode = "i", expr = true },
            n_esc = { "<esc>", "cancel", mode = "n", expr = true },
          }
        },
      },
      dashboard = {
        enabled = true,
        width = 30,
        preset = {
          pick = "fzf-lua",
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = "<leader>ff" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = "<leader>fg" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = " ", key = "h", desc = "Highlights", action = ":FzfLua highlights" },
            { icon = " ", key = ".", desc = "File tree", action = ":Oil" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
          header = [[
^ ^
(O,O)
(   )
-"-"-]],
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          {
            padding = { 1, 2 },
            text = {
              {
                "Better than yesterday.",
                hl = "SnacksDashboardFooter",
                align = "center",
              },
            },
          },
        },
      },
    },
  },
}
