--- Path graph represented by ordered waypoints for one lane.

local PathGraph = {}
PathGraph.__index = PathGraph

---@class PathGraph

---@param id string | nil
---@param team "player" | "enemy" | nil
---@param waypoints table | nil
---@return PathGraph
function PathGraph:new(id, team, waypoints)
	return setmetatable({
		Id = id or "path",
		Team = team,
		Waypoints = waypoints or {},
	}, self)
end

---@param x number
---@param y number
function PathGraph:AddWaypoint(x, y)
	table.insert(self.Waypoints, { X = x, Y = y })
end

---@return table
function PathGraph:GetWaypoints()
	return self.Waypoints
end

---@param x number
---@param y number
---@return number | nil
function PathGraph:GetClosestWaypointIndex(x, y)
	if #self.Waypoints == 0 then
		return nil
	end

	local bestIndex = 1
	local bestDistSq = math.huge
	for i, waypoint in ipairs(self.Waypoints) do
		local dx = waypoint.X - x
		local dy = waypoint.Y - y
		local distSq = dx * dx + dy * dy
		if distSq < bestDistSq then
			bestDistSq = distSq
			bestIndex = i
		end
	end

	return bestIndex
end

---@param index number
---@return table | nil
function PathGraph:GetWaypoint(index)
	return self.Waypoints[index]
end

return PathGraph
