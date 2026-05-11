--- Steering-based movement helper for units.

local Collisions = require("src.collisions")
local MathUtils = require("src.mathUtils")

local SteeringSystem = {}

local WEIGHTS = {
	Desired = 1.0,
	Separation = 1.4,
	Obstacle = 1.9,
}

local PADDING = {
	UnitSeparation = 6,
	BoundaryAvoid = 16,
	StructureAvoid = 10,
	WorldEdgeAvoid = 18,
}

--- Description of function getRectRepulsion.
---@param x number
---@param y number
---@param rx number
---@param ry number
---@param rw number
---@param rh number
---@return number, number, number
local function getRectRepulsion(x, y, rx, ry, rw, rh)
	local closestX = MathUtils.Clamp(x, rx, rx + rw)
	local closestY = MathUtils.Clamp(y, ry, ry + rh)
	local dx = x - closestX
	local dy = y - closestY
	local distSq = dx * dx + dy * dy
	if distSq <= 0.0001 then
		local centerX = rx + (rw * 0.5)
		local centerY = ry + (rh * 0.5)
		dx = x - centerX
		dy = y - centerY
		distSq = dx * dx + dy * dy
	end
	local dist = math.sqrt(math.max(0.0001, distSq))
	return dx / dist, dy / dist, dist
end

--- Description of function getDesiredDirection.
---@param unit table
---@param targetX number | nil
---@param targetY number | nil
---@return number, number
local function getDesiredDirection(unit, targetX, targetY)
	if not targetX or not targetY then
		return 0, 0
	end
	return MathUtils.Normalize(targetX - unit.Position.X, targetY - unit.Position.Y)
end

--- Description of function getSeparationForce.
---@param unit table
---@param entities WorldEntities
---@return number, number
local function getSeparationForce(unit, entities)
	local forceX = 0
	local forceY = 0

	for _, other in ipairs(entities:GetUnits()) do
		if other ~= unit then
			local dx = unit.Position.X - other.Position.X
			local dy = unit.Position.Y - other.Position.Y
			local distSq = dx * dx + dy * dy
			local minDist = (unit.Size + other.Size + PADDING.UnitSeparation)
			local minDistSq = minDist * minDist
			if distSq > 0.0001 and distSq < minDistSq then
				local dist = math.sqrt(distSq)
				local overlapRatio = (minDist - dist) / minDist
				local dirX = dx / dist
				local dirY = dy / dist
				forceX = forceX + (dirX * overlapRatio)
				forceY = forceY + (dirY * overlapRatio)
			end
		end
	end

	return forceX, forceY
end

--- Description of function getObstacleForce.
---@param unit table
---@param entities WorldEntities
---@return number, number
local function getObstacleForce(unit, entities)
	local forceX = 0
	local forceY = 0

	for _, boundary in ipairs(entities.Boundaries or {}) do
		if boundary.BlocksMovement ~= false and boundary.Shape then
			if boundary.Shape.Type == "rect" then
				local dirX, dirY, dist = getRectRepulsion(
					unit.Position.X,
					unit.Position.Y,
					boundary.Shape.X,
					boundary.Shape.Y,
					boundary.Shape.Width,
					boundary.Shape.Height
				)
				local avoidDist = unit.Size + PADDING.BoundaryAvoid
				if dist < avoidDist then
					local strength = (avoidDist - dist) / avoidDist
					forceX = forceX + (dirX * strength)
					forceY = forceY + (dirY * strength)
				end
			elseif boundary.Shape.Type == "circle" then
				local dx = unit.Position.X - boundary.Shape.X
				local dy = unit.Position.Y - boundary.Shape.Y
				local dist = math.sqrt(math.max(0.0001, dx * dx + dy * dy))
				local avoidDist = unit.Size + boundary.Shape.Radius + PADDING.BoundaryAvoid
				if dist < avoidDist then
					local strength = (avoidDist - dist) / avoidDist
					forceX = forceX + ((dx / dist) * strength)
					forceY = forceY + ((dy / dist) * strength)
				end
			end
		end
	end

	for _, structure in ipairs(entities:GetStructures()) do
		if structure.Team ~= unit.Team then
			local rx, ry, rw, rh = Collisions.GetRectBounds(structure.Position.X, structure.Position.Y, structure.Size)
			local dirX, dirY, dist = getRectRepulsion(unit.Position.X, unit.Position.Y, rx, ry, rw, rh)
			local avoidDist = unit.Size + (structure.Size * 0.5) + PADDING.StructureAvoid
			if dist < avoidDist then
				local strength = (avoidDist - dist) / avoidDist
				forceX = forceX + (dirX * strength)
				forceY = forceY + (dirY * strength)
			end
		end
	end

	local boundsX, boundsY, boundsW, boundsH = entities:GetWorldBounds()
	if unit.Position.X - boundsX < PADDING.WorldEdgeAvoid then
		forceX = forceX + (1 - ((unit.Position.X - boundsX) / PADDING.WorldEdgeAvoid))
	end
	if (boundsX + boundsW) - unit.Position.X < PADDING.WorldEdgeAvoid then
		forceX = forceX - (1 - (((boundsX + boundsW) - unit.Position.X) / PADDING.WorldEdgeAvoid))
	end
	if unit.Position.Y - boundsY < PADDING.WorldEdgeAvoid then
		forceY = forceY + (1 - ((unit.Position.Y - boundsY) / PADDING.WorldEdgeAvoid))
	end
	if (boundsY + boundsH) - unit.Position.Y < PADDING.WorldEdgeAvoid then
		forceY = forceY - (1 - (((boundsY + boundsH) - unit.Position.Y) / PADDING.WorldEdgeAvoid))
	end

	return forceX, forceY
