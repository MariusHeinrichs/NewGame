--- Registry for resolving structure type identifiers to concrete classes.

local StructureRegistry = {}

local STRUCTURE_CLASS_BY_TYPE = {
	TownHall      = require("Objects.Structures.DefenseStructures.townhall"),
	ArcherTower   = require("Objects.Structures.DefenseStructures.archertower"),
	MageTower     = require("Objects.Structures.DefenseStructures.magetower"),
	Barracks      = require("Objects.Structures.SpawnStructures.barracks"),
	BarbarianCamp = require("Objects.Structures.SpawnStructures.barbariancamp"),
	ArcherCamp    = require("Objects.Structures.SpawnStructures.archercamp"),
	Library       = require("Objects.Structures.SpawnStructures.library"),
}


--- Returns the structure class for the given type id.
---@param structureType string | nil
---@return table | nil
function StructureRegistry.GetByType(structureType)
	if type(structureType) ~= "string" or structureType == "" then
		return nil
	end
	return STRUCTURE_CLASS_BY_TYPE[structureType]
end

return StructureRegistry
