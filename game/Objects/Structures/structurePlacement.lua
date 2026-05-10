local Structure = require("Objects.Structures.structure")

local STRUCTURE_BY_TYPE = {
	TownHall  = { Health = 500, Armor = 20, Size = 70, SpawnRate = 0, Costs = { Gold = 0, Metal = 0, Aether = 0 } },
	Barbarian = { Health = 220, Armor = 12, Size = 28, SpawnRate = 2, Costs = { Gold = 30, Metal = 20, Aether = 0 } },
	Knight    = { Health = 280, Armor = 18, Size = 32, SpawnRate = 3, Costs = { Gold = 50, Metal = 40, Aether = 0 } },
	Archer    = { Health = 180, Armor = 8, Size = 24, SpawnRate = 1.5, Costs = { Gold = 25, Metal = 10, Aether = 5 } },
	Mage      = { Health = 160, Armor = 6, Size = 26, SpawnRate = 1.2, Costs = { Gold = 20, Metal = 5, Aether = 15 } },
}

local StructurePlacement = {}

--- Places the currently selected structure type at the given position.
--- Returns nil if the type is unknown or the player cannot afford it.
---@param selectedStructureType string | nil
---@param resources Resources
---@param x number
---@param y number
---@return Structure | nil The placed structure if successful, otherwise nil.
function StructurePlacement.PlaceSelectedStructure(selectedStructureType, resources, x, y)
	if not selectedStructureType then
		return nil
	end

	local selected = STRUCTURE_BY_TYPE[selectedStructureType]
	if not selected then
		return nil
	end

	if not resources:Spend(selected.Costs) then
		return nil
	end

	local structure = Structure:new(
		selectedStructureType,
		selected.Health,
		selected.Armor,
		selected.Size,
		selected.SpawnRate,
		selected.Costs
	)

	structure:Place({ X = x, Y = y })
	return structure
end

return StructurePlacement
