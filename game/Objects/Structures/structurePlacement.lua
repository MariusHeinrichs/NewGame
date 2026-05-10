local Structure = require("Objects.Structures.structure")

local STRUCTURE_BY_TYPE = {
	Barbarian = { Health = 220, Armor = 12, Size = 28, SpawnRate = 2 },
	Knight = { Health = 280, Armor = 18, Size = 32, SpawnRate = 3 },
	Archer = { Health = 180, Armor = 8, Size = 24, SpawnRate = 1.5 },
	Mage = { Health = 160, Armor = 6, Size = 26, SpawnRate = 1.2 },
}

local StructurePlacement = {}

--- Places the currently selected structure type at the given position.
---@param selectedStructureType string | nil
---@param x number
---@param y number
---@return Structure | nil The placed structure if successful, otherwise nil.
function StructurePlacement.PlaceSelectedStructure(selectedStructureType, x, y)
	if not selectedStructureType then
		return nil
	end

	local selected = STRUCTURE_BY_TYPE[selectedStructureType]
	if not selected then
		return nil
	end

	local structure = Structure:new(
		selectedStructureType,
		selected.Health,
		selected.Armor,
		selected.Size,
		selected.SpawnRate
	)

	structure:Place({ X = x, Y = y })
	return structure
end

return StructurePlacement
