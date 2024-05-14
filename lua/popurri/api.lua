local config = require("popurri.config")
local utils = require("popurri.utils")
local parsers = require("nvim-treesitter.parsers")
local const = require("popurri.constants")
local palettes = const.colour_palettes
local qs = const.query_strings
local ts = vim.treesitter
local notif_type = vim.log.levels
local timer = vim.loop.new_timer()

local M = {}

local supported_langs = { "lua" }

---@type integer | nil
local buffer_nr

---@type number | nil
local namespace_id

---@type string[]
local hl_list = {}

---@type string
local prev_hl_colour = ""

---@param bufnr integer
---@param ns_id number Namespace ID
---@param row_line integer
---@param col_start integer
---@param col_end integer
---@param palette table
local create_hl = function(bufnr, ns_id, row_line, col_start, col_end, palette)
	local lrow = tostring(row_line)
	local scol = tostring(col_start)
	local ecol = tostring(col_end)
	local hl_colour
	repeat
		hl_colour = utils.pick_random_colour(palette)
	until hl_colour ~= prev_hl_colour
	prev_hl_colour = hl_colour
	local hl_name = "PopurriL" .. lrow .. "S" .. scol .. "E" .. ecol
	vim.cmd("highlight " .. hl_name .. " guifg=" .. hl_colour)
	vim.api.nvim_buf_add_highlight(bufnr, ns_id, hl_name, row_line, col_start, col_end)
	table.insert(hl_list, hl_name)
end

--- Remove all Popurri highlights from memory
local clear_hl = function()
	if buffer_nr and namespace_id then
		vim.api.nvim_buf_clear_namespace(buffer_nr, namespace_id, 0, -1)
		for _, hl_name in ipairs(hl_list) do
			vim.cmd("highlight clear " .. hl_name)
		end
	end
end

local set_status = function(new_status)
	config.status = new_status
end

local get_status = function()
	return config.status
end

local popurrify = function(query_string, palette)
	buffer_nr = vim.api.nvim_get_current_buf()
	namespace_id = vim.api.nvim_create_namespace("Popurri")
	local parser = parsers.get_parser(buffer_nr)
	local tree = parser:parse()[1]
	local query = ts.query.parse(parser:lang(), query_string)

	for _, matches in query:iter_matches(tree:root(), 0, 1, -1) do
		for _, match in ipairs(matches) do
			local range = { ts.get_node_range(match) }
			local row = range[1]
			local col_start = range[2]
			local col_end = range[4]
			local col = col_start
			repeat
				if get_status() == false then
					break
				end
				create_hl(buffer_nr, namespace_id, row, col, col_end, palette)
				col = col + 1
			until col > col_end
		end
	end
end

M.get_status = get_status

M.start = function()
	if not utils.is_valid_lang(supported_langs) then
		utils.notify(" ❌", "Popurri: Invalid target!", notif_type.ERROR)
		return
	end

	set_status(true)
	-- local palette = utils.pick_random_palette(palettes)
	timer:start(
		0,
		300,
		vim.schedule_wrap(function()
			-- TODO: Add functionality to query dynamically from the command line
			popurrify(qs.lua.args, palettes.cake)
		end)
	)
	utils.notify(" 🎉", "Popurri started!", notif_type.INFO)
end

M.stop = function()
	if buffer_nr and namespace_id then
		set_status(false)
		timer:stop()
		vim.api.nvim_buf_clear_namespace(buffer_nr, namespace_id, 0, -1)
		clear_hl()
		buffer_nr = nil
		namespace_id = nil
		prev_hl_colour = ""
		utils.notify(" 🛑", "Popurri stopped", notif_type.WARN)
	end
end

return M
