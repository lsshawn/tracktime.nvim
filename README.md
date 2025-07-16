# timetrack.nvim

A minimal neovim plugin to track time spent on a line.

## Features

- Start/stop a timer on any line.
- Time is stored in a comment on the line itself in minutes (e.g., `<!-- ⏱ 5 min -->`).
- The time is automatically accumulated.

## Installation

### lazy.nvim

```lua
{
  "lsshawn/timetrack.nvim",
  config = function()
    require("timetrack").setup({
      -- your configuration comes here
      -- or leave it empty to use the default settings
    })
  end,
}
```

## Usage

Move your cursor to a line you want to track time on and use the command or keymap.

- **Command:** `:TimeTrackToggle`
- **Default Keymap:** `<leader>tt`

The first time you use it on a line, it starts the timer and shows a live-updating clock in the command area (e.g., `▶️ Tracking: 00:00:01`). Use it again on the same line to pause the timer and write the elapsed time to the line. If you move your cursor away and toggle tracking on a new line, the timer for the previous line is stopped (without saving) and a new one begins.

## Customization

You can customize the plugin by passing options to the `setup` function.

Example configuration:

```lua
require("timetrack").setup({
  -- Change the default keymap
  keymap = "<leader>T",
})
```

To disable the default keymap, set it to `false`:

```lua
require("timetrack").setup({
  keymap = false,
})
```

You can then set your own keymap:
```lua
vim.keymap.set("n", "<leader>ts", require("timetrack").toggle, { desc = "Toggle time tracker" })
```
