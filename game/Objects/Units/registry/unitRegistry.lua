--- Registry for resolving unit type identifiers to concrete classes.

local UnitRegistry = {}

local UNIT_CLASS_BY_TYPE = {
	Barbarian = require("Objects.Units.types.barbarian"),
	Knight = require("Objects.Units.types.knight"),
	Archer = require("Objects.Units.types.archer"),
	Mage = require("Objects.Units.types.mage"),
}

--- Returns the unit class for the given type id.
---@param unitType string | nil
---@return table | nil
function UnitRegistry.GetByType(unitType)
	if type(unitType) ~= "string" or unitType == "" then
		return nil
	end
	return UNIT_CLASS_BY_TYPE[unitType]
end

return UnitRegistry
