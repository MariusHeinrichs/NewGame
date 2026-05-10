--- World module — manages all active game entities.

local StructurePlacement = require("Objects.Structures.placement.structurePlacement")
local StructureRegistry = require("Objects.Structures.registry.structureRegistry")
local Collisions = require("src.collisions")

---@class World
---@field Units table
---@field Structures table
local World = {}
World.__index = World

---@return World
function World:new()
	return setmetatable({ Units = {}, Structures = {} }, self)
end

---@param unit Unit
function World:AddUnit(unit)
	table.insert(self.Units, unit)
end

---@param structure Structure
function World:AddStructure(structure)
	table.insert(self.Structures, structure)
end

--- Checks if a unit would collide with another entity at a target position.
---@param movingUnit Unit
---@param nextX number
---@param nextY number
---@return boolean
function World:WillUnitCollide(movingUnit, nextX, nextY)
	for _, structure in ipairs(self.Structures) do
		local rx, ry, rw, rh = Collisions.GetRectBounds(structure.Position.X, structure.Position.Y, structure.Size)
		if Collisions.CircleIntersectsRect(nextX, nextY, movingUnit.Size, rx, ry, rw, rh) then
			return true
		end
	end

	for _, otherUnit in ipairs(self.Units) do
		if otherUnit ~= movingUnit and Collisions.CirclesOverlap(nextX, nextY, movingUnit.Size, otherUnit.Position.X, otherUnit.Position.Y,
				otherUnit.Size) then
			return true
		end
	end

	return false
end

--- Places a structure of the given type at the given position, if a type is selected.
---@param selectedStructureType string | nil
---@param resources Resources
---@param x number
---@param y number
function World:PlaceStructure(selectedStructureType, resources, x, y)
	local structureClass = StructureRegistry.GetByType(selectedStructureType)
	local structure = StructurePlacement.PlaceStructure(structureClass, resources, self.Units,
		self.Structures, x, y)
	if structure then
		self:AddStructure(structure)
	end
end

--- Updates all entities. Moves units, removes dead ones, spawns new ones from structures.
---@param dt number
function World:Update(dt)
	for i = #self.Units, 1, -1 do
		local unit = self.Units[i]
		local nextX, nextY = unit:GetNextPosition("right")
		if not self:WillUnitCollide(unit, nextX, nextY) then
			unit:MoveTo(nextX, nextY)
		else
			unit:UpdateHealthFromWindowBounds()
		end
		if unit.Health <= 0 then
			table.remove(self.Units, i)
		end
	end

	for _, structure in ipairs(self.Structures) do
		local spawnedUnit = structure:SpawnUnit(dt)
		if spawnedUnit then
			self:AddUnit(spawnedUnit)
		end
	end
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
