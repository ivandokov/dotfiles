-- HTML, Emmet, JavaScript/TypeScript, JSON, YAML and SQL tweaks.
--
-- Formatting rule for this config: files are only formatted by a formatter the
-- project opted into (Pint, a Prettier config, ESLint). The language servers'
-- own formatters are turned off so they never reformat a file on save.
local no_lsp_format = { "intelephense", "vtsls", "html", "jsonls", "yamlls", "tailwindcss", "emmet_language_server" }

return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_no_lsp_format", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and vim.tbl_contains(no_lsp_format, client.name) then
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end
        end,
      })
    end,
    opts = {
      servers = {
        -- HTML tag and attribute completion, also inside Blade
        html = {
          filetypes = { "html", "blade" },
          init_options = { provideFormatter = false },
        },
        jsonls = {
          init_options = { provideFormatter = false },
        },
        yamlls = {
          settings = { yaml = { format = { enable = false } } },
        },
        -- Emmet abbreviations (div.card>ul>li*3), also inside Blade
        emmet_language_server = {
          filetypes = {
            "html",
            "blade",
            "css",
            "scss",
            "javascriptreact",
            "typescriptreact",
            "vue",
          },
        },
      },
    },
  },

  -- The `lang.sql` extra adds sqlfluff with the generic ANSI dialect, which is
  -- very noisy for MySQL/SQLite queries. Keep the database UI, drop sqlfluff.
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      for ft, linters in pairs(opts.linters_by_ft or {}) do
        opts.linters_by_ft[ft] = vim.tbl_filter(function(l)
          return l ~= "sqlfluff"
        end, linters)
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      for ft, formatters in pairs(opts.formatters_by_ft or {}) do
        if type(formatters) == "table" then
          opts.formatters_by_ft[ft] = vim.tbl_filter(function(f)
            return f ~= "sqlfluff"
          end, formatters)
        end
      end
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(pkg)
        return pkg ~= "sqlfluff"
      end, opts.ensure_installed or {})
    end,
  },
}
