local you_are_an_idiot = {}

---@class InitialWinConfig
---@field moving boolean Whether or not the window should be moving around
---@field x number | "mid" | "rand" The x position of the window. Set to "mid" for the center, or set to "rand" a random position.
---@field y number | "mid" | "rand" The y position of the window. Set to "mid" for the center, or set to "rand" a random position.

---@class IdiotConfig
---@field window? vim.api.keyset.win_config Options that will be passed into vim.api.nvim_open_win()
---@field resize_window_to_fit? boolean If true, automatically sets the height and width to the smallest size that fits the text.
---@field text? string | string[] Text that is displayed in the window.
---@field flash_interval? number How often the window should flash. Set to 0 to prevent flashing (this is the default settings because this is probably a epilepsy hazard).
---@field focus_cursor? boolean Should the cursor be brought into the floating window by default
---@field is_scratch? boolean Should the buffers created by the floating windows be a "scratch" buffer (i.e. can `:quit` exit the window without an exclamation mark).
---@field min_velocity? number Maximum velocity of the floating windows
---@field max_velocity? number Minimum velocity of the floating windows
---@field reproduce_count? number How many more windows should open when one of the windows is close.
---@field initial? InitialWinConfig[] Configuration for each of the initial windows. Must have at least 1.
---@field delta_time? number Time between each redraw of the screen.

local options = {
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

---@class IdiotState
---@field windows IdiotWindow[]
---@field augroup number
---@field flash_timer uv_timer_t
---@field timer uv_timer_t

---@type IdiotState?
local state = nil

-- Starts the "virus".
---@param override IdiotConfig? Override default options
function you_are_an_idiot.start(override)
    if you_are_an_idiot.is_running() then
        error("YouAreAnIdiot is already running! Enjoy!")
    end

    override = override or {}
    local opts = vim.tbl_deep_extend("keep", override, options)

    local window = require("you-are-an-idiot.window")

    local text
    if type(opts.text) == "table" then
        text = opts.text
    else
        text = { opts.text }
    end

    ---@cast text string[]

    local window_width
    local window_height
    if opts.resize_window_to_fit then
        window_height = #text
        window_width = 0
        for _, str in ipairs(text) do
            window_width = math.max(window_width, #str)
        end
    else
        window_height = opts.window.height
        window_width = opts.window.width
    end

    ---@type IdiotWindow[]
    local windows = {}

    local augroup = vim.api.nvim_create_augroup("idiot", {})
    local function new_window(x, y, rand_dir)
        local win_opts = vim.tbl_deep_extend("force", opts.window, {
            width=window_width,
            height=window_height,
            col=x,
            row=y,
        }) --[[@as vim.api.keyset.win_config]]

        local win = window.new(vim.deepcopy(text, true), opts.focus_cursor, opts.is_scratch, win_opts)

        if rand_dir then
            local magnitude = opts.min_velocity + math.random() * (opts.max_velocity - opts.min_velocity)
            local angle = math.random() * 2 * math.pi
            win.vx = math.cos(angle) * magnitude
            win.vy = math.sin(angle) * magnitude
        end

        local auto_id
        auto_id = vim.api.nvim_create_autocmd("WinClosed", {
            group = augroup,
            pattern = tostring(win.win),
            callback = function()
                for _ = 1, opts.reproduce_count do
                    table.insert(windows, new_window(win.x, win.y, true))
                end

                for i, v in ipairs(windows) do
                    if v == win then
                        table.remove(windows, i)
                        break
                    end
                end

                vim.api.nvim_del_autocmd(auto_id)
            end,
        })

        return win
    end

    local max_width = vim.o.columns - window_width
    local max_height = vim.o.lines - window_height - 1

    if opts.window.border then
        max_width = max_width - 2
        max_height = max_height - 2
    end


    for _, conf in ipairs(opts.initial) do
        local x = (conf.x == "mid" and math.floor(max_width/2))
            or (conf.x == "rand" and math.random(0, max_width))
            or conf.x

        local y = (conf.y == "mid" and math.floor(max_height/2))
            or (conf.y == "rand" and math.random(0, max_height))
            or conf.y

        table.insert(windows, new_window(x, y, conf.moving))
    end

    local flash_timer
    if opts.flash_interval ~= 0 then
        local regular_ns = vim.api.nvim_create_namespace("regular")
        local inverse_ns = vim.api.nvim_create_namespace("inverse")


        flash_timer = vim.uv.new_timer()
        flash_timer:start(0, opts.flash_interval * 1000, vim.schedule_wrap(function()
            local normal = vim.api.nvim_get_hl(0, {name = "Normal"})

            vim.api.nvim_set_hl(regular_ns, "Normal", {bg = normal.bg, fg = normal.fg})
            vim.api.nvim_set_hl(regular_ns, "FloatBorder", {bg = normal.bg})

            vim.api.nvim_set_hl(inverse_ns, "Normal", {bg = normal.fg, fg = normal.bg})
            vim.api.nvim_set_hl(regular_ns, "FloatBorder", {bg = normal.fg, fg = normal.bg})

            for _, win in ipairs(windows) do
                local ns = win.inverted and regular_ns or inverse_ns

                win.inverted = not win.inverted
                vim.api.nvim_win_set_hl_ns(win.win, ns)
            end
        end))
    end



    local timer = vim.uv.new_timer()
    timer:start(0, opts.delta_time * 1000, vim.schedule_wrap(function()
        for _, win in ipairs(windows) do
            win:update(opts.delta_time)

        end
        vim.cmd("redraw")
    end))

    state = {
        windows = windows,
        timer = timer,
        flash_timer = flash_timer,
        augroup = augroup,
    }
end

you_are_an_idiot.run = you_are_an_idiot.start

-- Stops the virus.
function you_are_an_idiot.stop()
    if not you_are_an_idiot.is_running() then
        error("YouAreAnIdiot is not running yet! No need to abort!")
    end

    local old_state = state
    state = nil

    if old_state.flash_timer then
        old_state.flash_timer:close()
    end

    local augroup = old_state.augroup
    old_state.timer:close(vim.schedule_wrap(function()
        local autocmds = vim.api.nvim_get_autocmds({group = augroup})
        for _, autocmd in ipairs(autocmds) do
            vim.api.nvim_del_autocmd(autocmd.id)
        end
        for _, win in ipairs(old_state.windows) do
            vim.api.nvim_win_close(win.win, true)
            vim.api.nvim_buf_delete(win.buf, {force = true})
        end
    end))
end

you_are_an_idiot.abort = you_are_an_idiot.stop

function you_are_an_idiot.toggle()
    if you_are_an_idiot.is_running() then
        you_are_an_idiot.stop()
    else
        you_are_an_idiot.start()
    end
end

-- Checks if the "virus" is running.
--- @return boolean
function you_are_an_idiot.is_running()
    return not not state
end

---@return IdiotState? state State of the "virus". Returns nil if it isn't running.
function you_are_an_idiot.current_state()
    return state
end

-- Use this to modify the default options.
---@param opts IdiotConfig
function you_are_an_idiot.setup(opts)
    options = vim.tbl_deep_extend("force", options, opts)
end

return you_are_an_idiot
