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
	{ name = " Silicon", cmd = "'<,'>Silicon" },
	{ name = " Copy diff", cmd = '!git diff "%" | wl-copy' },
}

function ask_user(prompt, handler)
	vim.ui.input({
		prompt = prompt,
	}, function(input)
		if input then
			handler(input)
		else
			vim.notify("No input provided", vim.log.levels.WARN, {
				title = prompt .. " had no input",
			})
		end
	end)
end
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
	local prefix = (entry.silent and "silent ") or ""
	if entry.options then
		-- If the entry has sub-options, open a submenu.
		M.menu(entry.options, entry.name or entry.text)
	elseif entry.cmd then
		-- Execute a Vim command, optionally silently.
		if entry.input then
			ask_user(entry.input, function(input)
				vim.cmd(prefix .. entry.cmd:gsub("{input}", input))
			end)
		else
			vim.cmd(prefix .. entry.cmd)
		end
	elseif entry.command then
		if entry.input then
			ask_user(entry.input, function(input)
				vim.cmd("terminal " .. entry.command:gsub("{input}", input))
			end)
		else
			vim.cmd("terminal " .. entry.command)
		end
	elseif entry.handler then
		if entry.input then
			ask_user(entry.input, entry.handler)
		else
			entry.handler()
		end
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
