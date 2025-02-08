---@class IdiotWindow
---@field x number Current x-position of the window
---@field y number Current x-position of the window
---@field width number Width of the window
---@field height number Height of the window
---@field vx number x velocity of the window
---@field vy number y velocity of the window
---@field win number Window ID
---@field buf number Buffer ID of window
---@field inverted boolean Whether the colorscheme of the window is inverted
---@field bordered boolean Whether the window has a border
---@field text string Text in the buffer (updated with :update())
local window = {}

local window_constructer = {}

---@param text string | string[]
---@param focus_cursor boolean
---@param is_scratch boolean
---@param win_opts vim.api.keyset.win_config
---@return IdiotWindow
function window_constructer.new(text, focus_cursor, is_scratch, win_opts)
    local data = {
        x = win_opts.col,
        y = win_opts.row,
        width = win_opts.width,
        height = win_opts.height,
        vx = 0,
        vy = 0,
        inverted = false,
        bordered = not not win_opts.border,
        text = text,
    }

    data.buf = vim.api.nvim_create_buf(false, is_scratch)
    data.win = vim.api.nvim_open_win(data.buf, focus_cursor, win_opts)

    if type(text) == "string" then
        text = {text}
    end

    for i, str in ipairs(text) do
        if #str < data.width then
            local diff = data.width - #str
            text[i] = string.rep(" ", math.floor(diff/2)) .. str
        elseif #str > data.width then
            local midpt = math.floor(#str/2)
            text[i] = string.sub(str, midpt-math.floor(data.width), midpt+math.ceil(data.width))
        end
    end

    local line = math.floor((data.height + 1 - #text)/2)
    vim.api.nvim_buf_set_lines(data.buf, line, line+#text, false, text)

    vim.bo[data.buf].modifiable = false
    vim.bo[data.buf].filetype = "idiot"

    return setmetatable(data, {__index = window})
end

---Updates the position of the window
---@param dt number
function window:update(dt)
    local max_width = vim.o.columns - self.width
    local max_height = vim.o.lines - self.height - 1

    if self.bordered then
        max_height = max_height - 2
        max_width = max_width - 2
    end

    local new_x = self.x + self.vx * dt
    local new_y = self.y + self.vy * dt

    if new_x > max_width then
        self.x = max_width
        self.vx = -self.vx
    elseif new_x < 0 then
        self.x = 0.4
        self.vx = -self.vx
    else
        self.x = new_x
    end

    if new_y > max_height then
        self.y = max_height
        self.vy = -self.vy
    elseif new_y < 0 then
        self.y = 0.4
        self.vy = -self.vy
    else
        self.y = new_y
    end

    local win_config = {
        relative="editor",
        col = self.x,
        row = self.y,
    }

    vim.api.nvim_win_set_config(self.win, win_config)
end

return window_constructer
