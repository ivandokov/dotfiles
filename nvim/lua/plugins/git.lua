-- Git. LazyVim already ships gitsigns (changed-line markers, hunk staging, blame)
-- and lazygit integration (<leader>gg). Diffview adds a PhpStorm-like
-- side-by-side diff, file history and 3-way merge conflict view.
return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      {
        "<leader>gv",
        function()
          if next(require("diffview.lib").views) == nil then
            vim.cmd("DiffviewOpen")
          else
            vim.cmd("DiffviewClose")
          end
        end,
        desc = "Diff View (toggle, also for merge conflicts)",
      },
      { "<leader>gV", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (diff view)" },
      { "<leader>gV", ":DiffviewFileHistory<cr>", mode = "x", desc = "Selection History (diff view)" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = { layout = "diff3_mixed" },
      },
    },
  },
}
