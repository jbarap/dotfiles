local M = {}

--            tables
-- ──────────────────────────────
function M.tbl_concat(tbl1, tbl2)
  local tbl3 = {unpack(tbl1)}
  for i = 1, #tbl2 do
    tbl3[#tbl1 + i] = tbl2[i]
  end
  return tbl3
end

--          autogroups
-- ──────────────────────────────
function M.create_augroup(name, autocmds)
  vim.cmd("augroup " .. name)
  vim.cmd("autocmd!")

  for _, autocmd in ipairs(autocmds) do
    vim.cmd("autocmd " .. table.concat(autocmd, " "))
  end

  vim.cmd("augroup END")
end

--           modules
-- ──────────────────────────────
function M.safe_load(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify(
      string.format("--- Module '%s' failed to load due to error: %s", module, result),
      vim.log.levels.ERROR
    )
    return nil
  else
    return result
  end
end

--          togglers
-- ──────────────────────────────

-- Toggle the quickfix list
function M.toggle_quickfix()
  local windows = vim.fn.getwininfo()
  local quickfix_open = false

  for _, value in pairs(windows) do
    if value["quickfix"] == 1 then
      quickfix_open = true
    end
  end

  if quickfix_open then
    vim.cmd("cclose")
  else
    vim.cmd("copen")
  end
end

--           sudo
-- ──────────────────────────────

-- Use sudo to execute commands and write files
-- from: https://github.com/ibhagwan/nvim-lua/blob/main/lua/utils.lua#L280
M.sudo_exec = function(cmd, print_output)
  local password = vim.fn.inputsecret("Password: ")
  if not password or #password == 0 then
    vim.notify("Invalid password, sudo aborted")
    return false
  end
  local out = vim.fn.system(string.format("sudo -p '' -S %s", cmd), password)
  if vim.v.shell_error ~= 0 then
    print("\r\n")
    vim.notify(out)
    return false
  end
  if print_output then
    print("\r\n", out)
  end
  return true
end

M.sudo_write = function(tmpfile, filepath)
  if not tmpfile then
    tmpfile = vim.fn.tempname()
  end
  if not filepath then
    filepath = vim.fn.expand("%")
  end
  if not filepath or #filepath == 0 then
    vim.notify("E32: No file name")
    return
  end
  -- `bs=1048576` is equivalent to `bs=1M` for GNU dd or `bs=1m` for BSD dd
  -- Both `bs=1M` and `bs=1m` are non-POSIX
  -- stylua: ignore
  local cmd = string.format(
    "dd if=%s of=%s bs=1048576",
    vim.fn.shellescape(tmpfile),
    vim.fn.shellescape(filepath))
  -- no need to check error as this fails the entire function
  vim.api.nvim_exec(string.format("write! %s", tmpfile), true)
  if M.sudo_exec(cmd) then
    vim.notify(string.format('\r\n"%s" written', filepath))
    vim.cmd("e!")
  end
  vim.fn.delete(tmpfile)
end

--           search
-- ──────────────────────────────

M.search_word_under_cursor = function()
  vim.cmd([[let @/='\<]] .. vim.fn.expand("<cword>") .. [[\>']])
  vim.o["hlsearch"] = true
end

M.search_selected_word = function()
  local bufnr = vim.api.nvim_win_get_buf(0)
  local start = vim.fn.getpos('v') -- [bufnum, lnum, col, off]
  local _end = vim.fn.getpos('.') -- [bufnum, lnum, col, off]
  local text = vim.api.nvim_buf_get_text(bufnr, start[2] - 1, start[3] - 1, _end[2] - 1, _end[3], {})[1]
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  vim.cmd([[let @/=']] .. text .. [[']])
  vim.o["hlsearch"] = true
end

--            files
-- ──────────────────────────────

-- Get a python executable within a virtualenv
M.get_python_executable = function(bin_name)
  local result = bin_name
  if os.getenv("VIRTUAL_ENV") then
    local venv_bin_name = os.getenv("VIRTUAL_ENV") .. "/bin/" .. bin_name
    if vim.fn.executable(venv_bin_name) == 1 then
      result = venv_bin_name
    end
  end
  return result
end


--          buffer delete
-- ──────────────────────────────

-- From: https://github.com/nyngwang/NeoNoName.lua/blob/main/lua/neo-no-name.lua
M.buffer_delete = function()
  if (vim.bo.filetype == 'dashboard') then
    vim.cmd('bd')
    return
  end
  local buffers = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted')
  end, vim.api.nvim_list_bufs())
  if (vim.api.nvim_tabpage_get_number(0) == 1) then
    if (#buffers > 1) then
      vim.cmd('bn')
      vim.cmd('bd #')
    else
      vim.cmd('bd')
    end
    return
  end
  local win_from_non_hidden_buf = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    win_from_non_hidden_buf[vim.api.nvim_win_get_buf(win)] = win
  end
  -- find a No-Name buffer from the existing ones in `:ls`.
  local first_no_name_buf = nil
  for _, buf in ipairs(buffers) do
    if (vim.api.nvim_buf_get_name(buf) == '') then
      first_no_name_buf = buf
      break
    end
  end
  -- if this is the first No Name buffer, then create one and done.
  if (first_no_name_buf == nil) then
    vim.cmd('enew')
    return
  end
  -- make the current buffer No Name without `:enew`, so both `buffers`, and `win_from_non_hidden_buf` are valid.
  vim.api.nvim_set_current_buf(first_no_name_buf)
  -- set all the other No Name buffers to be the same one.
  for _, buf in ipairs(buffers) do
    if (vim.api.nvim_buf_get_name(buf) == '' and win_from_non_hidden_buf[buf] ~= nil) then
      vim.api.nvim_win_set_buf(win_from_non_hidden_buf[buf], first_no_name_buf)
    end
  end
  -- delete all the other No-Name buffers.
  for _, buf in ipairs(buffers) do
    if (vim.api.nvim_buf_get_name(buf) == '' and buf ~= first_no_name_buf) then
      vim.cmd('bd ' .. buf)
    end
  end
end

-- TODO: scope buffers to only the ones in this tab?
M.buffer_close_all_but_current = function()
  local current_buf = vim.api.nvim_get_current_buf()
  local all_bufs = vim.api.nvim_list_bufs()
  for _, buf in ipairs(all_bufs) do
    if
      buf ~= current_buf
      and vim.api.nvim_buf_is_loaded(buf)
      and vim.api.nvim_buf_get_option(buf, "buftype") ~= "terminal"
    then
      vim.cmd(string.format("bdelete %s", buf))
    end
  end
end

--       highlight interface
-- ──────────────────────────────

local Highlight = {
  id = 0,
  name = "",
  highlights = {
    cterm = "NONE",
    ctermfg = "NONE",
    ctermbg = "NONE",
    gui = "NONE",
    guifg = "NONE",
    guibg = "NONE",
  },
  attributes = {
    "bold",
    "italic",
    "reverse", -- same as inverse
    "inverse",
    "standout",
    "underline",
    "undercurl",
    "strikethrough",
  },
}

function Highlight:_init(create_if_missing)
  if create_if_missing then
    self.id = vim.api.nvim_get_hl_id_by_name(self.name)
  else
    self.id = vim.fn.hlID(self.name)
  end

  if self.id == 0 then
    vim.notify(string.format("Highlight '%s' not defined", self.name), vim.log.levels.WARN)
  end

  self.id = vim.fn.synIDtrans(self.id)

  self.highlights = {}
  for hl_name, _ in pairs(M.Highlight.highlights) do
    local hl = self:_get_highlight(hl_name)
    if hl == "" then
      hl = "NONE"
    end
    self.highlights[hl_name] = hl
  end

  return self
end

function Highlight:_get_highlight(hl_name)
  hl_name = string.lower(hl_name)

  local highlight_value = ""
  local hl_type = string.match(hl_name, "gui") or string.match(hl_name, "cterm")

  if not hl_type then
    vim.notify(string.format("Highlight option %s not supported", hl_type), vim.log.levels.WARN)
  end

  hl_name = string.gsub(hl_name, hl_type, "")
  if hl_name ~= "" then
    -- fg/bg/sp highlights
    highlight_value = vim.fn.synIDattr(self.id, hl_name, hl_type)
  else
    -- attributes
    local attrs = {}
    for _, attr_name in ipairs(self.attributes) do
      if vim.fn.synIDattr(self.id, attr_name, hl_type) == "1" then
        table.insert(attrs, attr_name)
      end
    end

    highlight_value = table.concat(attrs, ",") or highlight_value
  end

  return highlight_value
end

function Highlight:_update()
  if self.id == 0 then
    return self
  end

  local formatted_hl = string.format("hi %s", self.name)
  for hl_name, hl_value in pairs(self.highlights) do
    formatted_hl = string.format("%s %s=%s", formatted_hl, hl_name, hl_value)
  end
  vim.cmd(formatted_hl)
end

function Highlight:new(name, create_if_missing)
  local obj = { name = name }
  setmetatable(obj, self)
  self.__index = self
  obj:_init(create_if_missing)
  return obj
end

function Highlight:set(hl_name, value)
  self.highlights[hl_name] = value
  self:_update()
  return self
end

function Highlight:clear()
  self.highlights = M.Highlight.highlights
  self:_update()
end

setmetatable(Highlight, {
  __call = function(self, ...)
    return self:new(...)
  end,
})

M.Highlight = Highlight

return M
