local Collisions = require("src.collisions")
local DEFAULT_CELL_SIZE = 128

---@class WorldEntities
---@field Units table
---@field Structures table
---@field CellSize number
---@field SpatialCells table | nil
---@field MaxEntityRadius number
local WorldEntities = {}
WorldEntities.__index = WorldEntities

---@param units table
---@param structures table
---@return WorldEntities
function WorldEntities:new(units, structures)
	return setmetatable({
		Units = units,
		Structures = structures,
		CellSize = DEFAULT_CELL_SIZE,
		SpatialCells = nil,
		MaxEntityRadius = 0,
	}, self)
end

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

--- Rebuilds the spatial grid from current unit and structure positions.
function WorldEntities:RebuildSpatialIndex()
	local cells = {}
	local maxRadius = 0

	for _, unit in ipairs(self.Units) do
		local cellX, cellY = getCellCoords(unit.Position.X, unit.Position.Y, self.CellSize)
		insertCellEntity(cells, cellX, cellY, unit)
		maxRadius = math.max(maxRadius, unit.Size or 0)
	end

	for _, structure in ipairs(self.Structures) do
		local cellX, cellY = getCellCoords(structure.Position.X, structure.Position.Y, self.CellSize)
		insertCellEntity(cells, cellX, cellY, structure)
		maxRadius = math.max(maxRadius, (structure.Size or 0) / 2)
	end

	self.SpatialCells = cells
	self.MaxEntityRadius = maxRadius
end

---@return table
function WorldEntities:GetUnits()
	return self.Units
end

---@return table
function WorldEntities:GetStructures()
	return self.Structures
end

---@param sourceUnit table
---@param isTargetInRange fun(target: table): boolean
---@return table | nil
function WorldEntities:FindClosestEnemy(sourceUnit, isTargetInRange)
	if not self.SpatialCells then
		self:RebuildSpatialIndex()
	end

	local closestTarget = nil
	local closestDistSq = math.huge
	local searchRadius = math.max(sourceUnit.AggroRange or 0, sourceUnit.AttackRange or 0) + self.MaxEntityRadius
	local minCellX, minCellY = getCellCoords(sourceUnit.Position.X - searchRadius, sourceUnit.Position.Y - searchRadius,
		self.CellSize)
	local maxCellX, maxCellY = getCellCoords(sourceUnit.Position.X + searchRadius, sourceUnit.Position.Y + searchRadius,
		self.CellSize)

	for cellX = minCellX, maxCellX do
		for cellY = minCellY, maxCellY do
			local bucket = self.SpatialCells[getCellKey(cellX, cellY)]
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

---@param team "player" | "enemy"
---@return Structure | nil
function WorldEntities:GetEnemyTownHall(team)
	for _, structure in ipairs(self.Structures) do
		if structure.Team ~= team and structure.Name == "TownHall" then
			return structure
		end
	end
	return nil
end

---@param movingUnit table
---@param nextX number
---@param nextY number
---@return boolean
function WorldEntities:WillUnitCollide(movingUnit, nextX, nextY)
	for _, structure in ipairs(self.Structures) do
		local rx, ry, rw, rh = Collisions.GetRectBounds(structure.Position.X, structure.Position.Y, structure.Size)
		if Collisions.CircleIntersectsRect(nextX, nextY, movingUnit.Size, rx, ry, rw, rh) then
			return true
		end
	end

	for _, otherUnit in ipairs(self.Units) do
		if otherUnit ~= movingUnit and Collisions.CirclesOverlap(nextX, nextY, movingUnit.Size, otherUnit.Position.X,
				otherUnit.Position.Y, otherUnit.Size) then
			return true
		end
	end

	return false
end

---@param x number
---@param y number
---@param size number
---@return boolean
---@return string | nil
function WorldEntities:CanPlaceStructureAt(x, y, size)
	local targetX, targetY, targetW, targetH = Collisions.GetRectBounds(x, y, size)
	local width, height = love.graphics.getDimensions()

	if targetX < 0 or targetY < 0 or targetX + targetW > width or targetY + targetH > height then
		return false, "out_of_bounds"
	end

	for _, structure in ipairs(self.Structures) do
		local sx, sy, sw, sh = Collisions.GetRectBounds(structure.Position.X, structure.Position.Y, structure.Size)
		if Collisions.RectsOverlap(targetX, targetY, targetW, targetH, sx, sy, sw, sh) then
			return false, "blocked_by_collision"
		end
	end

	for _, unit in ipairs(self.Units) do
		if Collisions.CircleIntersectsRect(unit.Position.X, unit.Position.Y, unit.Size, targetX, targetY, targetW, targetH) then
			return false, "blocked_by_collision"
		end
	end

	return true, nil
end

---@return number removedCount
function WorldEntities:RemoveDeadUnits()
	local removedCount = 0
	for i = #self.Units, 1, -1 do
		if self.Units[i].Health <= 0 then
			table.remove(self.Units, i)
			removedCount = removedCount + 1
		end
	end
	return removedCount
end

---@return number removedCount
function WorldEntities:RemoveDeadStructures()
	local removedCount = 0
	for i = #self.Structures, 1, -1 do
		if self.Structures[i].Health <= 0 then
			table.remove(self.Structures, i)
			removedCount = removedCount + 1
		end
	end
	return removedCount
end

return WorldEntities
