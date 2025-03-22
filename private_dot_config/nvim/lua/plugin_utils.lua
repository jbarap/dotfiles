local utils = require("utils")

local set_keymap = vim.keymap.set

local M = {}

--          togglers
-- ──────────────────────────────
function M.toggle_diff_view(mode)
  -- DiffviewFiles,
  local bfr = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  local buf_type = vim.api.nvim_get_option_value("filetype", { buf = bfr })
  local win_diff = vim.api.nvim_get_option_value("diff", { win = win })

  local is_diffview = false

  if string.match(buf_type, "Diffview") ~= nil or win_diff == true then
    is_diffview = true
  end

  if is_diffview then
    vim.cmd("silent DiffviewClose")
  else
    if buf_type == "snacks_dashboard" then
      -- Snacks dashboard will hide many UI elements, and only restores them once its
      -- buffer is deleted, so we delete it manually to restore them
      vim.cmd("bd")
    end

    if mode == "diff" then
      vim.fn.feedkeys(":DiffviewOpen ")
    elseif mode == "file" then
      vim.fn.feedkeys(":DiffviewFileHistory ")
    elseif mode == "pr" then

      vim.ui.select({"all", "per-commit"}, {
          prompt = "PR review mode:"
        },
        function(choice)
          if not choice then
            return
          end

          local is_in_repo = vim.system(
            {"git", "rev-parse", "--is-inside-work-tree"},
            {}
          ):wait().code == 0
          if not is_in_repo then
            vim.notify("Not in git repo", vim.log.levels.WARN)
            return
          end

          local base_ref = vim.fn.input({
            prompt = "Base ref (nothing for origin/HEAD): ",
            cancelreturn = "<cancel>",
            -- completion function defined in utils
            completion = "custom,v:lua._usr_git_refs_completion"
          })

          if base_ref == "<cancel>" then
            return
          elseif base_ref == "" then
            base_ref = "origin/HEAD"
          end

          vim.notify(
            string.format("Viewing changes since merge-base for %s", base_ref),
            vim.log.levels.INFO,
            { title = "DiffView" }
          )

          local cmd
          if choice == "all" then
            cmd = string.format("DiffviewOpen %s...HEAD --imply-local", base_ref)
          else
            cmd = string.format("DiffviewFileHistory --range=%s...HEAD --right-only --no-merges", base_ref)
          end
          vim.cmd(cmd)

          -- change gitsigns base for all buffers
          local ok, gitsigns = pcall(require, "gitsigns")
          if ok then
            local merge_base = utils.get_merge_base(base_ref)
            gitsigns.change_base(merge_base, true)
          else
            vim.notify("Gitsigns missing", vim.log.levels.WARN)
          end

        end
      )

    end
  end
  vim.cmd("echon ''")
end

--          prompts
-- ──────────────────────────────
-- Git compare file prompt
function M.prompt_git_file()
  local option = vim.fn.input({ prompt = "Open file in which commit: [~(number)/hash]? ", cancelreturn = "<canceled>" })
  -- read from another branch: :Gedit branchname:path/to/file

  if option == "<canceled>" then
    return nil
  elseif option == "" then
    vim.cmd("silent Gedit HEAD~1:%")
  elseif string.find(option, "~") ~= nil then
    vim.cmd("silent Gedit HEAD" .. option .. ":%")
  else
    vim.cmd("silent Gedit " .. option .. ":%")
  end

  vim.cmd("echon ''")
end

-- Grep in a specific dir prompt
function M.rg_dir()
  require("telescope.builtin").find_files({
    prompt_title = "Dir to grep",
    find_command = { "fdfind", "--type", "d", "--hidden", "--exclude", ".git" },

    attach_mappings = function(prompt_bufnr, map)
      local function select_dir()
        -- TODO: when https://github.com/nvim-telescope/telescope.nvim/issues/416 is merged,
        -- support grepping in multiple dirs
        local content = require("telescope.actions.state").get_selected_entry()
        local grep_dir = content.cwd .. "/" .. content.value
        require("telescope.actions").close(prompt_bufnr)

        vim.schedule(function()
          require("telescope.builtin").live_grep({
            prompt_title = "Grep in: " .. content.value,
            initial_mode = "insert",
            search_dirs = { grep_dir },
          })
        end)
      end

      map("i", "<CR>", function(_)
        select_dir()
      end)

      return true
    end,
  })
end

function M.rg_exclude_dir()
  require("telescope.builtin").find_files({
    prompt_title = "Dir to exclude from grep",
    find_command = { "fdfind", "--type", "d", "--hidden", "--exclude", ".git" },

    attach_mappings = function(prompt_bufnr, map)
      local function select_dir()
        -- TODO: when https://github.com/nvim-telescope/telescope.nvim/issues/416 is merged,
        -- support grepping in multiple dirs
        local content = require("telescope.actions.state").get_selected_entry()
        require("telescope.actions").close(prompt_bufnr)

        vim.schedule(function()
          require("telescope.builtin").live_grep({
            prompt_title = "Grep in exerything except: " .. content.value,
            initial_mode = "insert",
            additional_args = function() return { "-g", string.format("!%s/", content.value) } end,
          })
        end)
      end

      map("i", "<CR>", function(_)
        select_dir()
      end)

      return true
    end,
  })
end

-- todo comments searcher
function M.todo_comments()
  local all_comments = {
    "FIX",
    "FIXME",
    "BUG",
    "FIXIT",
    "ISSUE",
    "TODO",
    "HACK",
    "WARN",
    "PERF",
    "NOTE",
  }
  require("telescope.builtin").live_grep({
    default_text = table.concat(all_comments, ":|") .. ":",
    _completion_callbacks = {
      send_to_qf = function ()
        require("telescope.actions").smart_send_to_qflist()
      end
    },
  })
end
set_keymap("n", "<Leader>ct", M.todo_comments)


--          code runner
-- ──────────────────────────────
-- Code Runner - execute commands in a floating terminal
function M.run_code()
  local runners = {
    python = "python3",
    lua = "lua",
    go = "go run",
    -- TODO: set runner as 'sh', but read first line to look for shebangs
    sh = "bash",
  }

  local file_name = vim.api.nvim_buf_get_name(0)
  local file_type = vim.bo.filetype
  local exec = runners[file_type]

  if exec == nil then
    vim.notify("Filetype '" .. file_type .. "' not yet supported.")
  else
    require('FTerm').scratch({ cmd = { exec, file_name } })
  end

end

return M
