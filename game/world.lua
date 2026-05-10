--- World module — manages all active game entities.

local StructurePlacement = require("Objects.Structures.placement.structurePlacement")
local StructureRegistry = require("Objects.Structures.registry.structureRegistry")
local WorldEntities = require("src.worldEntities")

---@class World
---@field Entities WorldEntities
local World = {}
World.__index = World

---@return World
function World:new()
	return setmetatable({ Entities = WorldEntities:new() }, self)
end

--- Places a structure of the given type at the given position, if a type is selected.
---@param selectedStructureType string | nil
---@param resources Resources
---@param x number
---@param y number
---@param team "player" | "enemy"
---@return boolean placed True when structure was successfully placed.
---@return string | nil reason Failure reason code when placement fails.
function World:PlaceStructure(selectedStructureType, resources, x, y, team)
	local structureClass = StructureRegistry.GetByType(selectedStructureType)
	local structure, reason = StructurePlacement.PlaceStructure(structureClass, resources, self.Entities, x, y, team)
	if structure then
		self.Entities:AddStructure(structure)
		return true, nil
	end
	return false, reason
end

--- Updates all entities. Moves units, removes dead ones, spawns new ones from structures.
---@param dt number
function World:Update(dt)
	local units = self.Entities:GetUnits()
	local structures = self.Entities:GetStructures()

	self.Entities:RebuildSpatialIndex()

	for _, unit in ipairs(units) do
		local nextX, nextY = unit:CalculateNextPosition(self.Entities)
		unit:MoveTo(nextX, nextY)
	end

	self.Entities:RemoveDeadUnits()
	self.Entities:RebuildSpatialIndex()

	for _, unit in ipairs(units) do
		unit:UpdateCombat(dt, self.Entities)
	end
	for _, structure in ipairs(structures) do
		structure:UpdateCombat(dt, self.Entities)
	end
	self.Entities:UpdateProjectiles(dt)
	self.Entities:RemoveDeadUnits()

	for _, structure in ipairs(structures) do
		local spawnedUnit = structure:SpawnUnit(dt)
		if spawnedUnit then
			self.Entities:AddUnit(spawnedUnit)
		end
	end

	self.Entities:RemoveDeadStructures()
end

--- Draws all entities.
function World:Draw()
	for _, unit in ipairs(self.Entities:GetUnits()) do
		unit:Draw()
	end
	for _, projectile in ipairs(self.Entities:GetProjectiles()) do
		projectile:Draw()
	end
	for _, structure in ipairs(self.Entities:GetStructures()) do
		structure:Draw()
	end
end

return World
