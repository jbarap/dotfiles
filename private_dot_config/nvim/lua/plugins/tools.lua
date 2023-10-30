return {
  -- File explorer and modifier
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Oil",
    keys = {
      { "-", function() require("oil").open() end, desc = "Open buffer's directory" },
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
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
      },
      use_default_keymaps = false,
    },
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

  -- check "benlubas/molten-nvim"
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
        function()
          local dir_is_managed = vim.system({
            "sh", "-c", 'test -n "$(chezmoi managed $(chezmoi target-path .))"'
          }):wait().code == 0

          -- Fallback on applying on a file-basis
          local target = "."
          if not dir_is_managed then
            target = vim.fn.expand("%")
          end

          target = string.gsub(
            vim.system({"chezmoi", "target-path", target }, {text = true}):wait().stdout,
            "\n",
            ""
          )
          vim.notify(string.format("Applying changes to %s", target), vim.log.levels.INFO, { title = "Chezmoi" })

          require('FTerm').scratch({ cmd = string.format("chezmoi apply -v %s", target) })
        end, {}
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
      { "<Leader>fb", function() require("fzf-lua").buffers({ sort_lastused=true }) end, desc = "Find buffers" },
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
            layout = "vertical",
            vertical = "down:60%",
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
