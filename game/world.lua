--- World module — manages all active game entities.

local StructurePlacement = require("Objects.Structures.structurePlacement")

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

--- Places a structure of the given type at the given position, if a type is selected.
---@param selectedStructureType string | nil
---@param resources Resources
---@param x number
---@param y number
function World:PlaceStructure(selectedStructureType, resources, x, y)
	local structure = StructurePlacement.PlaceSelectedStructure(selectedStructureType, resources, x, y)
	if structure then
		self:AddStructure(structure)
	end
end

--- Updates all entities. Moves units, removes dead ones, spawns new ones from structures.
---@param dt number
function World:Update(dt)
	for i = #self.Units, 1, -1 do
		local unit = self.Units[i]
		unit:Move("right")
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
