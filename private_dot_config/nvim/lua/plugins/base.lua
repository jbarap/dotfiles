return {
  { "nvim-lua/plenary.nvim", lazy = true },

  { "nvim-tree/nvim-web-devicons", lazy = true },

  {
    "ahmedkhalf/project.nvim",
    name = "project_nvim",
    opts = {
      manual_mode = false,
      detection_methods = { "pattern" },
      scope_chdir = 'tab',
      patterns = {
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
      },
      ignore_lsp = { "null-ls" },
      silent_chdir = true,
    },
  },

  {
    "NMAC427/guess-indent.nvim",
    config = true,
  },

  {
    "dstein64/vim-startuptime",
    cmd = { "StartupTime" }
  },

  {
    "nvim-lua/popup.nvim",
    lazy = true,
  },

  {
    "williamboman/mason.nvim",
    init = function ()
      local ensure_installed = {
        -- lsp
        "jedi-language-server",
        "pyright",
        "python-lsp-server",
        "ruff-lsp",
        "gopls",
        "lua-language-server",
        "dockerfile-language-server",
        "json-lsp",
        "yaml-language-server",
        "terraform-ls",
        "clangd",

        -- null-ls
        "mypy",
        "pylint",
        "luacheck",
        "black",
        "stylua",
        "prettier",
        "staticcheck",
      }

      vim.api.nvim_create_user_command("MasonInstallMissing", function()
        local mr = require("mason-registry")

        local missing_packages = {}

        for _, tool in ipairs(ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            missing_packages:append(tool)
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
