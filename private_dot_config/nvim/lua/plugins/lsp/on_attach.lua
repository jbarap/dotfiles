return function(client, bufnr)
  local function buf_set_keymap(mode, lhs, rhs, opts)
    opts = opts or {}
    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { buffer = bufnr }, opts))
  end

  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  local function buf_fzf_keymap(lhs, function_name, function_opts, keymap_opts)
    function_opts = function_opts or {}
    keymap_opts = keymap_opts or {}
    vim.keymap.set("n", lhs, function()
      require("fzf-lua")[function_name](function_opts)
    end, vim.tbl_extend("force", { buffer = bufnr }, keymap_opts))
  end

  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  -- Get/Go
  buf_fzf_keymap("gr", "lsp_references", {}, { desc = "Goto references" })
  buf_fzf_keymap("gd", "lsp_definitions", {}, { desc = "Goto definition" })
  buf_fzf_keymap("gD", "lsp_declarations", {}, { desc = "Goto declaration" })
  buf_fzf_keymap("gI", "lsp_implementations", {}, { desc = "Goto implementation" })
  buf_fzf_keymap("gt", "lsp_typedefs", {}, { desc = "Goto type definition" })

  -- Calls
  buf_fzf_keymap("<Leader>fi", "lsp_incoming_calls", {}, { desc = "Find incoming calls (lsp)" })
  buf_fzf_keymap("<Leader>fo", "lsp_outgoing_calls", {}, { desc = "Find outgoing calls (lsp)" })

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

  -- Symbols
  buf_fzf_keymap("<Leader>fs", "lsp_document_symbols", {}, { desc = "Find symbols (lsp)" })
  buf_fzf_keymap("<Leader>fS", "lsp_workspace_symbols", {}, { desc = "Find symbols (lsp Workspace)" })

end
