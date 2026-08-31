return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    branch = "main",
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")

      local parsers = {
        "bash",
        -- "comment",
        "css",
        "diff",
        "dockerfile",
        "git_config",
        "git_rebase",
        "gitcommit",
        "gitignore",
        "go",
        "hcl",
        "helm",
        "html",
        "http",
        "java",
        "javascript",
        "jsdoc",
        "json",
        "json5",
        "just",
        "jinja",
        "jinja_inline",
        "latex",
        "lua",
        "luadoc",
        "make",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "rst",
        "rust",
        "scss",
        "ssh_config",
        "sql",
        "terraform",
        "typst",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "vue",
        "xml",
        "yaml",
      }
      ts.install(parsers)

      local group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true })

      local ignore_filetypes = {
        "checkhealth",
        "lazy",
        "mason",
        "snacks_dashboard",
        "snacks_notif",
        "snacks_win",
      }

      -- For indenting see: https://github.com/nvim-treesitter/nvim-treesitter/issues/7840
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        desc = "Enable treesitter highlighting",
        callback = function(event)
          local buf = event.buf
          local filetype = event.match

          if vim.tbl_contains(ignore_filetypes, filetype) then
            return
          end

          local lang = vim.treesitter.language.get_lang(filetype) or filetype

          -- Don't run on languages without parsers
          if not vim.treesitter.language.add(lang) then
              return
          end

          -- Start highlighting immediately (works if parser exists)
          pcall(vim.treesitter.start, buf, lang)

          -- Indent (slow)
          -- NOTE: disable vim.opt.smartindent if problematic
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      -- Incremental selection
      vim.keymap.set({ "n", "x", "o" }, "<A-o>", function()
        if vim.treesitter.get_parser(nil, nil, { error = false }) then
          require "vim.treesitter._select".select_parent(vim.v.count1)
        else
          vim.lsp.buf.selection_range(vim.v.count1)
        end
      end, { desc = "Select parent treesitter node or outer incremental lsp selections" })

      vim.keymap.set({ "n", "x", "o" }, "<A-i>", function()
        if vim.treesitter.get_parser(nil, nil, { error = false }) then
          require "vim.treesitter._select".select_child(vim.v.count1)
        else
          vim.lsp.buf.selection_range(-vim.v.count1)
        end
      end, { desc = "Select child treesitter node or inner incremental lsp selections" })

    end
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    init = function()
      -- Disable entire built-in ftplugin mappings to avoid conflicts.
      -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
      vim.g.no_plugin_maps = true
    end,
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
          selection_modes = {
            ["@parameter.outer"] = "v", -- charwise
            ["@function.outer"] = "V", -- linewise
            ["@class.outer"] = "<c-v>", -- blockwise
          },
          include_surrounding_whitespace = false,
        },
        move = {
          set_jumps = false,
        },
      })

      -- Select
      vim.keymap.set({ "x", "o" }, "af", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "if", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ac", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@class.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ic", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@class.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "aa", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@parameter.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ia", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@parameter.inner", "textobjects")
      end)
    end,
  },

}
