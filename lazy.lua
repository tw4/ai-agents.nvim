-- Read by lazy.nvim, so `{ "tw4/ai-agents.nvim" }` on its own is a complete
-- install: dependencies are pulled in and configured, the commands and the
-- default mappings work, and nothing loads until you first reach for it.
--
-- claudecode.nvim is configured here rather than left to the user because two
-- of its defaults are what this plugin exists to fix: a $HOME-local Claude CLI
-- that is invisible to Neovim outside a login shell, and diffs opened in the
-- current tab where a file tree and a terminal leave them no room. Anything you
-- set in your own claudecode.nvim spec is merged on top of these.
--
-- The mappings live here instead of in setup() so that lazy.nvim can defer
-- loading until one is pressed. To change them, override `keys` in your own
-- spec the way you would for any lazy.nvim plugin.
return {
  "tw4/ai-agents.nvim",
  opts = { keymaps = false },
  cmd = { "AiAgents", "AiAgentsAccept", "AiAgentsDeny" },
  keys = {
    { "<leader>ip", "<cmd>AiAgents<cr>", desc = "Pick AI provider" },
    { "<leader>ia", "<cmd>AiAgentsAccept<cr>", desc = "Accept proposed changes" },
    { "<leader>id", "<cmd>AiAgentsDeny<cr>", desc = "Reject proposed changes" },
  },
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
