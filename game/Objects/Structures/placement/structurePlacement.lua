local Collisions = require("src.collisions")

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
---@param units table
---@param structures table
---@param x number
---@param y number
---@param size number
---@return boolean
local function canPlaceStructureAt(units, structures, x, y, size)
	local targetX, targetY, targetW, targetH = Collisions.GetRectBounds(x, y, size)

	for _, structure in ipairs(structures) do
		local sx, sy, sw, sh = Collisions.GetRectBounds(structure.Position.X, structure.Position.Y, structure.Size)
		if Collisions.RectsOverlap(targetX, targetY, targetW, targetH, sx, sy, sw, sh) then
			return false
		end
	end

	for _, unit in ipairs(units) do
		if Collisions.CircleIntersectsRect(unit.Position.X, unit.Position.Y, unit.Size, targetX, targetY, targetW, targetH) then
			return false
		end
	end

	return true
end

--- Places a structure of the given class at the given position.
--- Returns nil if the class is unknown or the player cannot afford it or the position is invalid.
---@param structureClass table | nil
---@param resources Resources
---@param units table
---@param structures table
---@param x number
---@param y number
---@return Structure | nil The placed structure if successful, otherwise nil.
---@return string | nil reason Failure reason code when placement fails.
function StructurePlacement.PlaceStructure(structureClass, resources, units, structures, x, y)
	if not structureClass then
		return nil, "invalid_type"
	end

	if not isValidStructureClass(structureClass) then
		return nil, "invalid_class"
	end

	if not resources or type(resources.Spend) ~= "function" then
		return nil, "invalid_resources"
	end

	if not canPlaceStructureAt(units, structures, x, y, structureClass.Size) then
		return nil, "blocked_by_collision"
	end

	if not resources:Spend(structureClass.Costs) then
		return nil, "not_affordable"
	end

	local structure = structureClass:new()
	structure:Place({ X = x, Y = y })
	return structure, nil
end

return StructurePlacement
