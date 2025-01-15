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
    flashing = true,
    reproduce_count = 10,
})
```

## Example
```lua
local idiot = require("you-are-an-idiot")
vim.api.nvim_create_user_command("ToggleIdiot", function()
    if idiot.is_running() then
        idiot.abort()
    else
        idiot.run()
    end
end, {desc = "Toggles YouAreAnIdiot"})
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
        border="single",
        width = 17,
        height = 1,
    },
    text = "You are an idiot!",
    flashing = false,
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
