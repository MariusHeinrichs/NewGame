local Collisions = require("src.collisions")
local SpatialIndex = require("src.spatialIndex")
local DEFAULT_CELL_SIZE = 128
local DEFAULT_MAX_UNITS_PER_TEAM = 60

---@class WorldEntities
---@field Units table
---@field Structures table
---@field Projectiles table
---@field Boundaries table
---@field Map table | nil
---@field WorldBounds { X: number, Y: number, Width: number, Height: number } | nil
---@field CellSize number
---@field SpatialCells table | nil
---@field MaxEntityRadius number
---@field MaxUnitsPerTeam number
local WorldEntities = {}
WorldEntities.__index = WorldEntities

--- Creates a new WorldEntities instance.
---@return WorldEntities
function WorldEntities:new()
	return setmetatable({
		Units = {},
		Structures = {},
		Projectiles = {},
		Boundaries = {},
		Map = nil,
		WorldBounds = nil,
		CellSize = DEFAULT_CELL_SIZE,
		SpatialCells = nil,
		MaxEntityRadius = 0,
		MaxUnitsPerTeam = DEFAULT_MAX_UNITS_PER_TEAM,
	}, self)
end

--- Sets the map for the WorldEntities instance.
---@param map table | nil
function WorldEntities:SetMap(map)
	self.Map = map
	self.Boundaries = {}
	self.WorldBounds = nil

	if not map then
		return
	end

	if type(map["GetBoundaries"]) == "function" then
		self.Boundaries = map:GetBoundaries() or {}
	end

	if type(map["GetWorldBounds"]) == "function" then
		local originX, originY, width, height = map:GetWorldBounds()
		if originX and originY and width and height then
			self.WorldBounds = { X = originX, Y = originY, Width = width, Height = height }
		end
	elseif type(map["GetDimensions"]) == "function" then
		local width, height = map:GetDimensions()
		if width and height then
			self.WorldBounds = { X = 0, Y = 0, Width = width, Height = height }
		end
	end
end

--- Adds a unit to the WorldEntities instance.
---@param unit table
function WorldEntities:AddUnit(unit)
	table.insert(self.Units, unit)
end

--- Adds a structure to the WorldEntities instance.
---@param structure table
function WorldEntities:AddStructure(structure)
	table.insert(self.Structures, structure)
end

--- Adds a projectile to the WorldEntities instance.
---@param projectile table
function WorldEntities:AddProjectile(projectile)
	table.insert(self.Projectiles, projectile)
end

--- Returns the world bounds as a tuple (x, y, width, height).
---@return number, number, number, number
function WorldEntities:GetWorldBounds()
	if self.WorldBounds then
		return self.WorldBounds.X, self.WorldBounds.Y, self.WorldBounds.Width, self.WorldBounds.Height
	end
	local width, height = love.graphics.getDimensions()
	return 0, 0, width, height
end

--- Checks if a circle intersects with a boundary.
---@param boundary table | nil
---@param x number
---@param y number
---@param radius number
---@return boolean
local function boundaryIntersectsCircle(boundary, x, y, radius)
	if not boundary or boundary.BlocksMovement == false then
		return false
	end

	local shape = boundary.Shape
	if not shape then
		return false
	end

	if shape.Type == "rect" then
		return Collisions.CircleIntersectsRect(x, y, radius, shape.X, shape.Y, shape.Width, shape.Height)
	end

	if shape.Type == "circle" then
		return Collisions.CirclesOverlap(x, y, radius, shape.X, shape.Y, shape.Radius)
	end

	return false
end

--- Checks if a rectangle intersects with a boundary.
---@param boundary table | nil
---@param x number
---@param y number
---@param w number
---@param h number
---@return boolean
local function boundaryIntersectsRect(boundary, x, y, w, h)
	if not boundary or boundary.BlocksPlacement == false then
		return false
	end

	local shape = boundary.Shape
	if not shape then
		return false
	end

	if shape.Type == "rect" then
		return Collisions.RectsOverlap(x, y, w, h, shape.X, shape.Y, shape.Width, shape.Height)
	end

	if shape.Type == "circle" then
		local closestX = math.max(x, math.min(shape.X, x + w))
		local closestY = math.max(y, math.min(shape.Y, y + h))
		local dx = shape.X - closestX
		local dy = shape.Y - closestY
		return (dx * dx + dy * dy) < (shape.Radius * shape.Radius)
	end

	return false
