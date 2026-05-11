--- Map class containing static bounds, boundaries and movement paths.

local StructureRegistry = require("Objects.Structures.registry.structureRegistry")

local Map = {}
Map.__index = Map

---@class Map

--- Translates a point by the given delta values.
---@param point table | nil
---@param deltaX number
---@param deltaY number
local function translatePoint(point, deltaX, deltaY)
	if not point then
		return
	end
	point.X = point.X + deltaX
	point.Y = point.Y + deltaY
end

--- Translates a path by the given delta values.
---@param path table | nil
---@param deltaX number
---@param deltaY number
local function translatePath(path, deltaX, deltaY)
	if not path or type(path.GetWaypoints) ~= "function" then
		return
	end
	for _, waypoint in ipairs(path:GetWaypoints()) do
		translatePoint(waypoint, deltaX, deltaY)
	end
end

--- Translates a boundary by the given delta values.
---@param boundary table | nil
---@param deltaX number
---@param deltaY number
local function translateBoundary(boundary, deltaX, deltaY)
	if not boundary or not boundary.Shape then
		return
	end
	boundary.Shape.X = boundary.Shape.X + deltaX
	boundary.Shape.Y = boundary.Shape.Y + deltaY
end

--- Creates a new Map.
---@param id string
---@param width number
---@param height number
---@return Map
function Map:new(id, width, height)
	return setmetatable({
		Id = id,
		Width = width,
		Height = height,
		OriginX = 0,
		OriginY = 0,
		Paths = {},
		Boundaries = {},
		SpawnPoints = {},
		StartingStructures = {},
	}, self)
end

--- Translates the map by the given delta values.
---@param deltaX number
---@param deltaY number
function Map:TranslateBy(deltaX, deltaY)
	if deltaX == 0 and deltaY == 0 then
		return
	end

	self.OriginX = self.OriginX + deltaX
	self.OriginY = self.OriginY + deltaY

	for _, path in ipairs(self.Paths) do
		translatePath(path, deltaX, deltaY)
	end

	for _, boundary in ipairs(self.Boundaries) do
		translateBoundary(boundary, deltaX, deltaY)
	end

	for _, spawnPoint in pairs(self.SpawnPoints) do
		translatePoint(spawnPoint, deltaX, deltaY)
	end

	for _, startingStructure in ipairs(self.StartingStructures) do
		translatePoint(startingStructure, deltaX, deltaY)
	end
end

--- Centers the map in the window.
---@param windowWidth number | nil
---@param windowHeight number | nil
---@return number, number
function Map:CenterInWindow(windowWidth, windowHeight)
	local width = windowWidth or love.graphics.getWidth()
	local height = windowHeight or love.graphics.getHeight()
	local targetOriginX = (width - self.Width) / 2
	local targetOriginY = (height - self.Height) / 2
	local deltaX = targetOriginX - self.OriginX
	local deltaY = targetOriginY - self.OriginY
	self:TranslateBy(deltaX, deltaY)
	return deltaX, deltaY
end

--- Returns the origin of the map.
---@return number, number
function Map:GetOrigin()
	return self.OriginX, self.OriginY
end

--- Returns the world bounds of the map.
---@return number, number, number, number
function Map:GetWorldBounds()
	return self.OriginX, self.OriginY, self.Width, self.Height
end

--- Adds a starting structure to the map.
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

--- Returns the list of starting structures for the map.
---@return table
function Map:GetStartingStructures()
	return self.StartingStructures
end

--- Applies the initial state of the map to the given world, placing starting structures as needed.
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

--- Adds a path to the map.
---@param path table
function Map:AddPath(path)
	table.insert(self.Paths, path)
end

--- Adds a boundary to the map.
---@param boundary table
function Map:AddBoundary(boundary)
	table.insert(self.Boundaries, boundary)
end

--- Sets the spawn point for a team.
---@param team "player" | "enemy"
---@param x number
---@param y number
function Map:SetSpawnPoint(team, x, y)
	self.SpawnPoints[team] = { X = x, Y = y }
end

--- Returns the spawn point for a team.
---@param team "player" | "enemy"
---@return table | nil
function Map:GetSpawnPoint(team)
	return self.SpawnPoints[team]
end

--- Returns the list of boundaries for the map.
---@return table
function Map:GetBoundaries()
	return self.Boundaries
end

--- Returns the list of paths for a team.
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

--- Returns the path with the given ID.
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

--- Returns the primary path for a team.
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

--- Returns the closest path for a team to the given coordinates.
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

--- Gets the dimensions of the map.
---@return number, number
function Map:GetDimensions()
	return self.Width, self.Height
end

return Map
