---ai-agents.nvim
---
---One picker for every AI coding agent, and one pair of mappings to approve or
---reject what they propose.
local M = {}

local config = require("ai_agents.config")

M.pick = function()
  require("ai_agents.picker").pick()
end

M.toggle = function()
  require("ai_agents.picker").toggle()
end

M.accept = function()
  require("ai_agents.diff").accept()
end

M.deny = function()
  require("ai_agents.diff").deny()
end

---Options that should be passed to claudecode.nvim's setup.
M.claude_opts = function()
  return require("ai_agents.claude").opts()
end

local function set_keymaps()
  local prefix = config.options.prefix
  local map = function(suffix, fn, desc)
    vim.keymap.set("n", prefix .. suffix, fn, { desc = "Coding agents: " .. desc })
  end
  map("p", M.pick, "pick provider")
  map("t", M.toggle, "show or hide the session")
  map("a", M.accept, "accept proposed changes")
  map("d", M.deny, "reject proposed changes")
end

---@param opts AiAgents.Options|nil
function M.setup(opts)
  config.setup(opts)
  if config.options.keymaps then
    set_keymaps()
  end
end

return M
