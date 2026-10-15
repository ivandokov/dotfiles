-- Ctrl+h/j/k/l moves between Neovim splits and tmux panes seamlessly.
-- The tmux side is already configured in ~/.tmux.conf ("Smart pane switching").
return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Go to Left Window/Pane" },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Go to Lower Window/Pane" },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Go to Upper Window/Pane" },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Go to Right Window/Pane" },
    },
    init = function()
      vim.g.tmux_navigator_no_wrap = 1
    end,
  },
}
