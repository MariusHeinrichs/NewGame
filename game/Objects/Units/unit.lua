local Object = require("BaseClasses.object")

local DEFAULTS = {
	Health = 100,
	Damage = 10,
	Armor = 5,
	Speed = 2,
	Size = 10,
}

---@class Unit : Object
---@field Health number
---@field Damage number
---@field Armor number
---@field Speed number
---@field Size number
local Unit = {}
Unit.__index = Unit

setmetatable(Unit, { __index = Object })

---Creates a new Unit.
---@param Name string | nil
---@param Health number | nil
---@param Damage number | nil
---@param Armor number | nil
---@param Speed number | nil
---@param Size number | nil
---@return Unit
function Unit:new(Name, Health, Damage, Armor, Speed, Size)
	local newUnit = Object.new(self, Name)
	newUnit.Health = Health or DEFAULTS.Health
	newUnit.Damage = Damage or DEFAULTS.Damage
	newUnit.Armor = Armor or DEFAULTS.Armor
	newUnit.Speed = Speed or DEFAULTS.Speed
	newUnit.Size = Size or DEFAULTS.Size
	return newUnit
end

-- Moves the unit in the specified direction, by its Speed value.
---@param direction "up" | "down" | "left" | "right"
function Unit:Move(direction)
	if direction then
		if direction == "up" then
			self.Position.Y = self.Position.Y - self.Speed
		elseif direction == "down" then
			self.Position.Y = self.Position.Y + self.Speed
		elseif direction == "left" then
			self.Position.X = self.Position.X - self.Speed
		elseif direction == "right" then
			self.Position.X = self.Position.X + self.Speed
		end
	end
end

--- Draws the unit at its current position.
function Unit:Draw()
	love.graphics.setColor(0, 1, 0)

	love.graphics.circle("fill", self.Position.X, self.Position.Y, self.Size)

	love.graphics.setColor(1, 1, 1)
end

return Unit
