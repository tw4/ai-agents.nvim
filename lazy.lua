-- Read by lazy.nvim so that a bare { "tw4/ai-agents.nvim" } pulls in
-- everything it needs.
return {
  "tw4/ai-agents.nvim",
  dependencies = {
    { "coder/claudecode.nvim", dependencies = { "folke/snacks.nvim" } },
    { "olimorris/codecompanion.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  },
}
