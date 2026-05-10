--- World module — manages all active game entities.

local StructurePlacement = require("Objects.Structures.placement.structurePlacement")
local StructureRegistry = require("Objects.Structures.registry.structureRegistry")
local WorldEntities = require("src.worldEntities")

---@class World
---@field Units table
---@field Structures table
---@field Entities WorldEntities
local World = {}
World.__index = World

---@return World
function World:new()
	local units = {}
	local structures = {}
	return setmetatable({ Units = units, Structures = structures, Entities = WorldEntities:new(units, structures) }, self)
end

---@param unit Unit
function World:AddUnit(unit)
	table.insert(self.Units, unit)
end

---@param structure Structure
function World:AddStructure(structure)
	table.insert(self.Structures, structure)
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
		self:AddStructure(structure)
		return true, nil
	end
	return false, reason
end

--- Updates all entities. Moves units, removes dead ones, spawns new ones from structures.
---@param dt number
function World:Update(dt)
	self.Entities:RebuildSpatialIndex()

	for _, unit in ipairs(self.Units) do
		local nextX, nextY = unit:CalculateNextPosition(self.Entities)
		unit:MoveTo(nextX, nextY)
	end

	self.Entities:RemoveDeadUnits()
	self.Entities:RebuildSpatialIndex()

	for _, unit in ipairs(self.Units) do
		unit:UpdateCombat(dt, self.Entities)
	end
	self.Entities:RemoveDeadUnits()

	for _, structure in ipairs(self.Structures) do
		local spawnedUnit = structure:SpawnUnit(dt)
		if spawnedUnit then
			self:AddUnit(spawnedUnit)
		end
	end

	self.Entities:RemoveDeadStructures()
end

--- Draws all entities.
function World:Draw()
	for _, unit in ipairs(self.Units) do
		unit:Draw()
	end
	for _, structure in ipairs(self.Structures) do
		structure:Draw()
	end
end

return World
