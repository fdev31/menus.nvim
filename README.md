# menus.nvim
Very simple menu system for neovim

# Installation

## Lazy

Add to your plugin list:

```lua
  { 'fdev31/menus.nvim' },
```

# Usage

```lua
vim.keymap.set({ 'n', 'v' }, '<leader>cc', function()
  require('menus').menu(require('custom.menus').main_menu)
end, { desc = '[c]ommands' })
```

Assuming a `lua/custom/menus.lua` file is present, with a table having having properties consisting in a list of **Entries**.

Each **Entry** have the following properties:

A `text`, which is the (mandatory) text to display, and one of:

- `cmd` - A vim command to execute
- `command` - A shell command to execute (in a terminal buffer)
- `handler` - A function to execute
- `options` - A list of entries to create a sub-menu

Example:

```lua
local M = {}

local builtin = require 'telescope.builtin'

local git_menu = {
  {
    text = ' file history',
    handler = builtin.git_bcommits,
  },
  {
    text = ' line history',
    handler = package.loaded.snacks.picker.git_log_line,
  },
  {
    text = ' Add file',
    cmd = '!git add "%"',
  },
  {
    text = ' Reset file',
    cmd = '!git reset HEAD "%"',
  },
  {
    text = '⏬Checkout branch',
    handler = package.loaded.snacks.picker.git_branches,
  },
}

M.main_menu = {
  {
    text = ' Git ▶',
    options = git_menu,
  },
  { text = ' Silicon', cmd = 'Silicon' },
  { text = ' Copy diff', cmd = '!git diff "%" | wl-copy' },
  { text = '→ Scp cra', cmd = '!scp "%" cra:/tmp' },
}

return M
```

