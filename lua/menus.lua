local M = { config = {} }

local git_menu = { --{{{
	{
		text = " Add file",
		cmd = '!git add "%"',
	},
	{
		text = " Reset file",
		cmd = '!git reset HEAD "%"',
	},
} -- }}}

local menusystem = {
	{
		text = " Git ▶",
		options = git_menu,
	},
	{ text = " Silicon", cmd = "Silicon" },
	{ text = " Copy diff", cmd = '!git diff "%" | wl-copy' },
}

local execute_entry = function(entry)
	if not entry then
		return
	end
	if entry.options then
		M.menu(entry.options, entry.text)
	elseif entry.input then
		vim.ui.input({
			prompt = entry.text,
		}, function(input)
			if input then
				entry.handler(input)
			end
		end)
	elseif entry.cmd then
		local prefix = (entry.silent and "silent ") or ""
		vim.cmd(prefix .. entry.cmd)
	elseif entry.command then
		vim.cmd("terminal " .. entry.command)
	elseif entry.handler then
		entry.handler()
	end
end

local _format_entry = function(entry)
	return entry.text or entry.command or entry.cmd or "undefined"
end

--- Displays a menu using the configured menu system
--- @param options table|nil List of menu "entries". If nil, uses the default menusystem
--- @param label string|nil The label for the menu. If nil, uses "Main menu"
--- @usage M.menu({{text = 'quit', cmd = 'quit'}, {text = 'world', command = 'echo world'}, {text = 'notify', handler = function() vim.notify('hello') end}})
M.menu = function(options, label)
	options = options or menusystem
	label = label or "Main menu"

	vim.ui.select(options, {
		prompt = label,
		format_item = _format_entry,
	}, execute_entry)
end

M.setup = function(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

return M
