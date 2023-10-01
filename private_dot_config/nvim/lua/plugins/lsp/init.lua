return {
  -- Breadcrumbs
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    opts = {
      separator = " > ",
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
    cmd = "AerialToggle",
    keys = {
      { "<Leader>co", "<cmd>AerialToggle<CR>", desc = "Code outline" },
    },
    opts = {
      backends = { "lsp", "treesitter", "markdown" },
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
      },
    },
  },

  -- External commands as diagnostics/code actions/completion
  {
    "nvimtools/none-ls.nvim",
    event = { "bufreadpre", "bufnewfile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function ()
      local null_ls = require("null-ls")

      local sources = {
        -- linters
        null_ls.builtins.diagnostics.luacheck.with({
          extra_args = { "--globals", "vim", "--allow-defined" },
        }),
        null_ls.builtins.diagnostics.staticcheck,

        -- formatters
        null_ls.builtins.formatting.black.with({
          args = { "--quiet", "--line-length", 105, "-" },
        }),
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.formatting.gofmt, -- gofmt executable comes with go
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
        root_dir = require("project_nvim.project").find_pattern_root,
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
