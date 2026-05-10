--- MatchSetup module - builds initial match state.

local World = require("world")
local Resources = require("gameResources")
local BattleInterface = require("Interfaces.battleInterface")

local MatchSetup = {}

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
---@param resources Resources
function MatchSetup.InitializeDefault(world, resources)
	local width, height = love.graphics.getDimensions()
	local townHallMargin = width * 0.1
	world:PlaceStructure("TownHall", resources, townHallMargin, height / 2)
	world:PlaceStructure("TownHall", resources, width - townHallMargin, height / 2)
end

return MatchSetup
