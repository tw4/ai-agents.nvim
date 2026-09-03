---Discovery of the coding agents available on this machine.
---
---Two very different things are presented as one list:
---  * ACP agents  - external CLIs (codex, copilot, opencode, ...) driven through
---    the Agent Client Protocol. They propose edits and you approve them, which
---    is the flow people know from IDE extensions.
---  * HTTP models - plain API providers (openai, anthropic, gemini, ollama, ...)
---    used for chat and inline edits.
---
---The list is not hardcoded: it is read from CodeCompanion's own command
---completion, so new providers appear here as soon as CodeCompanion ships them.
local M = {}

local config = require("ai_agents.config")

---An ACP agent is spawned as an external process. When that binary is missing
---CodeCompanion surfaces a raw ENOENT ("Failed: ... (cmd): 'claude-agent-acp'"),
---so the binary is resolved up front and reported instead.
---@param adapter table
---@return string|nil
local function agent_binary(adapter)
  local commands = adapter.commands
  if type(commands) ~= "table" then
    return nil
  end
  local command = commands.default or commands.selected
  if type(command) ~= "table" or type(command[1]) ~= "string" then
    return nil
  end
  return command[1]
end

---Adapter names come from CodeCompanion's own config rather than from the
---completion of :CodeCompanionChat. The completion is only reachable when
---nvim_get_commands() hands back a callable, which it does from Neovim 0.12
---on; before that the `complete` field is the literal string "<Lua function>"
---and every provider silently disappears.
---@return string[]|nil names, string|nil err
local function adapter_names()
  local ok, cc_config = pcall(require, "codecompanion.config")
  if not ok then
    return nil, "codecompanion.nvim is not installed"
  end

  local groups = cc_config.adapters
  if type(groups) ~= "table" then
    return nil, "CodeCompanion returned no adapters"
  end

  local names = {}
  for _, group in ipairs({ "acp", "http" }) do
    for name in pairs(groups[group] or {}) do
      -- `opts` sits alongside the adapters in both groups.
      if name ~= "opts" then
        table.insert(names, name)
      end
    end
  end

  if #names == 0 then
    return nil, "CodeCompanion returned no adapters"
  end

  table.sort(names)
  return names
end

---@class AiAgents.Provider
---@field name string
---@field type "acp"|"http"
---@field binary string|nil  Required executable, ACP agents only
---@field available boolean  False only when a required binary is missing

---Every provider CodeCompanion knows about, most useful first.
---@return AiAgents.Provider[]|nil providers, string|nil err
function M.list()
  local names, err = adapter_names()
  if not names then
    return nil, err
  end

  local excluded = {}
  for _, name in ipairs(config.options.exclude) do
    excluded[name] = true
  end

  local resolve = require("codecompanion.adapters").resolve
  local providers = {}
  for _, name in ipairs(names) do
    if not excluded[name] then
      local ok, adapter = pcall(resolve, name)
      -- No roles means it is not something you can hold a conversation with.
      if ok and type(adapter) == "table" and adapter.roles then
        local binary = adapter.type == "acp" and agent_binary(adapter) or nil
        table.insert(providers, {
          name = name,
          type = adapter.type,
          binary = binary,
          -- HTTP providers need an API key rather than a binary, and that can
          -- only be judged once a request is made, so they count as available.
          available = binary == nil or vim.fn.executable(binary) == 1,
        })
      end
    end
  end

  -- Usable first, then ACP agents (the ones with the propose/approve flow).
  table.sort(providers, function(a, b)
    if a.available ~= b.available then
      return a.available
    end
    if (a.type == "acp") ~= (b.type == "acp") then
      return a.type == "acp"
    end
    return a.name < b.name
  end)

  return providers
end

---@param provider AiAgents.Provider
---@return string
function M.describe(provider)
  local label = provider.type == "acp" and "ACP agent - proposes edits you approve" or "HTTP model"
  if not provider.available then
    label = label .. string.format(" [%s not installed]", provider.binary)
  end
  return string.format("%-20s %s", provider.name, label)
end

return M
