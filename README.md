# you-are-an-idiot.nvim
A simple recreation of the YouAreAnIdiot trojan (see [here](https://www.youtube.com/watch?v=ZcwxToKjJhE)) in NeoVim.
> You are an idiot, ha ha ha ha ha ha ha, ha ha ha ha ha!

![demo image because video broke](https://i.imgur.com/ErQHOry.png)

## Why would I want this... "trojan" in my NeoVim config?
No idea lol, its your configuration not mine.

# Usage

```lua
-- Starts the "trojan"
require("you-are-an-idiot").run()

-- Stops the "trojan"
require("you-are-an-idiot").abort()
```

Override configuration:
```lua
require("you-are-an-idiot").run({
    flash_interval = 0.25,
    text = {"RTFM", "(Do it now!)"}
})
```

## Example
```lua
vim.api.nvim_create_user_command("ToggleIdiot", require("you-are-an-idiot").toggle, {desc = "Toggles YouAreAnIdiot"})
```

# Installation

Lazy.nvim:
```lua
return {
    "GitMarkedDan/you-are-an-idiot.nvim",
    -- Add your own custom configuration here:
    -- opts = { }
}
```

# Configuration

Default configuration:
```lua
{
    window = {
        relative="editor",
        style="minimal",
        border="single",
        width = 17,
        height = 1,
    },
    resize_window_to_fit = true,
    text = "You are an idiot!",
    flash_interval = 0,
    focus_cursor = true,
    is_scratch = true,
    min_velocity = 20,
    max_velocity = 30,
    reproduce_count = 5,
    initial = {
        {
            x = "mid",
            y = "mid",
            moving = false,
        },
    },
    delta_time = 0.05,
}
```
