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
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    opts = {
      PATH = "skip",
      pip = {
        upgrade_pip = true,
      },
      ui = {
        check_outdated_packages_on_open = false,
        border = "rounded",
      },
      ensure_installed = {
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
      },
    },
    config = function(plugin, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      for _, tool in ipairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end,
  },

}
