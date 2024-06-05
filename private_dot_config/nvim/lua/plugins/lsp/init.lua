local del_keymap = vim.keymap.del

return {
  -- Lsp config
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    init = function ()
      -- Delete unused builtin keymaps
      del_keymap("n", "grr")  -- references
      del_keymap("n", "grn")  -- rename
      del_keymap("n", "gra")  -- code actions

      -- Set up keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf

          local function buf_set_keymap(lhs, rhs, opts, mode)
            opts = type(opts) == 'string' and { desc = opts, buffer = bufnr }
              or vim.tbl_extend('error', opts --[[@as table]], { buffer = bufnr })
            mode = mode or 'n'
            vim.keymap.set(mode, lhs, rhs, opts)
          end

          local function buf_fzf_keymap(lhs, function_name, function_opts, keymap_opts)
            function_opts = function_opts or {}
            keymap_opts = keymap_opts or {}
            vim.keymap.set("n", lhs, function()
              require("fzf-lua")[function_name](function_opts)
            end, vim.tbl_extend("force", { buffer = bufnr }, keymap_opts))
          end

          -- Hover
          buf_set_keymap("K",
            function()
              -- peek folded lines if using ufo
              local ufo = require("utils").safe_load("ufo")
              if ufo ~= nil then
                local winid = require("ufo").peekFoldedLinesUnderCursor()
                if winid then
                  return
                end
              end
              -- LSP hover as fallback
              vim.lsp.buf.hover()
            end,
            "Hover information"
          )

          -- Signature help
          buf_set_keymap("<C-k>",
            vim.lsp.buf.signature_help,
            "Signature help",
            "i"
          )

          -- Rename
          buf_set_keymap("<Leader>cr",
            vim.lsp.buf.rename,
            "Code rename (lsp)"
          )

          -- Code actions
          buf_set_keymap("<leader>ca",
            vim.lsp.buf.code_action,
            "Code actions",
            { "n", "v" }
          )

          -- Inlay hints
          buf_set_keymap("<Leader>ch",
            function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
            end,
            "Code hints toggle"
          )

          -- Goto
          buf_fzf_keymap("gr", "lsp_references", {}, { desc = "Goto references" })
          buf_fzf_keymap("gd", "lsp_definitions", {}, { desc = "Goto definition" })
          buf_fzf_keymap("gD", "lsp_declarations", {}, { desc = "Goto declaration" })
          buf_fzf_keymap("gI", "lsp_implementations", {}, { desc = "Goto implementation" })
          buf_fzf_keymap("gt", "lsp_typedefs", {}, { desc = "Goto type definition" })

          -- Incoming/outgoing calls
          buf_fzf_keymap("<Leader>fi", "lsp_incoming_calls", {}, { desc = "Find incoming calls (lsp)" })
          buf_fzf_keymap("<Leader>fo", "lsp_outgoing_calls", {}, { desc = "Find outgoing calls (lsp)" })

          -- Symbols
          buf_fzf_keymap("<Leader>fs", "lsp_document_symbols", {}, { desc = "Find symbols (lsp)" })
          buf_fzf_keymap("<Leader>fS", "lsp_workspace_symbols", {}, { desc = "Find symbols (lsp Workspace)" })

          -- Set up nvim-navic integration
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client ~= nil and client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, bufnr)
          end
        end,
      })

      -- Handlers
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
      })
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
      })

    end,
    config = function()
      -- Set up language servers
      local language_servers = require("plugins.lsp.servers")

      local capabilities = vim.lsp.protocol.make_client_capabilities()

      -- for nvim_ufo compatibility
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
      }
      -- for autocompletion with nvim-cmp
      capabilities = vim.tbl_deep_extend("force", capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- initialization for all servers
      local base_options = {
        capabilities = capabilities,
        flags = {
          debounce_text_changes = 200,
        },
      }

      for _, name in ipairs(language_servers.lsps_in_use) do
        local server_config = language_servers.configs[name]
        local opts = vim.tbl_extend("keep", server_config, base_options or {})
        require("lspconfig")[name].setup(opts)
      end

    end
  },

  -- LuaLS setup for Neovim
  {
    "folke/lazydev.nvim",
    ft = "lua",
  },

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
  },

  -- Symbol tree
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

  -- External tools as diagnostics/code actions/completion
  {
    "nvimtools/none-ls.nvim",
    event = { "bufreadpre", "bufnewfile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function ()
      local null_ls = require("null-ls")

      local sources = {
        -- linters
        null_ls.builtins.diagnostics.selene,
        null_ls.builtins.diagnostics.staticcheck,
      }
      if not (
        vim.tbl_contains(require("plugins.lsp.servers").lsps_in_use, "pyright")
        or vim.tbl_contains(require("plugins.lsp.servers").lsps_in_use, "basedpyright")
      ) then
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
        save_after_format = false,
        sources = sources,
      })
    end,
  },

}
