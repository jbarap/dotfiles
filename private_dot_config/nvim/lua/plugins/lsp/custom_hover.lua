-- Copy of vim.lsp.buf.hover as of v0.12.0-dev-1855+gc08139d790
-- + replace html entities
-- + replace escaped characters

local api = vim.api
local lsp = vim.lsp
local validate = vim.validate
local util = require('vim.lsp.util')

local M = {}

--- @param params? table
--- @return fun(client: vim.lsp.Client): lsp.TextDocumentPositionParams
local function client_positional_params(params)
  local win = api.nvim_get_current_win()
  return function(client)
    local ret = util.make_position_params(win, client.offset_encoding)
    if params then
      ret = vim.tbl_extend('force', ret, params)
    end
    return ret
  end
end

local hover_ns = api.nvim_create_namespace('nvim.lsp.hover_range')

--- @class vim.lsp.buf.hover.Opts : vim.lsp.util.open_floating_preview.Opts
--- @field silent? boolean

--- Displays hover information about the symbol under the cursor in a floating
--- window. The window will be dismissed on cursor move.
--- Calling the function twice will jump into the floating window
--- (thus by default, "KK" will open the hover window and focus it).
--- In the floating window, all commands and mappings are available as usual,
--- except that "q" dismisses the window.
--- You can scroll the contents the same as you would any other buffer.
---
--- Note: to disable hover highlights, add the following to your config:
---
--- ```lua
--- vim.api.nvim_create_autocmd('ColorScheme', {
---   callback = function()
---     vim.api.nvim_set_hl(0, 'LspReferenceTarget', {})
---   end,
--- })
--- ```
--- @param config? vim.lsp.buf.hover.Opts
function M.hover(config)
  validate('config', config, 'table', true)

  config = config or {}
  config.focus_id = 'textDocument/hover'

  lsp.buf_request_all(0, 'textDocument/hover', client_positional_params(), function(results, ctx)
    local bufnr = assert(ctx.bufnr)
    if api.nvim_get_current_buf() ~= bufnr then
      -- Ignore result since buffer changed. This happens for slow language servers.
      return
    end

    -- Filter errors from results
    local results1 = {} --- @type table<integer,lsp.Hover>
    local empty_response = false

    for client_id, resp in pairs(results) do
      local err, result = resp.err, resp.result
      if err then
        lsp.log.error(err.code, err.message)
      elseif result and result.contents then
        -- Make sure the response is not empty
        -- Five response shapes:
        -- - MarkupContent: { kind="markdown", value="doc" }
        -- - MarkedString-string: "doc"
        -- - MarkedString-pair: { language="c", value="doc" }
        -- - MarkedString[]-string: { "doc1", ... }
        -- - MarkedString[]-pair: { { language="c", value="doc1" }, ... }
        if
          (
            type(result.contents) == 'table'
            and #(
                vim.tbl_get(result.contents, 'value') -- MarkupContent or MarkedString-pair
                or vim.tbl_get(result.contents, 1, 'value') -- MarkedString[]-pair
                or result.contents[1] -- MarkedString[]-string
                or ''
              )
              > 0
          )
          or (
            type(result.contents) == 'string' and #result.contents > 0 -- MarkedString-string
          )
        then
          results1[client_id] = result
        else
          empty_response = true
        end
      end
    end

    if vim.tbl_isempty(results1) then
      if config.silent ~= true then
        if empty_response then
          vim.notify('Empty hover response', vim.log.levels.INFO)
        else
          vim.notify('No information available', vim.log.levels.INFO)
        end
      end
      return
    end

    local contents = {} --- @type string[]

    local nresults = #vim.tbl_keys(results1)

    local format = 'markdown'

    for client_id, result in pairs(results1) do
      local client = assert(lsp.get_client_by_id(client_id))
      if nresults > 1 then
        -- Show client name if there are multiple clients
        contents[#contents + 1] = string.format('# %s', client.name)
      end
      if type(result.contents) == 'table' and result.contents.kind == 'plaintext' then
        if #results1 == 1 then
          format = 'plaintext'
          contents = vim.split(result.contents.value or '', '\n', { trimempty = true })
        else
          -- Surround plaintext with ``` to get correct formatting
          contents[#contents + 1] = '```'
          vim.list_extend(
            contents,
            vim.split(result.contents.value or '', '\n', { trimempty = true })
          )
          contents[#contents + 1] = '```'
        end
      else
        vim.list_extend(contents, util.convert_input_to_markdown_lines(result.contents))
      end
      local range = result.range
      if range then
        local start = range.start
        local end_ = range['end']
        local start_idx = util._get_line_byte_from_position(bufnr, start, client.offset_encoding)
        local end_idx = util._get_line_byte_from_position(bufnr, end_, client.offset_encoding)

        vim.hl.range(
          bufnr,
          hover_ns,
          'LspReferenceTarget',
          { start.line, start_idx },
          { end_.line, end_idx },
          { priority = vim.hl.priorities.user }
        )
      end
      contents[#contents + 1] = '---'
    end

    -- Remove last linebreak ('---')
    contents[#contents] = nil

    -- Remove html entities from servers that send them
    local function clean_html_entities(str)
      local entities = {
        nbsp = " ",
        lt = "<",
        gt = ">",
        amp = "&",
        quot = '"',
        apos = "'",
        ensp = " ",
        emsp = " ",
      }
      for entity, char in pairs(entities) do
        str = str:gsub("&" .. entity .. ";", char)
      end
      return str
    end

    local function clean_escape_characters(str)
      local chars = "\\`*_{}[]()#+-.!/"
      for char in chars:gmatch(".") do
        str = str:gsub("\\%" .. char, char)
      end
      return str
    end

    for i, line in ipairs(contents) do
      contents[i] = clean_escape_characters(clean_html_entities(line))
    end

    local _, winid = lsp.util.open_floating_preview(contents, format, config)

    if winid then
      vim.wo[winid].spell = false
    end

    api.nvim_create_autocmd('WinClosed', {
      pattern = tostring(winid),
      once = true,
      callback = function()
        api.nvim_buf_clear_namespace(bufnr, hover_ns, 0, -1)
        return true
      end,
    })
  end)
end

return M
