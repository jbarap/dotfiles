local set_keymap = vim.keymap.set

local M = {}

--          togglers
-- ──────────────────────────────
function M.toggle_diff_view(mode)
  -- DiffviewFiles,
  local bfr = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  local buf_type = vim.api.nvim_buf_get_option(bfr, "filetype")
  local win_diff = vim.api.nvim_win_get_option(win, "diff")

  local is_diffview = false

  if string.match(buf_type, "Diffview") ~= nil or win_diff == true then
    is_diffview = true
  end

  if is_diffview then
    vim.cmd("silent DiffviewClose")
    require("utils").buffer_close_all_but_current()

    -- enable indents once we close the diffview
    bfr = vim.api.nvim_get_current_buf()
    buf_type = vim.api.nvim_buf_get_option(bfr, "filetype")
    if not vim.tbl_contains(vim.g.indent_blankline_filetype_exclude, buf_type) then
      require("indent_blankline.commands").enable()
    end

  else
    if mode == "diff" then
      vim.fn.feedkeys(":DiffviewOpen ")
    elseif mode == "file" then
      vim.fn.feedkeys(":DiffviewFileHistory ")
    end
  end
  vim.cmd("echon ''")
end

function M.toggle_tree_offset_tabline(mode)
  local windows = vim.api.nvim_tabpage_list_wins(0)

  for _, win_nr in ipairs(windows) do
    local buf_nr = vim.api.nvim_win_get_buf(win_nr)
    local is_tree = vim.api.nvim_buf_get_option(buf_nr, "filetype") == "NvimTree"

    if is_tree then
      require("bufferline.state").set_offset(0)
      require("nvim-tree").close()
      return
    end
  end

  require("bufferline.state").set_offset(vim.g.nvim_tree_width, "FileTree")

  if mode == "file" then
    require("nvim-tree").find_file(true)
  elseif mode == "tree" then
    require("nvim-tree").open()
  end
end

function M.buffer_performance_mode()
  local option = vim.fn.input({ prompt = "extreme? [y/n] (default no)? ", cancelreturn = "<canceled>" })
  vim.cmd("echon ' '")

  if option == "<canceled>" then
    return
  end

  if string.match(option, "y") then
    vim.fn.execute("TSBufDisable highlight")
  end
  require("indent_blankline.commands").disable()
  vim.fn.execute("TSBufDisable indent")
  vim.fn.execute("TSBufDisable incremental_selection")
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
