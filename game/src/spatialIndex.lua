--- Spatial hash grid for fast entity lookups.

local SpatialIndex = {}

---@param cellX number
---@param cellY number
---@return string
local function getCellKey(cellX, cellY)
	return tostring(cellX) .. ":" .. tostring(cellY)
end

---@param x number
---@param y number
---@param cellSize number
---@return number, number
local function getCellCoords(x, y, cellSize)
	return math.floor(x / cellSize), math.floor(y / cellSize)
end

---@param cells table
---@param cellX number
---@param cellY number
---@param entity table
local function insertCellEntity(cells, cellX, cellY, entity)
	local key = getCellKey(cellX, cellY)
	if not cells[key] then
		cells[key] = {}
	end
	table.insert(cells[key], entity)
end

--- Rebuilds the spatial grid from all unit and structure positions.
---@param entities WorldEntities
function SpatialIndex.Rebuild(entities)
	local cells = {}
	local maxRadius = 0

	for _, unit in ipairs(entities.Units) do
		local cellX, cellY = getCellCoords(unit.Position.X, unit.Position.Y, entities.CellSize)
		insertCellEntity(cells, cellX, cellY, unit)
		maxRadius = math.max(maxRadius, unit.Size or 0)
	end

	for _, structure in ipairs(entities.Structures) do
		local cellX, cellY = getCellCoords(structure.Position.X, structure.Position.Y, entities.CellSize)
		insertCellEntity(cells, cellX, cellY, structure)
		maxRadius = math.max(maxRadius, (structure.Size or 0) / 2)
	end

	entities.SpatialCells = cells
	entities.MaxEntityRadius = maxRadius
end

--- Returns the closest enemy to sourceUnit that passes the range check.
---@param entities WorldEntities
---@param sourceUnit table
---@param isTargetInRange fun(target: table): boolean
---@return table | nil
function SpatialIndex.FindClosestEnemy(entities, sourceUnit, isTargetInRange)
	if not entities.SpatialCells then
		SpatialIndex.Rebuild(entities)
	end

	local closestTarget = nil
	local closestDistSq = math.huge
	local searchRadius = math.max(sourceUnit.AggroRange or 0, sourceUnit.AttackRange or 0) + entities.MaxEntityRadius
	local minCellX, minCellY = getCellCoords(
		sourceUnit.Position.X - searchRadius,
		sourceUnit.Position.Y - searchRadius,
		entities.CellSize
	)
	local maxCellX, maxCellY = getCellCoords(
		sourceUnit.Position.X + searchRadius,
		sourceUnit.Position.Y + searchRadius,
		entities.CellSize
	)

	for cellX = minCellX, maxCellX do
		for cellY = minCellY, maxCellY do
			local bucket = entities.SpatialCells[getCellKey(cellX, cellY)]
			if bucket then
				for _, target in ipairs(bucket) do
					if target ~= sourceUnit and target.Team ~= sourceUnit.Team then
						local dx = target.Position.X - sourceUnit.Position.X
						local dy = target.Position.Y - sourceUnit.Position.Y
						local distSq = dx * dx + dy * dy
						if isTargetInRange(target) and distSq < closestDistSq then
							closestDistSq = distSq
							closestTarget = target
						end
					end
				end
			end
		end
	end

	return closestTarget
end

--- Returns the enemy TownHall for the given team.
---@param entities WorldEntities
---@param team "player" | "enemy"
---@return table | nil
function SpatialIndex.GetEnemyTownHall(entities, team)
	for _, structure in ipairs(entities.Structures) do
		if structure.Team ~= team and structure.Name == "TownHall" then
			return structure
		end
	end
	return nil
end

return SpatialIndex
