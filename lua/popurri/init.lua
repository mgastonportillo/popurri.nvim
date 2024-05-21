local api = require("popurri.api")
local utils = require("popurri.utils")
local config = require("popurri.config")
local cmd = vim.api.nvim_create_user_command
local M = {}

local create_cmds = function()
	cmd("Popurri", function(opts)
		if opts.fargs[1] == nil then
			if api.get_status() then
				api.stop()
			else
				local default = config.options.default_query

				if default == nil then
					utils.notify(
						" 🎉",
						"Popurri requires an argument to start, or\n      a `default_query` opt different than nil",
						vim.log.levels.ERROR
					)
				else
					api.start(default)
				end
			end
		else
			if api.get_status() then
				api.stop()
			else
				api.start(opts.fargs[1])
			end
		end
	end, {
		desc = "Toggle Popurri",
		nargs = "?",
		complete = function(ArgLead, CmdLine, CursorPos) ---@diagnostic disable-line
			return { "args", "vars" }
		end,
	})

	cmd("PopurriStop", function()
		if api.get_status() then
			api.stop()
		end
	end, { desc = "Force Popurri to stop" })
end

---@param opts? PopurriConfig
M.setup = function(opts)
	config.setup(opts)
	create_cmds()
end

return M
