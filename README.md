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
    { text = ' line history', handler = package.loaded.snacks.picker.git_log_line },
    { text = ' Add file', cmd = '!git add "%"' },
    { text = '⏬Checkout branch', handler = package.loaded.snacks.picker.git_branches },

  })
end, { desc = '[c]ommands' })
```

Assuming a `lua/custom/menus.lua` file is present, with a table having having properties consisting in a list of **Entries**.

Each **Entry** have the following properties:

A `text`, which is the (mandatory) text to display, and one of:

- `cmd` - (str) A vim command to execute
  - `silent` - (bool) will add the 'silent ' prefix to the `cmd` (will not output anything)
- `command` - (str) A shell command to execute (in a **terminal** buffer)
- `handler` - (function) code to execute
  - `input` - (str) The title of the prompt asking for user input, which will be passed in handler
- `options` - (table) A list of entries to create a sub-menu

# Demo

[![menus.nvim demo](https://img.youtube.com/vi/BvoI3mE9rFs/0.jpg)](https://www.youtube.com/watch?v=BvoI3mE9rFs)

Complete/real-life example (requires `snacks.picker` and `telescope`):

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
  { text = 'Working copy', cmd = 'DiffviewOpen -uno' },
  {
    text = 'Branch ▶',
    handler = function()
      telescope.git_branches { attach_mappings = openDiffView }
    end,
  },
  {
    text = 'Commit ▶',
    handler = function()
      telescope.git_commits { attach_mappings = openDiffView }
    end,
  },
  {
    text = 'Branch "merge base" (PR like) ▶',
    handler = function()
      telescope.git_branches { attach_mappings = openDiffViewMB }
    end,
  },
}

M.git_menu = { --{{{
  {
    text = ' Commit',
    handler = function()
      require('diffview').close()
      vim.cmd ':terminal git commit'
      vim.cmd ':startinsert'
    end,
  },
  {
    text = ' Amend',
    cmd = '!git commit --amend --no-edit',
    silent = true,
  },
  -- {
  --   text = ' Cached',
  --   command = 'git diff --cached',
  -- },
  {
    text = ' File history',
    handler = telescope.git_bcommits,
  },
  {
    text = ' Line history',
    handler = package.loaded.snacks.picker.git_log_line,
  },
  {
    text = ' Reset file',
    cmd = '!git reset HEAD "%"',
  },
  {
    text = ' Checkout branch',
    handler = telescope.git_branches,
  },
  {
    text = ' Stash changes ▶',
    options = {
      {
        text = ' Push',
        handler = function()
          vim.ui.input({
            prompt = 'Stash message: ',
          }, function(input)
            vim.cmd('!git stash push -m "' .. input .. '"')
          end)
        end,
      },
      { text = '󰋺 Apply', handler = telescope.git_stash },
    },
  },
} -- }}}

M.main_menu = {
  {
    text = ' Git ▶',
    options = M.git_menu,
  },
  {
    text = ' DiffView ▶',
    options = M.git_compare_what,
  },
  { text = ' Runnables ▶', cmd = 'OverseerRun' },
  { text = ' Silicon', cmd = "'<,'> Silicon" },
  { text = ' Copy diff', cmd = '!git diff "%" | wl-copy'},
  { text = ' Send to cra', cmd = '!scp "%" cra:/tmp' },
}

return M
```

