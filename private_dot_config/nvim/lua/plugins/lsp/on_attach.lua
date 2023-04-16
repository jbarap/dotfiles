return function(client, bufnr)
  local function buf_set_keymap(mode, lhs, rhs, opts)
    opts = opts or {}
    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { buffer = bufnr }, opts))
  end

  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  -- Get/Go
  -- See telescope for definition and references
  buf_set_keymap("n", "gD", vim.lsp.buf.declaration, { desc = "Goto declaration" })
  buf_set_keymap("n", "gi", vim.lsp.buf.implementation, { desc = "Goto implementation" })
  buf_set_keymap("n", "gt", vim.lsp.buf.type_definition, { desc = "Goto type definition" })

  -- Information
  buf_set_keymap("n", "K", vim.lsp.buf.hover, { desc = "Hover information" })
  buf_set_keymap("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })

  -- Workspace
  buf_set_keymap("n", "<Leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "Workspace add folder" })
  buf_set_keymap("n", "<Leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Workspace remove folder" })
  buf_set_keymap("n", "<Leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, { desc = "Workspace list folders" })

  -- Code actions
  buf_set_keymap("n", "<Leader>cr", vim.lsp.buf.rename, { desc = "Code rename (lsp)" })
  buf_set_keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })

  -- Diagnostics
  buf_set_keymap("n", "<Leader>sl",  function() vim.diagnostic.open_float({ scope = "line", }) end, { desc = "Show diagnostics (line)" })
  buf_set_keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
  buf_set_keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })

  -- Formatting
  buf_set_keymap({ "n" , "v" }, "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, { desc = "Code format" })

  -- Telescope LSP
  -- TODO: debug why sometimes goto def doesn't work or why sometimes it shows up double
  -- TODO: implement incoming/outgoing calls
  local function buf_bind_picker(lhs, picker_name, picker_opts, opts)
    picker_opts = picker_opts or {}
    opts = opts or {}
    vim.keymap.set("n", lhs, function()
      require("telescope.builtin")[picker_name](picker_opts)
    end, vim.tbl_extend("force", { buffer = bufnr }, opts))
  end

  buf_bind_picker("<Leader>fs", "lsp_document_symbols", {}, { desc = "Find symbols (lsp)" })
  buf_bind_picker("<Leader>fS", "lsp_workspace_symbols", {}, { desc = "Find symbols (lsp Workspace)" })

  buf_bind_picker("gr", "lsp_references", {}, { desc = "Goto references" })
  buf_bind_picker("gd", "lsp_definitions", {}, { desc = "Goto definition" })
end
