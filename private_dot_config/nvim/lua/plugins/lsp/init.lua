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
    "jose-elias-alvarez/null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function ()
      local null_ls = require("null-ls")

      ---convenience wrapper of null\_ls builtin sources to register with a custom command
      ---@param type string formatting, diagnostics, code\_actions, hover, or completion.
      ---@param name string source name.
      ---@param opts table extra options to pass to the source.
      local function get_mason_nullls_source(type, name, opts)
        opts = opts or {}

        local source = null_ls.builtins[type][name]
        local custom_opts = {
          command = require("mason-core.path").bin_prefix(source["_opts"]["command"]),
        }

        opts = vim.tbl_extend("force", custom_opts, opts)
        return source.with(opts)
      end

      null_ls.setup({
        debounce = 250,
        debug = false,
        default_timeout = 20000,
        on_attach = require("plugins.lsp.on_attach"),
        save_after_format = false,
        sources = {
          ---- Linters
          -- get_mason_nullls_source("diagnostics", "mypy", {
          --   extra_args = { "--strict", "--ignore-missing-imports", "--check-untyped-defs" },
          -- }),
          -- get_mason_nullls_source("diagnostics", "pylint", {
          --   condition = function(cond_utils)
          --     return cond_utils.root_has_file({"pylintrc"})
          --   end,
          -- }),
          get_mason_nullls_source("diagnostics", "luacheck", {
            extra_args = { "--globals", "vim", "--allow-defined" },
          }),
          get_mason_nullls_source("diagnostics", "staticcheck", {}),

          -- ---- Fixers
          get_mason_nullls_source("formatting", "black", {
            args = { "--quiet", "--line-length", 105, "-" },
          }),
          get_mason_nullls_source("formatting", "stylua", {}),
          get_mason_nullls_source("formatting", "prettier", {}),
          null_ls.builtins.formatting.gofmt, -- gofmt executable comes with go
        },
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

      vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })

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
            return string.format("%s [%s](%s)", diagnostic.message, diagnostic.code, diagnostic.source)
          end,
          suffix = "",
        },
      })

      --             LSPs
      -- ──────────────────────────────
      local language_servers = require("plugins.lsp.servers")

      -- Language servers to register
      local server_names = {
        "ruff_lsp",
        -- "jedi_language_server",
        "pyright",
        "lua_ls",
        "dockerls",
        "gopls",
        "jsonls",
        "terraform_lsp",
        "yamlls",
        "clangd",
      }

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
      for _, name in ipairs(server_names) do
        local server_config = language_servers.configs[name]

        -- use after_on_attach if defined
        if server_config.after_on_attach then
          local original_on_attach = server_config.on_attach
          server_config.on_attach = function (client, bufnr)
            if original_on_attach then
              original_on_attach(client, bufnr)
            end
            server_config.after_on_attach(client, bufnr)
          end
        end

        local opts = vim.tbl_extend("keep", server_config, base_options or {})
        require("lspconfig")[name].setup(opts)
      end

    end
  },

}
