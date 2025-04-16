local M = { config = {} }

local git_menu = { --{{{
	{
		name = " Add file",
		cmd = '!git add "%"',
	},
	{
		name = " Reset file",
		cmd = '!git reset HEAD "%"',
	},
} -- }}}

local menusystem = {
	{
		name = " Git ▶",
		options = git_menu,
	},
	{ name = " Silicon", cmd = "Silicon" },
	{ name = " Copy diff", cmd = '!git diff "%" | wl-copy' },
}

--- Executes a menu entry based on its type.
-- @param entry The menu entry to execute. It should be a table containing one of the following keys:
-- - `options` (for submenus),
-- - `input` (for user input),
-- - `cmd` (for Vim commands),
-- - `command` (for terminal commands),
-- - `handler` (for custom functions).
-- @param parent The parent menu's name or identifier, used for context in notifications.
local execute_entry = function(entry, parent)
	if not entry then
		return
	end
	if entry.options then
		-- If the entry has sub-options, open a submenu.
		M.menu(entry.options, entry.name)
	elseif entry.input then
		-- If the entry requires user input, prompt the user.
		vim.ui.input({
			prompt = entry.name or entry.text,
		}, function(input)
			if input then
				-- Call the handler with the provided input.
				entry.handler(input)
			else
				-- Notify the user if no input is provided.
				vim.notify("No input provided", vim.log.levels.WARN, {
					title = parent .. " " .. entry.name or entry.text,
				})
			end
		end)
	elseif entry.cmd then
		-- Execute a Vim command, optionally silently.
		local prefix = (entry.silent and "silent ") or ""
		if entry.input then
			vim.ui.input({
				prompt = entry.text,
			}, function(input)
				if input then
					-- replace "{input}" with the actual input
					input = input:gsub("{input}", input)
					entry.cmd(input)
				else
					vim.notify("No input provided", vim.log.levels.WARN, {
						title = parent .. " " .. entry.text,
					})
				end
			end)
		else
			vim.cmd(prefix .. entry.cmd)
		end
	elseif entry.command then
		-- Execute a terminal command.
		vim.cmd("terminal " .. entry.command)
	elseif entry.handler then
		-- Call a custom handler function.
		entry.handler()
	end
end

--- Formats a menu entry for display.
-- This function determines the display name for a menu entry by prioritizing
-- the `name`, `command`, `cmd`, or defaults to "undefined" if none are provided.
-- @param entry The menu entry to format. It should be a table containing optional keys:
--  - `name`, `command`, or `cmd`.
-- @return A string representing the formatted entry name.
local _format_entry = function(entry)
	return entry.name or entry.text or entry.command or entry.cmd or "undefined"
end

--- Displays a menu using the configured menu system
--- @param options table|nil List of menu "entries". If nil, uses the default menusystem
--- @param label string|nil The label for the menu. If nil, uses "Main menu"
--- @usage M.menu({{name = 'quit', cmd = 'quit'}, {name = 'world', command = 'echo world'}, {name = 'notify', handler = function() vim.notify('hello') end}})
M.menu = function(options, label)
	options = options or menusystem
	label = label or "Main menu"

	vim.ui.select(options, {
		prompt = label,
		format_item = _format_entry,
	}, function(entry)
		execute_entry(entry, label)
	end)
end

M.setup = function(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

return M
