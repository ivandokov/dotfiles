-- AI. Inline completion comes from GitHub Copilot through Neovim's built-in
-- LSP support (LazyVim `ai.copilot-native` extra). Sign in once with :LspCopilotSignIn
-- Claude Code integration comes from the `ai.claudecode` extra (<leader>a...).

local function is_secret_file(bufnr)
  local name = vim.fs.basename(vim.api.nvim_buf_get_name(bufnr))
  return name:match("^%.env") ~= nil or name == "auth.json"
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        copilot = {
          -- Never attach Copilot to .env files or Composer auth.json, so secrets
          -- are not sent to GitHub for completions.
          root_dir = function(bufnr, on_dir)
            if not is_secret_file(bufnr) then
              on_dir(vim.fs.root(bufnr, { ".git" }))
            end
          end,
        },
      },
    },
  },
}
