--- SpawningStructure class for structures that periodically spawn units.

local Structure = require("Objects.Structures.base.structure")
local MathUtils = require("src.mathUtils")

local DEFAULTS = {
	SpawnRate = 5,
	SpawnTimer = 0,
}

--- Resolves the forward direction for the spawning structure.
---@param entities WorldEntities | nil
---@param structure SpawningStructure
---@return number, number
local function resolveForwardDirection(entities, structure)
	local fallbackX = (structure.Team == "enemy") and -1 or 1
	local fallbackY = 0

	if not entities or not entities.Map then
		return fallbackX, fallbackY
	end

	---@type any
	local map = entities.Map
	local path = nil

	if structure.PathId and type(map["GetPathById"]) == "function" then
		path = map:GetPathById(structure.PathId)
	end

	if not path and type(map["GetClosestPathForTeam"]) == "function" then
		path = map:GetClosestPathForTeam(structure.Position.X, structure.Position.Y, structure.Team)
	end

	if not path or type(path.GetClosestWaypointIndex) ~= "function" or type(path.GetWaypoint) ~= "function" or type(path.GetWaypoints) ~= "function" then
		return fallbackX, fallbackY
	end

	local waypoints = path:GetWaypoints()
	if not waypoints or #waypoints == 0 then
		return fallbackX, fallbackY
	end

	local nearestIndex = path:GetClosestWaypointIndex(structure.Position.X, structure.Position.Y)
	if not nearestIndex then
		return fallbackX, fallbackY
	end

	nearestIndex = MathUtils.Clamp(nearestIndex, 1, #waypoints)
	local preferredStep = (structure.Team == "enemy") and -1 or 1
	local targetIndex = MathUtils.Clamp(nearestIndex + preferredStep, 1, #waypoints)
	if targetIndex == nearestIndex then
		targetIndex = MathUtils.Clamp(nearestIndex - preferredStep, 1, #waypoints)
	end

	local targetWaypoint = path:GetWaypoint(targetIndex)
	if not targetWaypoint then
		targetWaypoint = path:GetWaypoint(nearestIndex)
	end
	if not targetWaypoint then
		return fallbackX, fallbackY
	end

	local directionX = targetWaypoint.X - structure.Position.X
	local directionY = targetWaypoint.Y - structure.Position.Y
	local normalizedX, normalizedY = MathUtils.Normalize(directionX, directionY)
	if normalizedX == 0 and normalizedY == 0 then
		return fallbackX, fallbackY
	end

	return normalizedX, normalizedY
end

--- Builds the spawn candidates for the spawning structure.
---@param structure SpawningStructure
---@param unitRadius number
---@param forwardX number
---@param forwardY number
---@return table
local function buildSpawnCandidates(structure, unitRadius, forwardX, forwardY)
	local spawnOffset = (structure.Size / 2) + unitRadius + 1
	local lateralAX, lateralAY = -forwardY, forwardX
	local lateralBX, lateralBY = forwardY, -forwardX
	local backX, backY = -forwardX, -forwardY
	local centerX = structure.Position.X
	local centerY = structure.Position.Y
	local sideOffset = spawnOffset * 0.9
	local diagonalOffset = spawnOffset * 0.72
	local wideOffset = spawnOffset * 1.25

	return {
		{ X = centerX + (forwardX * spawnOffset), Y = centerY + (forwardY * spawnOffset) },
		{
			X = centerX + ((forwardX + lateralAX * 0.65) * diagonalOffset),
			Y = centerY + ((forwardY + lateralAY * 0.65) * diagonalOffset),
		},
		{
			X = centerX + ((forwardX + lateralBX * 0.65) * diagonalOffset),
			Y = centerY + ((forwardY + lateralBY * 0.65) * diagonalOffset),
		},
		{ X = centerX + (lateralAX * sideOffset), Y = centerY + (lateralAY * sideOffset) },
		{ X = centerX + (lateralBX * sideOffset), Y = centerY + (lateralBY * sideOffset) },
		{
			X = centerX + ((backX + lateralAX * 0.45) * diagonalOffset),
			Y = centerY + ((backY + lateralAY * 0.45) * diagonalOffset),
		},
		{
			X = centerX + ((backX + lateralBX * 0.45) * diagonalOffset),
			Y = centerY + ((backY + lateralBY * 0.45) * diagonalOffset),
		},
		{ X = centerX + (forwardX * wideOffset), Y = centerY + (forwardY * wideOffset) },
	}
end

--- Finds a suitable spawn position for a unit.
---@param entities WorldEntities | nil
---@param structure SpawningStructure
---@param unitRadius number
---@return number | nil, number | nil
local function findSpawnPosition(entities, structure, unitRadius)
	local forwardX, forwardY = resolveForwardDirection(entities, structure)
	local candidates = buildSpawnCandidates(structure, unitRadius, forwardX, forwardY)

	for _, candidate in ipairs(candidates) do
		local canSpawn = true
		if entities and type(entities.CanSpawnUnitAt) == "function" then
			canSpawn = entities:CanSpawnUnitAt(candidate.X, candidate.Y, unitRadius)
		end
		if canSpawn then
			return candidate.X, candidate.Y
		end
	end

	return nil, nil
end

---@class SpawningStructure : Structure
---@field SpawnRate number
---@field SpawnTimer number
---@field UnitClass table | nil
---@field IsSpawningStructure boolean
local SpawningStructure = {}
SpawningStructure.__index = SpawningStructure

setmetatable(SpawningStructure, { __index = Structure })

--- Creates a new spawning structure.
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

--- Spawns a unit if the spawn timer has reached the spawn rate.
---@param dt number
---@param entities WorldEntities | nil
---@return Unit | nil
function SpawningStructure:SpawnUnit(dt, entities)
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
		spawnedUnit.PathId = self.PathId
		spawnedUnit.PathWaypointIndex = nil
		local spawnX, spawnY = findSpawnPosition(entities, self, spawnedUnit.Size)
		if not spawnX or not spawnY then
			return nil
		end

		spawnedUnit:Place({ X = spawnX, Y = spawnY })
		return spawnedUnit
	end
	return nil
end

return SpawningStructure
