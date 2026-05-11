--- World module — manages all active game entities.

local StructurePlacement = require("Objects.Structures.placement.structurePlacement")
local StructureRegistry = require("Objects.Structures.registry.structureRegistry")
local CombatSystem = require("Systems.combatSystem")
local MapDebugRenderer = require("Systems.mapDebugRenderer")
local MovementSystem = require("Systems.movementSystem")
local ProjectileSystem = require("Systems.projectileSystem")
local SpawnSystem = require("Systems.spawnSystem")
local WorldTransformSystem = require("Systems.worldTransformSystem")
local WorldEntities = require("src.worldEntities")

---@class World
---@field Entities WorldEntities
---@field Map table | nil
---@field ShowMapDebug boolean
local World = {}
World.__index = World

--- Description of function assignStructurePath.
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

---@return World
function World:new()
	return setmetatable({
		Entities = WorldEntities:new(),
		Map = nil,
		ShowMapDebug = false,
	}, self)
end

--- Description of function World:SetMap.
---@param map table | nil
function World:SetMap(map)
	if map and type(map.CenterInWindow) == "function" then
		map:CenterInWindow(love.graphics.getDimensions())
	end
	self.Map = map
	self.Entities:SetMap(map)
end

--- Description of function World:HandleResize.
---@param width number
---@param height number
function World:HandleResize(width, height)
	if not self.Map or type(self.Map.CenterInWindow) ~= "function" then
		return
	end

	local deltaX, deltaY = self.Map:CenterInWindow(width, height)
	WorldTransformSystem.TranslateEntities(self.Entities, deltaX, deltaY)
	self.Entities:SetMap(self.Map)
end

---@return boolean
function World:ToggleMapDebug()
	self.ShowMapDebug = not self.ShowMapDebug
	return self.ShowMapDebug
end

--- Description of function World:AddStructure.
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
	MovementSystem.Update(self.Entities, units)

	-- Phase 2: direct combat resolution.
	CombatSystem.Update(self.Entities, units, structures, dt)

	-- Phase 3: projectile simulation and post-combat cleanup.
	ProjectileSystem.Update(self.Entities, dt)

	-- Phase 4: structure-based spawns and structure cleanup.
	SpawnSystem.Update(self.Entities, structures, dt)
end

--- Draws all entities.
function World:Draw()
	if self.ShowMapDebug then
		MapDebugRenderer.Draw(self.Map)
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
