local M = {}
local ts = vim.treesitter

M.print_node = function(node)
	vim.print(ts.get_node_text(node, 0))
end

M.notify = function(icon, msg, type)
	---@diagnostic disable-next-line
	vim.notify.dismiss()
	vim.notify(msg, type, { icon = icon, timeout = 500, render = "compact" })
end

M.is_valid_lang = function(parser)
	local lang = parser:lang()
	if lang == "lua" then
		return true
	else
		return false
	end
end

return M
