return {
  -- Breadcrumbs
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    opts = {
      separator = " ➜ ",
      depth_limit = 0,
      depth_limit_indicator = "..",
      icons = {
        File = ' ',
        Module = ' ',
        Namespace = ' ',
        Package = ' ',
        Class = ' ',
        Method = ' ',
        Property = ' ',
        Field = ' ',
        Constructor = ' ',
        Enum = ' ',
        Interface = ' ',
        Function = ' ',
        Variable = ' ',
        Constant = ' ',
        String = ' ',
        Number = ' ',
        Boolean = ' ',
        Array = ' ',
        Object = ' ',
        Key = ' ',
        Null = ' ',
        EnumMember = ' ',
        Struct = ' ',
        Event = ' ',
        Operator = ' ',
        TypeParameter = ' '
      },
    },
    init = function()
      -- from LazyVim
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buffer = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, buffer)
          end
        end,
      })
    end
  },

  -- Code tree
  {
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle", "AerialNavToggle" },
    keys = {
      { "<Leader>co", "<cmd>AerialToggle<CR>", desc = "Code outline" },
      { "<Leader>cn", "<cmd>AerialNavToggle<CR>", desc = "Code navigate" },
    },
    opts = {
      backends = { "lsp", "treesitter", "markdown", "man" },
      highlight_on_jump = 350,
      manage_folds = false,
      link_tree_to_folds = true,
      link_folds_to_tree = true,
      show_guides = true,
      disable_max_lines = 10000,
      disable_max_size = 2000000, -- 2MB
      lazy_load = true,
      on_attach = function(bufnr)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>a', '<cmd>AerialToggle!<CR>', {})
      end,
      layout = {
        preserve_equality = true
      },
      keymaps = {
        ["<CR>"] = function()
          -- hack because for some reason when you just jump, the cursor position is wrong,
          -- but when you first scroll and then jump it works fine
          require("aerial").select({ jump = false })
          vim.schedule(require("aerial").select)
        end,
        ["<Tab>"] = "actions.tree_toggle",
      },
      nav = {
        preview = true,
        min_height = { 30, 0.5 },
        max_height = { 30, 0.5 },
        min_width = { 50, 0.2 },
        max_width = { 50, 0.2 },
        keymaps = {
          ["q"] = "actions.close",
          ["<Esc>"] = "actions.close",
        },
      },
    },
  },

  -- External commands as diagnostics/code actions/completion
  {
    "nvimtools/none-ls.nvim",
    event = { "bufreadpre", "bufnewfile" },
    commit = "fc0f601",  -- mypy broke due to: https://github.com/nvimtools/none-ls.nvim/commit/1fa06d350a36eb0901fe8edb50b9ba4a33e467e4
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function ()
      local null_ls = require("null-ls")

      local sources = {
        -- linters
        null_ls.builtins.diagnostics.luacheck.with({
          extra_args = { "--globals", "vim", "--allow-defined" },
        }),
        null_ls.builtins.diagnostics.staticcheck,
      }
      if not vim.tbl_contains(require("plugins.lsp.servers").lsps_in_use, "pyright") then
        table.insert(sources, null_ls.builtins.diagnostics.mypy.with({
          extra_args = {
            "--strict",
            "--ignore-missing-imports",
            "--check-untyped-defs",
            "--allow-untyped-calls",
          },
        }))
      end

      null_ls.setup({
        debounce = 200,
        debug = false,
        default_timeout = 20000,
        on_attach = require("plugins.lsp.on_attach"),
        save_after_format = false,
        sources = sources,
      })
    end,
  },

  -- Lsp config
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    init = function ()
      -- file watcher patch in: https://github.com/neovim/neovim/issues/23291
      -- while either the native watcher improves, or a third party gets vendored with neovim
      local watch_type = require("vim._watch").FileChangeType

      local function handler(res, callback)
        if not res.files or res.is_fresh_instance then
          return
        end

        for _, file in ipairs(res.files) do
          local path = res.root .. "/" .. file.name
          local change = watch_type.Changed
          if file.new then
            change = watch_type.Created
          end
          if not file.exists then
            change = watch_type.Deleted
          end
          callback(path, change)
        end
      end

      local function watchman(path, opts, callback)
        vim.system({ "watchman", "watch", path }):wait()

        local buf = {}
        local sub = vim.system({
          "watchman",
          "-j",
          "--server-encoding=json",
          "-p",
        }, {
          stdin = vim.json.encode({
            "subscribe",
            path,
            "nvim:" .. path,
            {
              expression = { "anyof", { "type", "f" }, { "type", "d" } },
              fields = { "name", "exists", "new" },
            },
          }),
          stdout = function(_, data)
            if not data then
              return
            end
            for line in vim.gsplit(data, "\n", { plain = true, trimempty = true }) do
              table.insert(buf, line)
              if line == "}" then
                local res = vim.json.decode(table.concat(buf))
                handler(res, callback)
                buf = {}
              end
            end
          end,
          text = true,
        })

        return function()
          sub:kill("sigint")
        end
      end

      if vim.fn.executable("watchman") == 1 then
        require("vim.lsp._watchfiles")._watchfunc = watchman
      end
    end,

    config = function()
      --             Handlers
      -- ──────────────────────────────
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
      })

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
      })

      --          Diagnostics
      -- ──────────────────────────────
      vim.fn.sign_define("DiagnosticSignError", { text = "☓", texthl = "DiagnosticSignError" })

      vim.fn.sign_define("DiagnosticSignWarn", { text = "!", texthl = "DiagnosticSignWarn" })

      vim.fn.sign_define("DiagnosticSignInfo", { text = "ℹ", texthl = "DiagnosticSignInfo" })

      vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })

      vim.diagnostic.config({
        underline = true,
        virtual_text = false,
        signs = true,
        update_in_insert = false,
        severity_sort = false,
        float = {
          -- header = true,
          border = "rounded",
          format = function(diagnostic)
            local extra_info = {}

            if diagnostic.code ~= nil then
              table.insert(extra_info, "C:" .. diagnostic.code)
            end

            if diagnostic.source ~= nil then
              table.insert(extra_info, "S:" .. diagnostic.source)
            end

            return string.format("%s (%s)", diagnostic.message, table.concat(extra_info, ", "))
          end,
          suffix = "",
        },
      })

      --             LSPs
      -- ──────────────────────────────
      local language_servers = require("plugins.lsp.servers")

      local capabilities = vim.lsp.protocol.make_client_capabilities()

      -- for nvim_ufo compatibility
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
      }
      -- for autocompletion with nvim-cmp
      capabilities = vim.tbl_deep_extend("force", capabilities, require('cmp_nvim_lsp').default_capabilities())

      local base_options = {
        on_attach = require("plugins.lsp.on_attach"),
        capabilities = capabilities,
        flags = {
          debounce_text_changes = 200,
        },
      }

      -- initialization for all servers
      for _, name in ipairs(language_servers.lsps_in_use) do
        local server_config = language_servers.configs[name]

        local opts = vim.tbl_extend("keep", server_config, base_options or {})
        require("lspconfig")[name].setup(opts)
      end

    end
  },

}
