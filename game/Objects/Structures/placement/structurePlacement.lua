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

--- Checks whether the structure center/footprint is on the allowed team half.
---@param entities WorldEntities | nil
---@param x number
---@param size number
---@param team "player" | "enemy"
---@return boolean
local function isOnAllowedTeamSide(entities, x, size, team)
	local boundsX = 0
	local width = love.graphics.getWidth()
	if entities and type(entities.GetWorldBounds) == "function" then
		boundsX, _, width = entities:GetWorldBounds()
	end
	local middleX = boundsX + (width / 2)
	local halfSize = size / 2

	if team == "enemy" then
		return (x - halfSize) >= middleX
	end

	return (x + halfSize) <= middleX
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
	local requestedTeam = team or "player"

	if not structureClass then
		return nil, "invalid_type"
	end

	if not isValidStructureClass(structureClass) then
		return nil, "invalid_class"
	end

	if not resources or type(resources.Spend) ~= "function" then
		return nil, "invalid_resources"
	end

	if not isOnAllowedTeamSide(entities, x, structureClass.Size, requestedTeam) then
		return nil, "wrong_side"
	end

	local canPlace, placementReason = entities:CanPlaceStructureAt(x, y, structureClass.Size)
	if not canPlace then
		return nil, placementReason
	end

	if not resources:Spend(structureClass.Costs) then
		return nil, "not_affordable"
	end

	local structure = structureClass:new()
	structure:Place({ X = x, Y = y })
	structure.Team = requestedTeam

	if structure.Team == "player" and type(resources.AddIncomeBonus) == "function" then
		resources:AddIncomeBonus(structure.IncomeBonusGold, structure.IncomeBonusMetal)
	end

	return structure, nil
end

return StructurePlacement
