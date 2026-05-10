--- MatchSetup module - builds initial match state.

local World = require("world")
local Resources = require("gameResources")
local BattleInterface = require("Interfaces.battleInterface")
local StructureRegistry = require("Objects.Structures.registry.structureRegistry")

local MatchSetup = {}

---@param world World
---@param structureType string
---@param x number
---@param y number
---@param team "player" | "enemy"
local function addStartingStructure(world, structureType, x, y, team)
	local structureClass = StructureRegistry.GetByType(structureType)
	if not structureClass then
		return
	end
	local structure = structureClass:new()
	structure:Place({ X = x, Y = y })
	structure.Team = team
	world.Entities:AddStructure(structure)
end

--- Creates a fresh match state.
---@param startResources {Gold: number, Metal: number, Aether: number} | nil
---@return World
---@return Resources
function MatchSetup.CreateMatchState(startResources)
	startResources = startResources or { Gold = 100, Metal = 50, Aether = 10 }
	local world = World:new()
	local resources = Resources:new(startResources.Gold, startResources.Metal, startResources.Aether)
	return world, resources
end

--- Creates a fresh runtime state for a default match.
---@param startResources {Gold: number, Metal: number, Aether: number} | nil
---@return World
---@return Resources
---@return BattleInterface
---@return boolean
function MatchSetup.CreateDefaultRuntimeState(startResources)
	local world, resources = MatchSetup.CreateMatchState(startResources)
	local battleInterface = BattleInterface:new(resources)
	local hasInitializedMatch = false
	return world, resources, battleInterface, hasInitializedMatch
end

--- Places default starting structures for a new match.
---@param world World
function MatchSetup.InitializeDefault(world)
	local width, height = love.graphics.getDimensions()
	local townHallMargin = width * 0.1
	local playerTownHallX = townHallMargin
	local enemyTownHallX = width - townHallMargin
	local centerY = height / 2

	addStartingStructure(world, "TownHall", playerTownHallX, centerY, "player")
	addStartingStructure(world, "TownHall", enemyTownHallX, centerY, "enemy")

	-- Enemy-side defensive setup for immediate pressure.
	addStartingStructure(world, "ArcherTower", enemyTownHallX - 150, centerY - 85, "enemy")
	addStartingStructure(world, "MageTower", enemyTownHallX - 185, centerY + 95, "enemy")
	addStartingStructure(world, "ArcherTower", enemyTownHallX - 255, centerY + 5, "enemy")
end

return MatchSetup
