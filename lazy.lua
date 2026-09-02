-- Read by lazy.nvim so that a bare { "tw4/ai-agents.nvim" } pulls in everything
-- it needs, already configured.
--
-- claudecode.nvim is set up here rather than left to the user because two of its
-- defaults are what this plugin exists to fix: a $HOME-local Claude CLI that is
-- invisible to Neovim outside a login shell, and diffs opened in the current tab
-- where a file tree and a terminal leave them no room. Anything you set in your
-- own claudecode.nvim spec is merged on top of these.
return {
  "tw4/ai-agents.nvim",
  dependencies = {
    {
      "coder/claudecode.nvim",
      dependencies = { "folke/snacks.nvim" },
      opts = function()
        return require("ai_agents.claude").opts()
      end,
    },
    {
      "olimorris/codecompanion.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
    },
  },
}
