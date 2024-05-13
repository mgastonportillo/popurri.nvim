local config = require("popurri.config")
local utils = require("popurri.utils")
local parsers = require("nvim-treesitter.parsers")
local palettes = require("popurri.constants").palettes
local ts = vim.treesitter
local notif_type = vim.log.levels
local timer = vim.loop.new_timer()

local M = {}

local qs_lua_arg = [[
  (parameters (identifier) @popurri_lua_arg)
]]
local qs_lua_var = [[
  [
    (variable_list (identifier))
    (variable_list (dot_index_expression) @mindex (#lua-match? @mindex "^M"))
  ] @popurri_lua_var
]]

---@param palettes_tbl table
local pick_random_palette = function(palettes_tbl)
	local keys = vim.tbl_keys(palettes_tbl)
	local key = keys[math.random(#keys)]
	local palette = palettes[key]
	return palette
end

---@param palette_tbl table
local pick_random_colour = function(palette_tbl)
	local colour = palette_tbl[math.random(#palette_tbl)]
	return colour
end

local created_hl = {}

---@param rline integer
---@param rstart integer
---@param rend integer
---@param palette table
local create_hl = function(bufnr, ns_id, rline, rstart, rend, palette)
	local colour = pick_random_colour(palette)
	local hl = "PopurriL" .. tostring(rline) .. "S" .. tostring(rstart) .. "E" .. tostring(rend)
	vim.cmd("highlight " .. hl .. " guifg=" .. colour)
	vim.api.nvim_buf_add_highlight(bufnr, ns_id, hl, rline, rstart, rend)
	table.insert(created_hl, hl)
end

---@type integer
local bufnr

---@type number
local namespace_id

local clear_highlights = function()
	if bufnr and namespace_id then
		vim.api.nvim_buf_clear_namespace(bufnr, namespace_id, 0, -1)
		for _, hl in ipairs(created_hl) do
			vim.cmd("highlight clear " .. hl)
		end
	end
end

local popurrify = function(parser, qs, palette)
	if not bufnr then
		bufnr = vim.api.nvim_get_current_buf()
	end
	if not namespace_id then
		namespace_id = vim.api.nvim_create_namespace("Popurri")
	end

	local tree = parser:parse()[1]
	local root = tree:root()
	local lang = parser:lang()
	local query = ts.query.parse(lang, qs)

	for _, matches in query:iter_matches(root, 0, 1, -1) do
		for _, match in ipairs(matches) do
			local range = { ts.get_node_range(match) }
			local rline = range[1]
			local rstart = range[2]
			local rend = range[4]
			local next_rstart = rstart
			repeat
				if M.get_status() == false then
					break
				end
				create_hl(bufnr, namespace_id, rline, next_rstart, rend, palette)
				next_rstart = next_rstart + 1
			until next_rstart > rend
		end
	end
end

---@param qs string
---@param palette table
local start_timer = function(parser, qs, palette)
	timer:start(
		0,
		200,
		vim.schedule_wrap(function()
			popurrify(parser, qs, palette)
		end)
	)
end

local stop_timer = function()
	timer:stop()
end

local set_status = function(new_status)
	config.status = new_status
end

M.get_status = function()
	return config.status
end

M.start = function()
	local parser = parsers.get_parser(bufnr)
	local palette = pick_random_palette(palettes)
	if utils.is_valid_lang(parser) then
		start_timer(parser, qs_lua_arg, palette)
		utils.notify(" 🎉", "Popurri started", notif_type.INFO)
		set_status(true)
	else
		utils.notify(" ❌", "Invalid language! Popurri only works with Lua (by now)", notif_type.ERROR)
	end
end

M.stop = function()
	stop_timer()
	if bufnr and namespace_id then
		vim.api.nvim_buf_clear_namespace(bufnr, namespace_id, 0, -1)
	end
	clear_highlights()
	utils.notify(" 🛑", "Popurri stopped", notif_type.WARN)
	set_status(false)
end

return M