end

--- Description of function resolveCollisionFallback.
---@param unit table
---@param entities WorldEntities
---@param moveDirX number
---@param moveDirY number
---@return number, number
local function resolveCollisionFallback(unit, entities, moveDirX, moveDirY)
	local step = unit.Speed
	local candidates = {
		{ X = unit.Position.X + (moveDirX * step), Y = unit.Position.Y + (moveDirY * step) },
		{ X = unit.Position.X + (-moveDirY * step), Y = unit.Position.Y + (moveDirX * step) },
		{ X = unit.Position.X + (moveDirY * step), Y = unit.Position.Y + (-moveDirX * step) },
		{ X = unit.Position.X + (-moveDirY * step * 0.6), Y = unit.Position.Y + (moveDirX * step * 0.6) },
		{ X = unit.Position.X + (moveDirY * step * 0.6), Y = unit.Position.Y + (-moveDirX * step * 0.6) },
	}

	for _, candidate in ipairs(candidates) do
		if not entities:WillUnitCollide(unit, candidate.X, candidate.Y) then
			return candidate.X, candidate.Y
		end
	end

	return unit.Position.X, unit.Position.Y
end

--- Description of function SteeringSystem.GetNextPosition.
---@param unit table
---@param entities WorldEntities
---@param targetX number | nil
---@param targetY number | nil
---@return number, number
function SteeringSystem.GetNextPosition(unit, entities, targetX, targetY)
	local desiredX, desiredY = getDesiredDirection(unit, targetX, targetY)
	if desiredX == 0 and desiredY == 0 then
		return unit.Position.X, unit.Position.Y
	end

	local separationX, separationY = getSeparationForce(unit, entities)
	local obstacleX, obstacleY = getObstacleForce(unit, entities)

	local steerX =
		(desiredX * WEIGHTS.Desired) +
		(separationX * WEIGHTS.Separation) +
		(obstacleX * WEIGHTS.Obstacle)
	local steerY =
		(desiredY * WEIGHTS.Desired) +
		(separationY * WEIGHTS.Separation) +
		(obstacleY * WEIGHTS.Obstacle)

	local moveDirX, moveDirY = MathUtils.Normalize(steerX, steerY)
	if moveDirX == 0 and moveDirY == 0 then
		moveDirX, moveDirY = desiredX, desiredY
	end

	local nextX = unit.Position.X + (moveDirX * unit.Speed)
	local nextY = unit.Position.Y + (moveDirY * unit.Speed)
	if entities:WillUnitCollide(unit, nextX, nextY) then
		return resolveCollisionFallback(unit, entities, moveDirX, moveDirY)
	end

	return nextX, nextY
end

return SteeringSystem
