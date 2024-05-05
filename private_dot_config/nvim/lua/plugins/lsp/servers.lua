local utils = require("utils")

local M = {}

--          preparation
-- ──────────────────────────────
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

-- TODO: implement this as a util instead of relying on lspconfig
function M.find_root(patterns, fname)
  local lsputils = require("lspconfig.util")
  return lsputils.root_pattern(unpack(patterns))(fname) or lsputils.find_git_ancestor(fname) or vim.loop.cwd()
end

local common_patterns = {
  ".project",
  ".git",
  "Makefile",
}

local python_patterns = {
  "pyproject.toml",
  "setup.py",
  "setup.cfg",
  "requirements.txt",
  "Pipfile",
  "poetry.lock",
  "pyrightconfig.json",
}

M.lsps_in_use = {
  "ruff_lsp",
  -- "jedi_language_server",
  -- "pylyzer",
  -- "pyright",
  "basedpyright",
  "lua_ls",
  "dockerls",
  "gopls",
  "jsonls",
  "terraformls",
  "yamlls",
  "clangd",
}

--        lsp settings
-- ──────────────────────────────
-- See: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
-- And: https://github.com/neovim/nvim-lspconfig/blob/master/ADVANCED_README.md
M._lazy_configs = {
  jedi_language_server = function ()
    return {
      before_init = function(initialize_params, config)
        -- if no virtualenv is activated, jedi uses python's packages from the virtualenv in
        -- which it was installed. This makes it use the system's packages instead
        local env = vim.env.PYENV_VERSION
        if not env then
          config.cmd[1] = "VIRTUAL_ENV=python3 PYENV_VIRTUAL_ENV=python3 " .. config.cmd[1]
        end

        initialize_params["initializationOptions"] = {
          executable = {
            command = config.cmd[1],
          },
          jediSettings = {
            autoImportModules = { "torch", "numpy", "pandas", "tensorflow", "cv2" },
          },
        }
      end,
      root_dir = function(fname)
        return M.find_root(utils.tbl_concat(common_patterns, python_patterns), fname)
      end
    }
  end,

  pylyzer = function()
    return {
      root_dir = function(fname)
        return M.find_root(utils.tbl_concat(common_patterns, python_patterns), fname)
      end
    }
  end,

  pyright = function()
    return {
      -- automatically identify virtualenvs set with pyenv
      on_new_config = function (config, _)
        local python_path
        local virtual_env = vim.env.VIRTUAL_ENV or vim.env.PYENV_VIRTUAL_ENV
        if virtual_env then
          python_path = require("lspconfig.util").path.join(virtual_env, "bin", "python")
        else
          python_path = "python"
        end
        config.settings.python.pythonPath = python_path
      end,
      root_dir = function(fname)
        return M.find_root(utils.tbl_concat(common_patterns, python_patterns), fname)
      end
    }
  end,

  basedpyright = function()

    -- highlight self and cls as a builtin variables
    local function ts_highlight_self(args)
      local token = args.data.token
      if token.type ~= "parameter" then return end

      -- TODO: check performance impact of getting text so frequently
      local text = vim.api.nvim_buf_get_text(
        args.buf, token.line, token.start_col, token.line, token.end_col, {})[1]

      if text ~= "self" and text ~= "cls" then return end

      vim.lsp.semantic_tokens.highlight_token(
        token, args.buf, args.data.client_id, "@variable.builtin"
      )
    end

    vim.api.nvim_create_autocmd("LspTokenUpdate", {
      callback = ts_highlight_self,
    })

    return {
      settings = {
        basedpyright = {
          analysis = {
            typeCheckingMode = "standard",
          },
        },
      },
      -- automatically identify virtualenvs set with pyenv
      on_new_config = function (config, _)
        local python_path
        local virtual_env = vim.env.VIRTUAL_ENV or vim.env.PYENV_VIRTUAL_ENV
        if virtual_env then
          python_path = require("lspconfig.util").path.join(virtual_env, "bin", "python")
        else
          python_path = "python"
        end
        config.settings.python.pythonPath = python_path

      end,
      root_dir = function(fname)
        return M.find_root(utils.tbl_concat(common_patterns, python_patterns), fname)
      end
    }
  end,

  pylsp = function()
    return {
      settings = {
        pylsp = {
          plugins = {
            mccabe = {
              enabled = false,
            },
            pycodestyle = {
              enabled = false,
            },
            pyflakes = {
              enabled = false,
            },
            rope_completion = {
              enabled = false,
            },
            yapf = {
              enabled = false,
            },
          }
        }
      },
      root_dir = function(fname)
        return M.find_root(utils.tbl_concat(common_patterns, python_patterns), fname)
      end
    }
  end,

  ruff_lsp = function()
    return {
      settings = {
        args = {
          -- to enable later: ANN,
          "--select",
          "F,E,W,C,I,D,N,S,FBT,B,C4,EM,ICN,RET,ARG,ERA,PLW",

          -- configuration for pydocstyle - google convention
          "--extend-ignore",
          "D203,D204,D213,D215,D400,D404,D406,D407,D408,D409,D413",
        },
      },
      -- automatically identify virtualenvs set with pyenv
      on_new_config = function (config, _)
        local python_path
        local virtual_env = vim.env.VIRTUAL_ENV or vim.env.PYENV_VIRTUAL_ENV

        if virtual_env then
          python_path = require("lspconfig.util").path.join(virtual_env, "bin", "python")
        else
          python_path = "python"
        end

        config.settings.interpreter = python_path
      end,
      root_dir = function(fname)
        return M.find_root(utils.tbl_concat(common_patterns, python_patterns), fname)
      end,
      on_init = function(client)
        client.server_capabilities.hoverProvider = false
      end,
    }
  end,

  lua_ls = function()
    return {
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
            path = runtime_path,
          },
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
            preloadFileSize = 350, -- in kb
          },
          telemetry = {
            enable = false,
          },
          hint = {
            enable = true,
          },
        },
      },
    }
  end,

  dockerls = function()
    return {
      -- disable semantic highlighting because it looks worse than regular
      on_init = function(client)
        client.server_capabilities.semanticTokensProvider = nil
      end,
    }
  end,

  yamlls = function()
    return {
      settings = {
        yaml = {
          -- from: https://github.com/Allaman/nvim/blob/main/lua/config/lsp/languages/yaml.lua
          schemaStore = {
            enable = true,
            url = "https://www.schemastore.org/api/json/catalog.json",
          },
          schemas = {
            kubernetes = "*.yaml",
            ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
            ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
            ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
            ["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
            ["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
            ["http://json.schemastore.org/ansible-playbook"] = "*play*.{yml,yaml}",
            ["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
            ["https://json.schemastore.org/dependabot-v2"] = ".github/dependabot.{yml,yaml}",
            ["https://json.schemastore.org/gitlab-ci"] = "*gitlab-ci*.{yml,yaml}",
            ["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json"] = "*api*.{yml,yaml}",
            ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "*docker-compose*.{yml,yaml}",
            ["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = "*flow*.{yml,yaml}",
            ["https://squidfunk.github.io/mkdocs-material/schema.json"] = "mkdocs.yml",
          },
          format = { enabled = false },
          validate = false, -- conflicts between Kubernetes resources and kustomization.yaml
          completion = true,
          hover = true,
        }
      }
    }
  end,

}

M.configs = setmetatable({}, {
  __index = function (table, key)
    if M._lazy_configs[key] ~= nil then
      return M._lazy_configs[key]()
    else
      return {}
    end
  end
})

return M
