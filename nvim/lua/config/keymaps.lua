-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- <leader>l is used for Laravel (see lua/plugins/laravel.lua).
-- The plugin manager is still available with :Lazy
pcall(vim.keymap.del, "n", "<leader>l")

-- Go to file, Laravel aware: Livewire tags, route(), view(), <x-components>, @include ...
map("n", "gf", function()
  require("user.laravel_gf").gf()
end, { desc = "Go to File (Laravel aware)" })

-- Copy the current file path, relative to the project (like PhpStorm "Copy Path/Reference")
map("n", "<leader>fy", function()
  local path = vim.fn.expand("%:.")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Copy Relative File Path" })
