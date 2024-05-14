local M = {}

M.colour_palettes = {
	pop = {
		"#ff5252",
		"#ffee53",
		"#53ffa9",
		"#5395ff",
		"#ef53ff",
	},
	cake = {
		"#ff9999",
		"#9ab9ff",
		"#db97ff",
		"#9affc1",
		"#fdffa6",
	},
}

M.query_strings = {
	lua = {
		args = [[
      (parameters (identifier) @popurri_lua_arg)
    ]],
		vars = [[
      (variable_list (identifier) @popurri_lua_var)
    ]],
	},
}

return M
