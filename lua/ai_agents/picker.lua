---The provider picker: one keymap to reach every coding agent.
local M = {}

local providers = require("ai_agents.providers")

---Claude Code is driven by claudecode.nvim rather than CodeCompanion, so it is
---added to the list by hand -- it speaks Claude's own IDE protocol, which gives
---a better diff experience than routing Claude through ACP.
---@return AiAgents.Provider|nil
local function claude_code_entry()
  if not pcall(require, "claudecode") then
    return nil
  end
  local cmd = require("ai_agents.claude").resolve_cmd()
  return {
    name = "claude-code",
    type = "acp",
    binary = cmd or "claude",
    available = cmd ~= nil or vim.fn.executable("claude") == 1,
    native = true,
  }
end

---The provider the last session was opened with. Both backends can hide and
---restore their own window, but only this knows which of them to ask.
---@type AiAgents.Provider|nil
local opened = nil

---Open a session with the given provider.
---@param provider AiAgents.Provider
function M.open(provider)
  if not provider.available then
    vim.notify(
      string.format("`%s` is required by %s but was not found on your system.", provider.binary, provider.name),
      vim.log.levels.WARN,
      { title = "ai-agents" }
    )
    return
  end

  opened = provider

  if provider.native then
    vim.cmd("ClaudeCode")
    return
  end

  vim.cmd("CodeCompanionChat adapter=" .. provider.name)
end

---Hide the open session, or bring the last one back. With nothing opened yet
---there is nothing to restore, so this falls through to the picker.
function M.toggle()
  if not opened then
    return M.pick()
  end

  if opened.native then
    -- :ClaudeCode is claudecode.nvim's own show/hide.
    vim.cmd("ClaudeCode")
    return
  end

  require("codecompanion").toggle()
end

---Prompt for a provider and open it.
function M.pick()
  local list, err = providers.list()
  if not list then
    vim.notify(err or "no providers found", vim.log.levels.ERROR, { title = "ai-agents" })
    return
  end

  local claude = claude_code_entry()
  if claude then
    table.insert(list, 1, claude)
  end

  vim.ui.select(list, {
    prompt = "Coding agent:",
    format_item = providers.describe,
  }, function(choice)
    if choice then
      M.open(choice)
    end
  end)
end

return M
