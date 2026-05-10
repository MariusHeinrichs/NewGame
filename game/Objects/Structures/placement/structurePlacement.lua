local StructurePlacement = {}

--- Returns true if structureClass has the required placement shape.
---@param structureClass table
---@return boolean
local function isValidStructureClass(structureClass)
	if type(structureClass) ~= "table" then
		return false
	end
	if type(structureClass.new) ~= "function" then
		return false
	end
	if type(structureClass.Size) ~= "number" or structureClass.Size <= 0 then
		return false
	end
	if type(structureClass.Costs) ~= "table" then
		return false
	end
	return true
end

--- Checks whether a structure can be placed without overlapping existing entities.
---@param entities WorldEntities
---@param x number
---@param y number
---@param size number
---@return boolean
---@return string | nil
local function canPlaceStructureAt(entities, x, y, size)
	return entities:CanPlaceStructureAt(x, y, size)
end

--- Places a structure of the given class at the given position.
--- Returns nil if the class is unknown or the player cannot afford it or the position is invalid.
---@param structureClass table | nil
---@param resources Resources
---@param entities WorldEntities
---@param x number
---@param y number
---@param team "player" | "enemy"
---@return Structure | nil The placed structure if successful, otherwise nil.
---@return string | nil reason Failure reason code when placement fails.
function StructurePlacement.PlaceStructure(structureClass, resources, entities, x, y, team)
	if not structureClass then
		return nil, "invalid_type"
	end

	if not isValidStructureClass(structureClass) then
		return nil, "invalid_class"
	end

	if not resources or type(resources.Spend) ~= "function" then
		return nil, "invalid_resources"
	end

	local canPlace, placementReason = canPlaceStructureAt(entities, x, y, structureClass.Size)
	if not canPlace then
		return nil, placementReason
	end

	if not resources:Spend(structureClass.Costs) then
		return nil, "not_affordable"
	end

	local structure = structureClass:new()
	structure:Place({ X = x, Y = y })
	structure.Team = team or "player"
	return structure, nil
end

return StructurePlacement