end

--- Checks if a unit can be spawned at the given position.
---@param x number
---@param y number
---@param radius number
---@return boolean
function WorldEntities:CanSpawnUnitAt(x, y, radius)
	local unitRadius = radius or 0
	local boundsX, boundsY, width, height = self:GetWorldBounds()

	if x - unitRadius < boundsX or y - unitRadius < boundsY
		or x + unitRadius > (boundsX + width) or y + unitRadius > (boundsY + height) then
		return false
	end

	for _, boundary in ipairs(self.Boundaries) do
		if boundaryIntersectsCircle(boundary, x, y, unitRadius) then
			return false
		end
	end

	for _, unit in ipairs(self.Units) do
		if Collisions.CirclesOverlap(x, y, unitRadius, unit.Position.X, unit.Position.Y, unit.Size) then
			return false
		end
	end

	return true
end

--- Rebuilds the spatial grid from current unit and structure positions.
function WorldEntities:RebuildSpatialIndex()
	SpatialIndex.Rebuild(self)
end

--- Returns the list of units in the world.
---@return table
function WorldEntities:GetUnits()
	return self.Units
end

--- Returns the list of structures in the world.
---@return table
function WorldEntities:GetStructures()
	return self.Structures
end

--- Returns the list of projectiles in the world.
---@return table
function WorldEntities:GetProjectiles()
	return self.Projectiles
end

--- Returns the unit count by team.
---@param team "player" | "enemy" | string | nil
---@return number
function WorldEntities:GetUnitCountByTeam(team)
	local requestedTeam = team or "player"
	local count = 0
	for _, unit in ipairs(self.Units) do
		if (unit.Team or "player") == requestedTeam then
			count = count + 1
		end
	end
	return count
end

--- Finds the closest enemy unit to the given source unit.
---@param sourceUnit table
---@param isTargetInRange fun(target: table): boolean
---@return table | nil
function WorldEntities:FindClosestEnemy(sourceUnit, isTargetInRange)
	return SpatialIndex.FindClosestEnemy(self, sourceUnit, isTargetInRange)
end

--- Finds the enemy town hall for the given team.
---@param team "player" | "enemy"
---@return Structure | nil
function WorldEntities:GetEnemyTownHall(team)
	return SpatialIndex.GetEnemyTownHall(self, team)
end

--- Checks if a moving unit will collide with any obstacles at the given position.
---@param movingUnit table
---@param nextX number
---@param nextY number
---@return boolean
function WorldEntities:WillUnitCollide(movingUnit, nextX, nextY)
	for _, boundary in ipairs(self.Boundaries) do
		if boundaryIntersectsCircle(boundary, nextX, nextY, movingUnit.Size) then
			return true
		end
	end

	for _, structure in ipairs(self.Structures) do
		if structure.Team ~= movingUnit.Team then
			local rx, ry, rw, rh = Collisions.GetRectBounds(structure.Position.X, structure.Position.Y, structure.Size)
			if Collisions.CircleIntersectsRect(nextX, nextY, movingUnit.Size, rx, ry, rw, rh) then
				return true
			end
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

--- Checks if a structure can be placed at the given position.
---@param x number
---@param y number
---@param size number
---@return boolean
---@return string | nil
function WorldEntities:CanPlaceStructureAt(x, y, size)
	local targetX, targetY, targetW, targetH = Collisions.GetRectBounds(x, y, size)
	local boundsX, boundsY, width, height = self:GetWorldBounds()

	if targetX < boundsX or targetY < boundsY
		or targetX + targetW > (boundsX + width) or targetY + targetH > (boundsY + height) then
		return false, "out_of_bounds"
	end

	for _, boundary in ipairs(self.Boundaries) do
		if boundaryIntersectsRect(boundary, targetX, targetY, targetW, targetH) then
			return false, "blocked_by_boundary"
		end
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

--- Removes all units with health <= 0 from the world.
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

--- Removes all structures with health <= 0 from the world.
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
