local M = {}

---@type boolean
M.status = false

---@type PopurriConfig
local defaults = {
	default_query = nil,
}

---@type PopurriConfig
M.options = {}

---@param opts? PopurriConfig
M.setup = function(opts)
	M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

return M
