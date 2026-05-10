--- Text class for reusable UI text rendering.

local DEFAULTS = {
	Content = "",
	Position = { X = 0, Y = 0 },
	Width = 0,
	Align = "left",
	Color = { 1, 1, 1, 1 },
}

---@class Text
---@field Content string
---@field Position {X: number, Y: number}
---@field Width number
---@field Align "left" | "center" | "right" | "justify"
---@field Color number[]
local Text = {}
Text.__index = Text

--- Creates a new Text object.
---@generic T : Text
---@param content string | nil
---@param position {X: number, Y: number} | nil
---@param width number | nil
---@param align "left" | "center" | "right" | "justify" | nil
---@param color number[] | nil
---@return T
function Text:new(content, position, width, align, color)
	local text = setmetatable({}, self)
	text.Content = content or DEFAULTS.Content
	text.Position = position or DEFAULTS.Position
	text.Width = width or DEFAULTS.Width
	text.Align = align or DEFAULTS.Align
	text.Color = color or DEFAULTS.Color
	return text
end

--- Draws the text using its current properties.
function Text:Draw()
	love.graphics.setColor(self.Color)
	love.graphics.printf(self.Content, self.Position.X, self.Position.Y, self.Width, self.Align)
	love.graphics.setColor(1, 1, 1, 1)
end

return Text
