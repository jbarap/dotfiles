return {
  -- Utility functions
  { "nvim-lua/plenary.nvim", lazy = true },

  -- Icons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  -- Rooter
  {
    "echasnovski/mini.misc",
    config = function ()
      local files = {
        "_darcs",
        ".project",
        ".chezmoiignore",
        ".bzr",
        ".git",
        ".hg",
        ".svn",
        "go.mod",
        "package.json",
        "Pipfile",
        "poetry.lock",
        "pyrightconfig.json",
        "pyproject.toml",
        "setup.cfg",
        "setup.py",
      }
      require("mini.misc").setup_auto_root(files)
    end
  },

  -- Auto indent settings
  {
    "NMAC427/guess-indent.nvim",
    config = true,
  },

  -- Dependency manager
  {
    "williamboman/mason.nvim",
    init = function ()
      local ensure_installed = {
        -- lsp
        "jedi-language-server",
        "pyright",
        "basedpyright",
        "python-lsp-server",
        "ruff-lsp",
        "gopls",
        "lua-language-server",
        "dockerfile-language-server",
        "json-lsp",
        "yaml-language-server",
        "terraform-ls",
        "clangd",

        -- linters/formatters
        "mypy",
        "pylint",
        "ruff",
        "selene",
        "black",
        "isort",
        "stylua",
        "prettier",
        "staticcheck",
        "biome",
        "yamlfmt",

        -- DAP
        "debugpy",
      }

      vim.api.nvim_create_user_command("MasonInstallMissing", function()
        local mr = require("mason-registry")

        local missing_packages = {}

        for _, tool in ipairs(ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            table.insert(missing_packages, tool)
          end
        end

        if #missing_packages == 0 then
          vim.notify("No missing Mason packages to install", vim.log.levels.INFO)
          return
        end

        vim.cmd("MasonInstall " .. table.concat(missing_packages, " "))
      end, {})
    end,
    opts = {
      PATH = "prepend",
      pip = {
        upgrade_pip = true,
      },
      ui = {
        check_outdated_packages_on_open = false,
        border = "rounded",
      },
    },
  },

}
