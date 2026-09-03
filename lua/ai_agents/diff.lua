---Accepting and rejecting proposed edits, whichever agent proposed them.
---
---Two backends put a diff on screen and neither knows about the other:
---
---  * claudecode.nvim marks the *proposed* buffer with a variable and exposes
---    :ClaudeCodeDiffAccept / :ClaudeCodeDiffDeny. Those commands only work
---    while the cursor is in that buffer, and report "No active diff found in
---    current buffer" from the original half of the diff.
---  * CodeCompanion -- and so every ACP agent and model it drives -- attaches
---    its own accept/reject keymaps to the diff buffer, each closing over the
---    diff it belongs to. There is no registry to look the diff up in, so the
---    buffer-local mapping is the handle: find it, and call what it calls.
---
---Either way the work is the same: find the buffer holding the proposal, make
---it current, and resolve it.
local M = {}

---claudecode.nvim marks only the proposed buffer with this variable.
local CLAUDE_MARKER = "claudecode_diff_tab_name"

---Normalise a keymap's left-hand side so "g2" and "<leader>x" both compare
---correctly against what Neovim reports for a buffer-local mapping.
---@param lhs string
---@return string
local function normalise(lhs)
  return vim.api.nvim_replace_termcodes(lhs, true, true, true)
end

---Walk every window, current tabpage first, and hand each buffer to `pred`.
---@param pred fun(buf: integer): boolean
---@return integer|nil win
local function find_window(pred)
  local current = vim.api.nvim_get_current_win()
  if pred(vim.api.nvim_win_get_buf(current)) then
    return current
  end

  local seen = { [current] = true }
  local tabs = { vim.api.nvim_get_current_tabpage() }
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if tab ~= tabs[1] then
      table.insert(tabs, tab)
    end
  end

  for _, tab in ipairs(tabs) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      if not seen[win] then
        seen[win] = true
        if pred(vim.api.nvim_win_get_buf(win)) then
          return win
        end
      end
    end
  end
  return nil
end

---@param buf integer
---@return boolean
local function is_claude_diff(buf)
  return vim.b[buf][CLAUDE_MARKER] ~= nil
end

---The key CodeCompanion binds for `name`, honouring the user's own config.
---@param name "accept_change"|"reject_change"
---@return string|nil
local function codecompanion_key(name)
  local ok, config = pcall(require, "codecompanion.config")
  if not ok then
    return nil
  end
  local keymaps = vim.tbl_get(config, "interactions", "shared", "keymaps", name, "modes", "n")
  -- A mode may be configured as a single key or as a list of them.
  if type(keymaps) == "table" then
    return keymaps[1]
  end
  return keymaps
end

---The buffer-local mapping CodeCompanion attached to a diff, if this buffer
---carries one.
---@param buf integer
---@param lhs string
---@return function|nil
local function codecompanion_callback(buf, lhs)
  local wanted = normalise(lhs)
  for _, map in ipairs(vim.api.nvim_buf_get_keymap(buf, "n")) do
    if map.callback and normalise(map.lhs) == wanted then
      return map.callback
    end
  end
  return nil
end

---@param name "accept_change"|"reject_change"
---@param claude_command string
local function resolve(name, claude_command)
  local win = find_window(is_claude_diff)
  if win then
    vim.api.nvim_set_current_win(win)
    vim.cmd(claude_command)
    return
  end

  local lhs = codecompanion_key(name)
  if lhs then
    local callback
    win = find_window(function(buf)
      callback = codecompanion_callback(buf, lhs)
      return callback ~= nil
    end)
    if win and callback then
      vim.api.nvim_set_current_win(win)
      callback()
      return
    end
  end

  vim.notify("No proposed changes to act on.", vim.log.levels.WARN, { title = "ai-agents" })
end

---Accept the proposed changes.
function M.accept()
  resolve("accept_change", "ClaudeCodeDiffAccept")
end

---Reject the proposed changes.
function M.deny()
  resolve("reject_change", "ClaudeCodeDiffDeny")
end

return M
