--- Structure class representing a game structure with health, armor, and size attributes.

local Object = require("BaseClasses.object")
local DEFAULTS = {
	Health = 100,
	Armor = 5,
	Size = 10,
	SpawnRate = 5,
	SpawnTimer = 0,
	Costs = { Gold = 0, Metal = 0, Aether = 0 },
}

---@class Structure : Object
---@field Health number
---@field Armor number
---@field Size number
---@field SpawnRate number
---@field SpawnTimer number
---@field Costs table
---@field UnitClass table | nil
---@field Team "player" | "enemy"
local Structure = {}
Structure.__index = Structure

setmetatable(Structure, { __index = Object })

---Creates a new Structure.
---@generic T : Structure
---@param self T
---@param Name string | nil
---@param Health number | nil
---@param Armor number | nil
---@param Size number | nil
---@param SpawnRate number | nil
---@param Costs table | nil
---@param Team "player" | "enemy" | nil
---@return T
function Structure:new(Name, Health, Armor, Size, SpawnRate, Costs, Team)
	local newStructure = Object.new(self, Name)
	newStructure.Health = Health or DEFAULTS.Health
	newStructure.Armor = Armor or DEFAULTS.Armor
	newStructure.Size = Size or DEFAULTS.Size
	newStructure.SpawnRate = SpawnRate or DEFAULTS.SpawnRate
	newStructure.SpawnTimer = DEFAULTS.SpawnTimer
	newStructure.Costs = Costs or DEFAULTS.Costs
	newStructure.Team = Team or "player"
	return newStructure
end

--- Draws the structure at its current position.
function Structure:Draw()
	if self.Team == "enemy" then
		love.graphics.setColor(0.8, 0.3, 0.2)
	else
		love.graphics.setColor(0.5, 0.5, 0.5)
	end
	love.graphics.rectangle("fill", self.Position.X - self.Size / 2, self.Position.Y - self.Size / 2, self.Size,
		self.Size)
	love.graphics.setColor(1, 1, 1)
end

--- Draws a unit at the structure's position when dt passed spawn rate, simulating a spawn.
---@param dt number The delta time since the last update, used to manage spawn timing.
---@return Unit | nil The spawned unit if the spawn condition is met, otherwise nil.
function Structure:SpawnUnit(dt)
	if self.SpawnRate <= 0 then
		return nil
	end
	if not self.UnitClass then
		return nil
	end

	self.SpawnTimer = self.SpawnTimer + dt
	if self.SpawnTimer >= self.SpawnRate then
		self.SpawnTimer = self.SpawnTimer - self.SpawnRate
		local spawnedUnit = self.UnitClass:new(self.Name .. "_Unit")
		spawnedUnit.Team = self.Team
		local spawnOffset = (self.Size / 2) + spawnedUnit.Size + 1
		local spawnDirection = (self.Team == "enemy") and -1 or 1
		spawnedUnit:Place({ X = self.Position.X + (spawnOffset * spawnDirection), Y = self.Position.Y })
		return spawnedUnit
	end
	return nil
end

return Structure
