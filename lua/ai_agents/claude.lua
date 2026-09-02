---Claude Code (claudecode.nvim) helpers.
local M = {}

local config = require("ai_agents.config")

---Locate the Claude Code CLI.
---
---The native installer puts it under $HOME, which is not always on $PATH when
---Neovim is started outside a login shell (a GUI client, a desktop launcher).
---claudecode.nvim then fails with "'claude' is not executable", so an absolute
---path is preferred when one can be found.
---@return string|nil path nil means "fall back to $PATH"
function M.resolve_cmd()
  if not config.options.claude.resolve_cmd then
    return nil
  end
  for _, candidate in ipairs(config.options.claude.cmd_candidates) do
    local path = vim.fn.expand(candidate)
    if vim.fn.executable(path) == 1 then
      return path
    end
  end
  return nil
end

---Options to merge into claudecode.nvim's own setup.
---@return table
function M.opts()
  return {
    terminal_cmd = M.resolve_cmd(),
    diff_opts = {
      -- With a file tree on one side and the Claude terminal on the other, a
      -- diff opened in the current tab is squeezed into whatever is left. Its
      -- own tab, without the terminal, gives it the full window.
      open_in_new_tab = true,
      hide_terminal_in_new_tab = true,
      layout = "vertical",
    },
  }
end

return M
