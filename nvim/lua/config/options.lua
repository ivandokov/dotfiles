-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- PHP language server. Intelephense is the closest to PhpStorm in speed and accuracy.
vim.g.lazyvim_php_lsp = "intelephense"

-- Only run Prettier when the project has a Prettier config, so projects that
-- don't use Prettier are never reformatted on save.
vim.g.lazyvim_prettier_needs_config = true

-- Keep a few lines visible above/below the cursor when scrolling.
vim.opt.scrolloff = 8

-- Relative line numbers make vim motions like `5j` easy. Set to false if you
-- prefer absolute numbers like PhpStorm.
vim.opt.relativenumber = true
