--- World module — manages all active game entities.

local StructurePlacement = require("Objects.Structures.placement.structurePlacement")
local StructureRegistry = require("Objects.Structures.registry.structureRegistry")
local WorldEntities = require("src.worldEntities")

---@class World
---@field Entities WorldEntities
---@field Map table | nil
---@field ShowMapDebug boolean
local World = {}
World.__index = World

---@param path table | nil
local function drawPathDebug(path)
	if not path or type(path.GetWaypoints) ~= "function" then
		return
	end

	local waypoints = path:GetWaypoints()
	if not waypoints or #waypoints == 0 then
		return
	end

	if path.Team == "enemy" then
		love.graphics.setColor(0.95, 0.35, 0.35, 0.8)
	else
		love.graphics.setColor(0.2, 0.85, 0.35, 0.8)
	end

	for i = 1, #waypoints - 1 do
		local startPoint = waypoints[i]
		local endPoint = waypoints[i + 1]
		love.graphics.line(startPoint.X, startPoint.Y, endPoint.X, endPoint.Y)
	end

	for _, point in ipairs(waypoints) do
		love.graphics.circle("fill", point.X, point.Y, 3)
	end
end

---@param boundary table | nil
local function drawBoundaryDebug(boundary)
	if not boundary or not boundary.Shape then
		return
	end

	if boundary.BlocksMovement == false and boundary.BlocksPlacement == false then
		love.graphics.setColor(0.6, 0.6, 0.6, 0.35)
	elseif boundary.BlocksMovement and boundary.BlocksPlacement then
		love.graphics.setColor(0.95, 0.75, 0.2, 0.4)
	elseif boundary.BlocksMovement then
		love.graphics.setColor(0.95, 0.45, 0.2, 0.4)
	else
		love.graphics.setColor(0.35, 0.75, 0.95, 0.4)
	end

	if boundary.Shape.Type == "rect" then
		love.graphics.rectangle("fill", boundary.Shape.X, boundary.Shape.Y, boundary.Shape.Width, boundary.Shape.Height)
		love.graphics.setColor(1, 1, 1, 0.7)
		love.graphics.rectangle("line", boundary.Shape.X, boundary.Shape.Y, boundary.Shape.Width, boundary.Shape.Height)
		return
	end

	if boundary.Shape.Type == "circle" then
		love.graphics.circle("fill", boundary.Shape.X, boundary.Shape.Y, boundary.Shape.Radius)
		love.graphics.setColor(1, 1, 1, 0.7)
		love.graphics.circle("line", boundary.Shape.X, boundary.Shape.Y, boundary.Shape.Radius)
	end
end

---@param map table | nil
local function drawMapDebug(map)
	if not map then
		return
	end

	if map.Paths then
		for _, path in ipairs(map.Paths) do
			drawPathDebug(path)
		end
	end

	if map.Boundaries then
		for _, boundary in ipairs(map.Boundaries) do
			drawBoundaryDebug(boundary)
		end
	end

	love.graphics.setColor(1, 1, 1, 1)
end

---@param self World
---@param structure table | nil
local function assignStructurePath(self, structure)
	if not structure or not structure.Position or not self.Map then
		return
	end

	if structure.PathId and type(self.Map["GetPathById"]) == "function" and self.Map:GetPathById(structure.PathId) then
		return
	end

	if type(self.Map["GetClosestPathForTeam"]) ~= "function" then
		return
	end

	local closestPath = self.Map:GetClosestPathForTeam(structure.Position.X, structure.Position.Y, structure.Team)
	if closestPath and closestPath.Id then
		structure.PathId = closestPath.Id
	end
end

---@param entities WorldEntities
---@param units table
local function runMovementPhase(entities, units)
	entities:RebuildSpatialIndex()

	for _, unit in ipairs(units) do
		local nextX, nextY = unit:CalculateNextPosition(entities)
		unit:MoveTo(nextX, nextY)
	end

	entities:RemoveDeadUnits()
	entities:RebuildSpatialIndex()
end

---@param entities WorldEntities
---@param units table
---@param structures table
---@param dt number
local function runCombatPhase(entities, units, structures, dt)
	for _, unit in ipairs(units) do
		unit:UpdateCombat(dt, entities)
	end
	for _, structure in ipairs(structures) do
		structure:UpdateCombat(dt, entities)
	end
end

---@param entities WorldEntities
---@param dt number
local function runProjectileAndCleanupPhase(entities, dt)
	entities:UpdateProjectiles(dt)
	entities:RemoveDeadUnits()
end

---@param entities WorldEntities
---@param structures table
---@param dt number
local function runSpawnPhase(entities, structures, dt)
	for _, structure in ipairs(structures) do
		entities:TrySpawnUnitFromStructure(structure, dt)
	end

	entities:RemoveDeadStructures()
end

---@return World
function World:new()
	return setmetatable({
		Entities = WorldEntities:new(),
		Map = nil,
		ShowMapDebug = false,
	}, self)
end

---@param map table | nil
function World:SetMap(map)
	self.Map = map
	self.Entities:SetMap(map)
end

---@param enabled boolean
function World:SetMapDebugEnabled(enabled)
	self.ShowMapDebug = enabled == true
end

---@return boolean
function World:ToggleMapDebug()
	self.ShowMapDebug = not self.ShowMapDebug
	return self.ShowMapDebug
end

---@param structure table
function World:AddStructure(structure)
	assignStructurePath(self, structure)
	self.Entities:AddStructure(structure)
end

--- Places a structure of the given type at the given position, if a type is selected.
---@param selectedStructureType string | nil
---@param resources Resources
---@param x number
---@param y number
---@param team "player" | "enemy"
---@return boolean placed True when structure was successfully placed.
---@return string | nil reason Failure reason code when placement fails.
function World:PlaceStructure(selectedStructureType, resources, x, y, team)
	local structureClass = StructureRegistry.GetByType(selectedStructureType)
	local structure, reason = StructurePlacement.PlaceStructure(structureClass, resources, self.Entities, x, y, team)
	if structure then
		self:AddStructure(structure)
		return true, nil
	end
	return false, reason
end

--- Updates all entities. Moves units, removes dead ones, spawns new ones from structures.
---@param dt number
function World:Update(dt)
	local units = self.Entities:GetUnits()
	local structures = self.Entities:GetStructures()

	-- Phase 1: movement and pathing.
	runMovementPhase(self.Entities, units)

	-- Phase 2: direct combat resolution.
	runCombatPhase(self.Entities, units, structures, dt)

	-- Phase 3: projectile simulation and post-combat cleanup.
	runProjectileAndCleanupPhase(self.Entities, dt)

	-- Phase 4: structure-based spawns and structure cleanup.
	runSpawnPhase(self.Entities, structures, dt)
end

--- Draws all entities.
function World:Draw()
	if self.ShowMapDebug then
		drawMapDebug(self.Map)
	end

	for _, unit in ipairs(self.Entities:GetUnits()) do
		unit:Draw()
	end
	for _, projectile in ipairs(self.Entities:GetProjectiles()) do
		projectile:Draw()
	end
	for _, structure in ipairs(self.Entities:GetStructures()) do
		structure:Draw()
	end
end

return World
