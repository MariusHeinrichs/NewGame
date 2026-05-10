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

--- Registers or overrides a unit class for the given type id.
---@param unitType string
---@param unitClass table
---@return boolean True if registration succeeded, otherwise false.
function UnitRegistry.Register(unitType, unitClass)
	if type(unitType) ~= "string" or unitType == "" then
		return false
	end
	if type(unitClass) ~= "table" or type(unitClass.new) ~= "function" then
		return false
	end
	UNIT_CLASS_BY_TYPE[unitType] = unitClass
	return true
end

return UnitRegistry
