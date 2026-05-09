--- Base Object class for all game objects.

local DEFAULTS = {
	Name = "Object",
	Position = { X = 0, Y = 0 },
}

---@class Object
---@field Name string
---@field Position {X: number, Y: number}
local Object = {}
Object.__index = Object

--- Creates a new Object.
---@generic T : Object
---@param self T
---@param Name string | nil
---@return T
function Object:new(Name)
	local newObj = {}
	setmetatable(newObj, self)
	newObj.Name = Name or DEFAULTS.Name
	newObj.Position = { X = DEFAULTS.Position.X, Y = DEFAULTS.Position.Y }
	return newObj
end

--- Sets the current location of the Object.
---@param x number
---@param y number
function Object:Place(x, y)
	if x then
		self.Position.X = x
	end
	if y then
		self.Position.Y = y
	end
end

return Object
