local M = {}

M.status = false

---@type PopurriConfig
local defaults = {}

---@type PopurriConfig
M.options = {}

---@param opts? PopurriConfig
M.setup = function(opts)
	opts = opts or {}
	M.options = vim.tbl_deep_extend("force", defaults, opts)
end

M.setup()

return M
