---Accepting and rejecting proposed edits.
local M = {}

---claudecode.nvim marks only the *proposed* buffer with this variable, so its
---accept/deny commands report "No active diff found in current buffer" whenever
---the cursor sits in the original half of the diff. Jumping to the proposed
---window first makes the mappings work from either side.
local MARKER = "claudecode_diff_tab_name"

---@return boolean moved true when a proposed buffer is now focused
local function focus_proposed_buffer()
  if vim.b[MARKER] then
    return true
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.b[buf][MARKER] then
      vim.api.nvim_set_current_win(win)
      return true
    end
  end
  return false
end

---@param command string
local function run(command)
  if not focus_proposed_buffer() then
    vim.notify("No proposed changes in this tab.", vim.log.levels.WARN, { title = "ai-agents" })
    return
  end
  vim.cmd(command)
end

---Accept the proposed changes in the current tab.
function M.accept()
  run("ClaudeCodeDiffAccept")
end

---Reject the proposed changes in the current tab.
function M.deny()
  run("ClaudeCodeDiffDeny")
end

return M
