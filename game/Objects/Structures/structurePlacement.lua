local Structure = require("Objects.Structures.structure")

local STRUCTURE_BY_TYPE = {
	TownHall  = { Health = 500, Armor = 20, Size = 70, SpawnRate = 0, Costs = { Gold = 0, Metal = 0, Aether = 0 } },
	Barbarian = { Health = 220, Armor = 12, Size = 28, SpawnRate = 2, Costs = { Gold = 30, Metal = 20, Aether = 0 } },
	Knight    = { Health = 280, Armor = 18, Size = 32, SpawnRate = 3, Costs = { Gold = 50, Metal = 40, Aether = 0 } },
	Archer    = { Health = 180, Armor = 8, Size = 24, SpawnRate = 1.5, Costs = { Gold = 25, Metal = 10, Aether = 5 } },
	Mage      = { Health = 160, Armor = 6, Size = 26, SpawnRate = 1.2, Costs = { Gold = 20, Metal = 5, Aether = 15 } },
}

local StructurePlacement = {}

--- Returns true if two axis-aligned rectangles overlap.
---@param ax number
---@param ay number
---@param aw number
---@param ah number
---@param bx number
---@param by number
---@param bw number
---@param bh number
---@return boolean
local function rectsOverlap(ax, ay, aw, ah, bx, by, bw, bh)
	return ax < bx + bw and ax + aw > bx and ay < by + bh and ay + ah > by
end

--- Returns true if a circle intersects an axis-aligned rectangle.
---@param cx number
---@param cy number
---@param radius number
---@param rx number
---@param ry number
---@param rw number
---@param rh number
---@return boolean
local function circleIntersectsRect(cx, cy, radius, rx, ry, rw, rh)
	local closestX = math.max(rx, math.min(cx, rx + rw))
	local closestY = math.max(ry, math.min(cy, ry + rh))
	local dx = cx - closestX
	local dy = cy - closestY
	return (dx * dx + dy * dy) < (radius * radius)
end

---@param centerX number
---@param centerY number
---@param size number
---@return number, number, number, number
local function getStructureBounds(centerX, centerY, size)
	local halfSize = size / 2
	return centerX - halfSize, centerY - halfSize, size, size
end

--- Checks whether a structure can be placed without overlapping existing entities.
---@param units table
---@param structures table
---@param x number
---@param y number
---@param size number
---@return boolean
local function canPlaceStructureAt(units, structures, x, y, size)
	local targetX, targetY, targetW, targetH = getStructureBounds(x, y, size)

	for _, structure in ipairs(structures) do
		local sx, sy, sw, sh = getStructureBounds(structure.Position.X, structure.Position.Y, structure.Size)
		if rectsOverlap(targetX, targetY, targetW, targetH, sx, sy, sw, sh) then
			return false
		end
	end

	for _, unit in ipairs(units) do
		if circleIntersectsRect(unit.Position.X, unit.Position.Y, unit.Size, targetX, targetY, targetW, targetH) then
			return false
		end
	end

	return true
end

--- Places the currently selected structure type at the given position.
--- Returns nil if the type is unknown or the player cannot afford it or the position is invalid.
---@param selectedStructureType string | nil
---@param resources Resources
---@param units table
---@param structures table
---@param x number
---@param y number
---@return Structure | nil The placed structure if successful, otherwise nil.
function StructurePlacement.PlaceSelectedStructure(selectedStructureType, resources, units, structures, x, y)
	if not selectedStructureType then
		return nil
	end

	local selected = STRUCTURE_BY_TYPE[selectedStructureType]
	if not selected then
		return nil
	end

	if not canPlaceStructureAt(units, structures, x, y, selected.Size) then
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
