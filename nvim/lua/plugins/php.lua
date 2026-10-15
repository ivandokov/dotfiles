-- PHP, Blade and Laravel tooling on top of LazyVim's `lang.php` extra.

--- True when any of `paths` exists relative to the nearest composer.json above `dir`.
---@param dir string
---@param paths string[]
local function project_has(dir, paths)
  local root = vim.fs.root(dir, "composer.json")
  if not root then
    return false
  end
  for _, path in ipairs(paths) do
    if vim.uv.fs_stat(root .. "/" .. path) then
      return true
    end
  end
  return false
end

-- Intelephense premium licence. Without it intelephense has no rename, go to
-- implementation/type definition or code actions, so phpactor is added for those.
local intelephense_licensed = vim.uv.fs_stat(vim.fn.expand("~/intelephense/licence.txt")) ~= nil
  or vim.uv.fs_stat(vim.fn.expand("~/intelephense/license.txt")) ~= nil

-- phpactor keeps only rename, go to implementation/type definition and code
-- actions. Everything it would duplicate from intelephense is switched off, so
-- completion, hover, diagnostics and "find usages" are not shown twice.
---@param client vim.lsp.Client
local function strip_phpactor_capabilities(client)
  local caps = client.server_capabilities
  if not caps then
    return
  end
  caps.completionProvider = nil
  caps.hoverProvider = false
  caps.definitionProvider = false
  caps.declarationProvider = false
  caps.referencesProvider = false
  caps.documentHighlightProvider = false
  caps.documentSymbolProvider = false
  caps.workspaceSymbolProvider = false
  caps.signatureHelpProvider = nil
  caps.documentFormattingProvider = false
  caps.documentRangeFormattingProvider = false
  caps.inlayHintProvider = false
  caps.selectionRangeProvider = false
  caps.foldingRangeProvider = false
  caps.semanticTokensProvider = nil
  caps.diagnosticProvider = nil
end

return {
  -- Syntax parsers. `php_only` and `blade` give correct highlighting in Blade,
  -- including JavaScript inside Alpine (x-data, @click, :class) and wire:* attributes.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "php",
        "php_only",
        "phpdoc",
        "blade",
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "sql",
        "bash",
      },
    },
  },

  -- Intelephense settings. Docs: https://github.com/bmewburn/intelephense-docs
  -- Premium licence (rename, go to implementation, etc.): put the key in ~/intelephense/licence.txt
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        intelephense = {
          settings = {
            intelephense = {
              -- _ide_helper.php from barryvdh/laravel-ide-helper is often bigger than the 1 MB default
              files = { maxSize = 5000000 },
              -- formatting is done by Pint (see conform below)
              format = { enable = false },
              telemetry = { enabled = false },
            },
          },
        },
        phpactor = {
          enabled = not intelephense_licensed,
          on_init = strip_phpactor_capabilities,
          handlers = {
            ["textDocument/publishDiagnostics"] = function() end,
          },
          init_options = {
            ["language_server.diagnostics_on_open"] = false,
            ["language_server.diagnostics_on_save"] = false,
            ["language_server.diagnostics_on_update"] = false,
            ["language_server_phpstan.enabled"] = false,
            ["language_server_psalm.enabled"] = false,
            ["language_server_php_cs_fixer.enabled"] = false,
            ["php_code_sniffer.enabled"] = false,
          },
        },
      },
    },
  },

  -- Formatting: Laravel Pint, but only in projects that have it installed
  -- (vendor/bin/pint). Older projects without Pint are never reformatted.
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.php = { "pint" }
      opts.formatters = opts.formatters or {}
      opts.formatters.pint = {
        condition = function(_, ctx)
          return project_has(ctx.dirname, { "vendor/bin/pint" })
        end,
        -- Pint reads pint.json from the working directory
        cwd = require("conform.util").root_file({ "pint.json", "composer.json" }),
      }
    end,
  },

  -- Linting: the `lang.php` extra enables phpcs with the PEAR standard, which
  -- flags almost every line of Laravel code. Use PHPStan/Larastan instead,
  -- only when the project has it configured.
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.php = { "phpstan" }
      opts.linters = opts.linters or {}
      opts.linters.phpstan = {
        condition = function(ctx)
          return project_has(ctx.dirname, { "vendor/bin/phpstan" })
            and project_has(ctx.dirname, { "phpstan.neon", "phpstan.neon.dist", "phpstan.dist.neon" })
        end,
      }
    end,
  },

  -- Don't install phpcs / php-cs-fixer (replaced by Pint and PHPStan above)
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(pkg)
        return pkg ~= "phpcs" and pkg ~= "php-cs-fixer"
      end, opts.ensure_installed or {})
    end,
  },
}
