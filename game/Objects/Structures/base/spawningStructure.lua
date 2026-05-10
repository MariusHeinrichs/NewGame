--- SpawningStructure class for structures that periodically spawn units.

local Structure = require("Objects.Structures.base.structure")

local DEFAULTS = {
	SpawnRate = 5,
	SpawnTimer = 0,
}

---@class SpawningStructure : Structure
---@field SpawnRate number
---@field SpawnTimer number
---@field UnitClass table | nil
local SpawningStructure = {}
SpawningStructure.__index = SpawningStructure

setmetatable(SpawningStructure, { __index = Structure })

---@generic T : SpawningStructure
---@param self T
---@param Name string | nil
---@param Health number | nil
---@param Armor number | nil
---@param Size number | nil
---@param SpawnRate number | nil
---@param UnitClass table | nil
---@param Costs table | nil
---@param IncomeBonusGold number | nil
---@param IncomeBonusMetal number | nil
---@param SpawnTimer number | nil
---@param Team "player" | "enemy" | nil
---@return T
function SpawningStructure:new(Name, Health, Armor, Size, SpawnRate, UnitClass, Costs, IncomeBonusGold, IncomeBonusMetal, SpawnTimer, Team)
	local newStructure = Structure.new(self, Name, Health, Armor, Size, Costs, IncomeBonusGold, IncomeBonusMetal,
		Team)
	newStructure.SpawnRate = SpawnRate or DEFAULTS.SpawnRate
	newStructure.SpawnTimer = SpawnTimer or DEFAULTS.SpawnTimer
	newStructure.UnitClass = UnitClass
	return newStructure
end

---@param dt number
---@return Unit | nil
function SpawningStructure:SpawnUnit(dt)
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

return SpawningStructure