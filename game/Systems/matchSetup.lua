--- MatchSetup module - builds initial match state.

local World = require("world")
local Resources = require("gameResources")
local BattleInterface = require("Interfaces.battleInterface")
local EnemyBuilderAI = require("Systems.enemyBuilderAI")
local DefaultMap = require("Maps.Maps.defaultMap")

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
---@return EnemyBuilderAI
function MatchSetup.CreateDefaultRuntimeState(startResources)
	local world, resources = MatchSetup.CreateMatchState(startResources)
	local battleInterface = BattleInterface:new(resources)
	local hasInitializedMatch = false
	local enemyBuilderAI = EnemyBuilderAI:new()
	return world, resources, battleInterface, hasInitializedMatch, enemyBuilderAI
end

--- Places default starting structures for a new match.
---@param world World
function MatchSetup.InitializeDefault(world)
	---@type any
	local map = DefaultMap.Create()
	world:SetMap(map)

	if type(map.ApplyInitialState) == "function" then
		map:ApplyInitialState(world)
	end
end

return MatchSetup
