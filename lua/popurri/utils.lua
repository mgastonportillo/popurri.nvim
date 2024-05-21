local M = {}

M.notify = function(icon, msg, type)
	vim.notify.dismiss() ---@diagnostic disable-line
	vim.notify(msg, type, { icon = icon, timeout = 500, render = "compact" })
end

---@param supported_langs string[]
M.is_valid_lang = function(supported_langs)
	for _, lang in ipairs(supported_langs) do
		if lang == vim.bo.ft then
			return true
		end
	end

	return false
end

---@param palettes_tbl table
M.pick_random_palette = function(palettes_tbl)
	local keys = vim.tbl_keys(palettes_tbl)
	local key = keys[math.random(#keys)]
	local palette = palettes_tbl[key]
	return palette
end

---@param palette_tbl table
M.pick_random_colour = function(palette_tbl)
	local colour = palette_tbl[math.random(#palette_tbl)]
	return colour
end

return M
