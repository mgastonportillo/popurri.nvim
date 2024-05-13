local M = {}

local api = require("popurri.api")
local config = require("popurri.config")
local cmd = vim.api.nvim_create_user_command

local create_commands = function()
	cmd("Popurri", function()
		if api.get_status() == false then
			api.start()
		else
			api.stop()
		end
	end, { desc = "Toggle Popurri" })
end

---@param opts? PopurriConfig
local setup = function(opts)
	config.setup(opts)
	create_commands()
end

---@type fun(opts: PopurriConfig)
M.setup = setup

return M
