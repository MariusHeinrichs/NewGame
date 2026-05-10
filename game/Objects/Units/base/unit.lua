--- Unit class representing a game unit with health, damage, armor, speed, size, range, and attack speed attributes.

local Object = require("BaseClasses.object")

local DEFAULTS = {
	Health = 100,
	Damage = 10,
	Armor = 5,
	Speed = 2,
	Size = 10,
	Range = 50,
	AttackSpeed = 1,
}

---@class Unit : Object
---@field Health number
---@field Damage number
---@field Armor number
---@field Speed number
---@field Size number
---@field Range number
---@field AttackSpeed number
local Unit = {}
Unit.__index = Unit

setmetatable(Unit, { __index = Object })

---Creates a new Unit.
---@generic T : Unit
---@param self T
---@param Name string | nil
---@param Health number | nil
---@param Damage number | nil
---@param Armor number | nil
---@param Speed number | nil
---@param Size number | nil
---@param Range number | nil
---@param AttackSpeed number | nil
---@return T
function Unit:new(Name, Health, Damage, Armor, Speed, Size, Range, AttackSpeed)
	local newUnit = Object.new(self, Name)
	newUnit.Health = Health or DEFAULTS.Health
	newUnit.Damage = Damage or DEFAULTS.Damage
	newUnit.Armor = Armor or DEFAULTS.Armor
	newUnit.Speed = Speed or DEFAULTS.Speed
	newUnit.Size = Size or DEFAULTS.Size
	newUnit.Range = Range or DEFAULTS.Range
	newUnit.AttackSpeed = AttackSpeed or DEFAULTS.AttackSpeed
	return newUnit
end

--- Returns the next position for the given direction without applying it.
---@param direction "up" | "down" | "left" | "right"
---@return number, number
function Unit:GetNextPosition(direction)
	local nextX = self.Position.X
	local nextY = self.Position.Y

	if direction == "up" then
		nextY = nextY - self.Speed
	elseif direction == "down" then
		nextY = nextY + self.Speed
	elseif direction == "left" then
		nextX = nextX - self.Speed
	elseif direction == "right" then
		nextX = nextX + self.Speed
	end

	return nextX, nextY
end

--- Moves the unit to an absolute position.
---@param x number
---@param y number
function Unit:MoveTo(x, y)
	self.Position.X = x
	self.Position.Y = y
	self:UpdateHealthFromWindowBounds()
end

--- Sets Health to 0 when the unit leaves the current window.
function Unit:UpdateHealthFromWindowBounds()
	local width, height = love.graphics.getDimensions()
	if self.Position.X < 0 or self.Position.X > width or self.Position.Y < 0 or self.Position.Y > height then
		self.Health = 0
	end
end

--- Draws the unit at its current position.
function Unit:Draw()
	love.graphics.setColor(0, 1, 0)

	love.graphics.circle("fill", self.Position.X, self.Position.Y, self.Size)

	love.graphics.setColor(1, 1, 1)
end

return Unit
