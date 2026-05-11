--- Map class containing static bounds, boundaries and movement paths.

local StructureRegistry = require("Objects.Structures.registry.structureRegistry")

local Map = {}
Map.__index = Map

---@class Map

---@param id string
---@param width number
---@param height number
---@return Map
function Map:new(id, width, height)
	return setmetatable({
		Id = id,
		Width = width,
		Height = height,
		Paths = {},
		Boundaries = {},
		SpawnPoints = {},
		StartingStructures = {},
	}, self)
end

---@param structureType string
---@param x number
---@param y number
---@param team "player" | "enemy"
function Map:AddStartingStructure(structureType, x, y, team)
	table.insert(self.StartingStructures, {
		StructureType = structureType,
		X = x,
		Y = y,
		Team = team,
	})
end

---@return table
function Map:GetStartingStructures()
	return self.StartingStructures
end

---@param world World
function Map:ApplyInitialState(world)
	if not world or type(world.AddStructure) ~= "function" then
		return
	end

	for _, startingStructure in ipairs(self.StartingStructures) do
		local structureClass = StructureRegistry.GetByType(startingStructure.StructureType)
		if structureClass then
			local structure = structureClass:new()
			structure:Place({ X = startingStructure.X, Y = startingStructure.Y })
			structure.Team = startingStructure.Team
			world:AddStructure(structure)
		end
	end
end

---@param path table
function Map:AddPath(path)
	table.insert(self.Paths, path)
end

---@param boundary table
function Map:AddBoundary(boundary)
	table.insert(self.Boundaries, boundary)
end

---@param team "player" | "enemy"
---@param x number
---@param y number
function Map:SetSpawnPoint(team, x, y)
	self.SpawnPoints[team] = { X = x, Y = y }
end

---@param team "player" | "enemy"
---@return table | nil
function Map:GetSpawnPoint(team)
	return self.SpawnPoints[team]
end

---@return table
function Map:GetBoundaries()
	return self.Boundaries
end

---@param team "player" | "enemy"
---@return table
function Map:GetPathsForTeam(team)
	local paths = {}
	for _, path in ipairs(self.Paths) do
		if path.Team == team then
			table.insert(paths, path)
		end
	end
	return paths
end

---@param id string | nil
---@return table | nil
function Map:GetPathById(id)
	if not id then
		return nil
	end

	for _, path in ipairs(self.Paths) do
		if path.Id == id then
			return path
		end
	end

	return nil
end

---@param team "player" | "enemy"
---@return table | nil
function Map:GetPrimaryPathForTeam(team)
	local teamPaths = self:GetPathsForTeam(team)
	if #teamPaths > 0 then
		return teamPaths[1]
	end

	if #self.Paths > 0 then
		return self.Paths[1]
	end
	return nil
end

---@param x number
---@param y number
---@param team "player" | "enemy"
---@return table | nil
function Map:GetClosestPathForTeam(x, y, team)
	local teamPaths = self:GetPathsForTeam(team)
	if #teamPaths == 0 then
		return self:GetPrimaryPathForTeam(team)
	end

	local bestPath = nil
	local bestDistSq = math.huge

	for _, path in ipairs(teamPaths) do
		if type(path.GetClosestWaypointIndex) == "function" and type(path.GetWaypoint) == "function" then
			local index = path:GetClosestWaypointIndex(x, y)
			local waypoint = index and path:GetWaypoint(index) or nil
			if waypoint then
				local dx = waypoint.X - x
				local dy = waypoint.Y - y
				local distSq = dx * dx + dy * dy
				if distSq < bestDistSq then
					bestDistSq = distSq
					bestPath = path
				end
			end
		end
	end

	return bestPath or self:GetPrimaryPathForTeam(team)
end

---@return number, number
function Map:GetDimensions()
	return self.Width, self.Height
end

return Map
