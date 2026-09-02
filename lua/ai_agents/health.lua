---`:checkhealth ai_agents`
local M = {}

local INSTALL_HINTS = {
  ["claude"] = "curl -fsSL https://claude.ai/install.sh | bash",
  ["codex-acp"] = "npm install -g @agentclientprotocol/codex-acp  (plus the codex CLI)",
  ["copilot"] = "npm install -g @github/copilot",
  ["opencode"] = "npm install -g opencode-ai",
  ["gemini"] = "npm install -g @google/gemini-cli",
}

function M.check()
  local health = vim.health

  health.start("ai-agents: dependencies")
  for _, plugin in ipairs({ "claudecode", "codecompanion" }) do
    if pcall(require, plugin) then
      health.ok(plugin .. ".nvim is installed")
    else
      health.warn(plugin .. ".nvim is not installed", { "Providers relying on it will not be listed." })
    end
  end

  health.start("ai-agents: providers")
  local providers = require("ai_agents.providers")
  local list, err = providers.list()
  if not list then
    health.error(err or "provider list unavailable")
    return
  end

  local ready, missing = 0, 0
  for _, provider in ipairs(list) do
    if provider.type == "acp" then
      if provider.available then
        ready = ready + 1
        health.ok(string.format("%s (%s)", provider.name, provider.binary))
      else
        missing = missing + 1
        local hint = INSTALL_HINTS[provider.binary]
        health.info(
          string.format("%s needs `%s`", provider.name, provider.binary),
          hint and { "Install with: " .. hint } or nil
        )
      end
    end
  end

  health.info(string.format("%d agent(s) ready, %d not installed", ready, missing))
  health.info("HTTP providers are listed too; they need an API key rather than a binary.")
end

return M
