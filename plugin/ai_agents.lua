if vim.g.loaded_ai_agents then
  return
end
vim.g.loaded_ai_agents = true

local command = vim.api.nvim_create_user_command

command("AiAgents", function()
  require("ai_agents").pick()
end, { desc = "Pick a coding agent" })

command("AiAgentsAccept", function()
  require("ai_agents").accept()
end, { desc = "Accept the proposed changes" })

command("AiAgentsDeny", function()
  require("ai_agents").deny()
end, { desc = "Reject the proposed changes" })
