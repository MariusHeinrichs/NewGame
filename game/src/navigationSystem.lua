--- Navigation helpers for path-based fallback movement.

local NavigationSystem = {}

local WAYPOINT_REACHED_DISTANCE = 14

---@param unit table
---@param map table
---@return table | nil
local function getPathForUnit(unit, map)
	local selectedPath = nil

	if unit.PathId and type(map["GetPathById"]) == "function" then
		selectedPath = map:GetPathById(unit.PathId)
	end

	if not selectedPath and type(map["GetClosestPathForTeam"]) == "function" then
		selectedPath = map:GetClosestPathForTeam(unit.Position.X, unit.Position.Y, unit.Team)
		if selectedPath and selectedPath.Id ~= unit.PathId then
			unit.PathId = selectedPath.Id
			unit.PathWaypointIndex = nil
		end
	end

	if not selectedPath and type(map["GetPrimaryPathForTeam"]) == "function" then
		selectedPath = map:GetPrimaryPathForTeam(unit.Team)
		if selectedPath and selectedPath.Id ~= unit.PathId then
			unit.PathId = selectedPath.Id
			unit.PathWaypointIndex = nil
		end
	end

	return selectedPath
end

---@param unit table
---@param path table
---@return number | nil
local function getCurrentWaypointIndex(unit, path)
	local waypointIndex = unit.PathWaypointIndex
	if waypointIndex ~= nil then
		return waypointIndex
	end

	if type(path.GetWaypoints) ~= "function" then
		return path:GetClosestWaypointIndex(unit.Position.X, unit.Position.Y)
	end

	local waypoints = path:GetWaypoints()
	if not waypoints or #waypoints == 0 then
		return path:GetClosestWaypointIndex(unit.Position.X, unit.Position.Y)
	end

	local forwardSign = (unit.Team == "enemy") and -1 or 1
	local tolerance = math.max(8, unit.Size or 0)
	local bestAheadIndex = nil
	local bestAheadDistSq = math.huge

	for i, waypoint in ipairs(waypoints) do
		local dx = waypoint.X - unit.Position.X
		local dy = waypoint.Y - unit.Position.Y
		local isAhead = (forwardSign > 0 and dx >= -tolerance) or (forwardSign < 0 and dx <= tolerance)
		if isAhead then
			local distSq = dx * dx + dy * dy
			if distSq < bestAheadDistSq then
				bestAheadDistSq = distSq
				bestAheadIndex = i
			end
		end
	end

	if bestAheadIndex ~= nil then
		return bestAheadIndex
	end

	return path:GetClosestWaypointIndex(unit.Position.X, unit.Position.Y)
end

---@param unit table
---@param path table
---@return table | nil
local function pickWaypoint(unit, path)
	local waypointIndex = getCurrentWaypointIndex(unit, path)
	if waypointIndex == nil then
		return nil
	end

	local waypoint = path:GetWaypoint(waypointIndex)
	if waypoint == nil then
		return nil
	end

	local dx = waypoint.X - unit.Position.X
	local dy = waypoint.Y - unit.Position.Y
	local reachedDist = math.max(WAYPOINT_REACHED_DISTANCE, unit.Speed * 1.5)
	if (dx * dx + dy * dy) <= (reachedDist * reachedDist) then
		if waypointIndex < #path:GetWaypoints() then
			waypointIndex = waypointIndex + 1
		end
		waypoint = path:GetWaypoint(waypointIndex)
	end

	unit.PathWaypointIndex = waypointIndex
	return waypoint
end

---@param unit table
---@param entities WorldEntities
---@return number | nil, number | nil
function NavigationSystem.GetPathTargetPoint(unit, entities)
	if not entities or not entities.Map then
		return nil, nil
	end

	local map = entities.Map
	if not map then
		return nil, nil
	end

	local path = getPathForUnit(unit, map)
	if not path or type(path.GetWaypoint) ~= "function" then
		return nil, nil
	end

	local waypoint = pickWaypoint(unit, path)
	if waypoint == nil then
		return nil, nil
	end

	return waypoint.X, waypoint.Y
end

---@param unit table
---@param entities WorldEntities
---@return number | nil, number | nil
function NavigationSystem.GetPathFallbackPosition(unit, entities)
	local waypointX, waypointY = NavigationSystem.GetPathTargetPoint(unit, entities)
	if not waypointX or not waypointY then
		return nil, nil
	end

	local dx = waypointX - unit.Position.X
	local dy = waypointY - unit.Position.Y
	local dist = math.sqrt(dx * dx + dy * dy)
	if dist <= 0 then
		return unit.Position.X, unit.Position.Y
	end

	return unit.Position.X + (dx / dist) * unit.Speed, unit.Position.Y + (dy / dist) * unit.Speed
end

return NavigationSystem
