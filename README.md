# menus.nvim
Very simple menu system for neovim.
Using vim.ui.select to display a menu of options, and execute the selected option.
Supports nested menus.

# Installation

## Lazy

Add to your plugin list:

```lua
  { 'fdev31/menus.nvim' },
```

# Usage

```lua
-- storing menus in a separate file
vim.keymap.set({ 'n', 'v' }, '<leader>cc', function()
  local main_menu = require('custom.menus').main_menu
  require('menus').menu(main_menu)
end, { desc = '[c]ommands' })

-- inline
vim.keymap.set({ 'n', 'v' }, '<leader>cd', function()
  require('menus').menu({
    { name = 'text', cmd = 'lua vim.notify "{input}"' , input="notification" },
    { name = ' line history', handler = package.loaded.snacks.picker.git_log_line },
    { name = ' Add file', cmd = '!git add "%"' },
    { name = '⏬Checkout branch', handler = package.loaded.snacks.picker.git_branches },

  })
end, { desc = '[c]ommands' })
```

Assuming a `lua/custom/menus.lua` file is present, with a table having having properties consisting in a list of **Entries**.

Each **Entry** have the following properties:

A `name`, which is the (mandatory) text to display, and one of:

- `cmd` - (str) A vim command to execute
  - `silent` - (bool) will add the 'silent ' prefix to the `cmd` (will not output anything)
  - `input` - (str) The title of the prompt asking for user input, the `command` should contain "{input}", that will be replaced by the input content
- `command` - (str) A shell command to execute (in a **terminal** buffer)
  - `input` - (str) The title of the prompt asking for user input, the `command` should contain "{input}", that will be replaced by the input content
- `handler` - (function) code to execute
  - `input` - (str) The title of the prompt asking for user input, which will be passed as a parameter to the handler
- `options` - (table) A list of entries to create a sub-menu

# Demo

[![menus.nvim demo](https://img.youtube.com/vi/BvoI3mE9rFs/0.jpg)](https://www.youtube.com/watch?v=BvoI3mE9rFs)

Complete/real-life examples (requires `snacks.picker` and `telescope`) [here](https://github.com/fdev31/kickstart.nvim/blob/master/lua/config/menus.lua) and here:

```lua
local M = {}

local telescope = require 'telescope.builtin'

local openDiffView = function(_, action)
  action('i', '<CR>', function(prompt_bufnr)
    local selection = require('telescope.actions.state').get_selected_entry()
    require('telescope.actions').close(prompt_bufnr)
    vim.cmd('DiffviewOpen -uno ' .. selection.value .. '...HEAD --imply-local')
  end)
  return true
end

local openDiffViewMB = function(_, action)
  action('i', '<CR>', function(prompt_bufnr)
    local selection = require('telescope.actions.state').get_selected_entry()
    require('telescope.actions').close(prompt_bufnr)
    local result = vim.fn.system('git merge-base HEAD ' .. selection.value)
    local merge_base = result:gsub('%s+', '')
    vim.cmd('DiffviewOpen -uno ' .. merge_base .. '...HEAD --imply-local')
  end)
  return true
end

M.git_compare_what = {
  { name = 'Working copy', cmd = 'DiffviewOpen -uno' },
  {
    name = 'Branch ▶',
    handler = function()
      telescope.git_branches { attach_mappings = openDiffView }
    end,
  },
  {
    name = 'Commit ▶',
    handler = function()
      telescope.git_commits { attach_mappings = openDiffView }
    end,
  },
  {
    name = 'Branch "merge base" (PR like) ▶',
    handler = function()
      telescope.git_branches { attach_mappings = openDiffViewMB }
    end,
  },
}

M.git_menu = { --{{{
  {
    name = ' Commit',
    handler = function()
      require('diffview').close()
      vim.cmd ':terminal git commit'
      vim.cmd ':startinsert'
    end,
  },
  {
    name = ' Amend',
    cmd = '!git commit --amend --no-edit',
    silent = true,
  },
  -- {
  --   name = ' Cached',
  --   command = 'git diff --cached',
  -- },
  {
    name = ' File history',
    handler = telescope.git_bcommits,
  },
  {
    name = ' Line history',
    handler = package.loaded.snacks.picker.git_log_line,
  },
  {
    name = ' Reset file',
    cmd = '!git reset HEAD "%"',
  },
  {
    name = ' Checkout branch',
    handler = telescope.git_branches,
  },
  {
    name = ' Stash changes ▶',
    options = {
      {
        name = ' Push',
        handler = function()
          vim.ui.input({
            prompt = 'Stash message: ',
          }, function(input)
            vim.cmd('!git stash push -m "' .. input .. '"')
          end)
        end,
      },
      { name = '󰋺 Apply', handler = telescope.git_stash },
    },
  },
} -- }}}

M.main_menu = {
  {
    name = ' Git ▶',
    options = M.git_menu,
  },
  {
    name = ' DiffView ▶',
    options = M.git_compare_what,
  },
  { name = ' Runnables ▶', cmd = 'OverseerRun' },
  { name = ' Silicon', cmd = "'<,'> Silicon" },
  { name = ' Copy diff', cmd = '!git diff "%" | wl-copy'},
  { name = ' Send to cra', cmd = '!scp "%" cra:/tmp' },
}

return M
```

