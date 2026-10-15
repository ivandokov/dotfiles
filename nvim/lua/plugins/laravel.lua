-- Laravel / Livewire / Blade support.
--
-- laravel.nvim: Artisan, routes, make, related files, Tinker, and completion for
--   view(), route(), config(), env() and Eloquent columns in where()/orderBy().
-- blade-nav.nvim: go to file on <x-component>, @include, @extends, view(),
--   config(), __() and more. Plus completion for Blade components and Livewire tags.
-- `gf` combines both (see lua/user/laravel_gf.lua, mapped in config/keymaps.lua).
--
-- Both only activate inside Laravel projects.

return {
  {
    "folke/which-key.nvim",
    opts = { spec = { { "<leader>l", group = "laravel" } } },
  },

  {
    "adalessa/laravel.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
    },
    ft = { "php", "blade" },
    event = { "BufEnter composer.json" },
    -- stylua: ignore
    keys = {
      { "<leader>ll", function() Laravel.pickers.laravel() end, desc = "Laravel Picker (everything)" },
      { "<leader>la", function() Laravel.pickers.artisan() end, desc = "Artisan" },
      { "<leader>lr", function() Laravel.pickers.routes() end, desc = "Routes" },
      { "<leader>lm", function() Laravel.pickers.make() end, desc = "Make (artisan make:*)" },
      { "<leader>lR", function() Laravel.commands.run("picker:related") end, desc = "Related Files" },
      { "<leader>lo", function() Laravel.pickers.resources() end, desc = "Resources (models, views, ...)" },
      { "<leader>lc", function() Laravel.pickers.commands() end, desc = "Custom Commands" },
      { "<leader>lt", function() Laravel.commands.run("actions") end, desc = "Laravel Code Actions" },
      { "<leader>lu", function() Laravel.commands.run("hub") end, desc = "Artisan Hub (serve, vite, ...)" },
      { "<leader>lp", function() Laravel.commands.run("command_center") end, desc = "Command Center" },
      { "<leader>lk", function() Laravel.commands.run("tinker:open") end, desc = "Tinker" },
      { "<leader>lv", function() Laravel.commands.run("view:finder") end, desc = "Where Is This View Used" },
      { "<leader>le", function() Laravel.commands.run("env:configure") end, desc = "Configure Environment (local/sail/herd)" },
      { "<leader>lh", function() Laravel.run("artisan docs") end, desc = "Laravel Docs" },
    },
    opts = {
      features = {
        pickers = { provider = "snacks" },
      },
      -- The generated vendor/_model_helpers.php declares every query builder
      -- parameter as required (false "Not enough arguments" errors) and makes
      -- go to definition on a model show two locations. Use laravel-ide-helper instead.
      eloquent_generate_doc_blocks = false,
    },
  },

  {
    "ricardoramirezr/blade-nav.nvim",
    ft = { "blade", "php" },
    opts = {
      -- laravel.nvim already completes route names
      include_routes_in_cmp = false,
      -- completion goes through blink.cmp (configured below), not nvim-cmp/coq.
      -- gf is mapped in config/keymaps.lua, which calls blade-nav itself.
      integrations = { cmp = false, coq = false, gf = false },
      -- keep K for the language server's hover documentation
      annotations = { create_keymaps = false },
    },
  },

  -- Register both completion sources in blink.cmp for PHP and Blade files
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        per_filetype = {
          php = { inherit_defaults = true, "laravel" },
          blade = { inherit_defaults = true, "laravel", "blade-nav" },
        },
        providers = {
          laravel = {
            name = "Laravel",
            module = "laravel.extensions.completion.blink",
            score_offset = 95,
          },
          ["blade-nav"] = {
            name = "Blade",
            module = "blade-nav.integrations.blink",
            score_offset = 90,
          },
        },
      },
    },
  },
}
