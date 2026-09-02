---@class AiAgents.Config
local M = {}

---@class AiAgents.Options
local defaults = {
  --- Adapters that ship with CodeCompanion but are not chat providers: they back
  --- the `@web_search` tool. Picking one as a provider fails in a confusing way.
  exclude = { "jina", "tavily", "duckduckgo" },

  --- Register the default keymaps listed in the README. Set to false to bind
  --- the `:AiAgents*` commands yourself.
  keymaps = true,

  --- Prefix used for the default keymaps.
  prefix = "<leader>i",

  --- Claude Code (claudecode.nvim) specific behaviour.
  claude = {
    --- Resolve the Claude Code CLI. Local installs live under $HOME and are not
    --- always on $PATH when Neovim starts outside a login shell, which makes
    --- claudecode.nvim fail with "'claude' is not executable".
    resolve_cmd = true,
    --- Extra paths to check before falling back to `claude` on $PATH.
    cmd_candidates = {
      "~/.local/bin/claude",
      "~/.claude/local/claude",
    },
  },
}

---@type AiAgents.Options
M.options = vim.deepcopy(defaults)

M.defaults = defaults

---@param opts AiAgents.Options|nil
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
  return M.options
end

return M
