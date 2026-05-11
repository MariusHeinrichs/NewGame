--- Default map preset with one lane per team.

local Map = require("Maps.base.map")
local PathGraph = require("Maps.base.pathGraph")
local Boundary = require("Maps.base.boundary")

local DefaultMap = {}

---@return Map
function DefaultMap.Create()
	local width, height = 1280, 720
	---@type any
	local map = Map:new("default", width, height)
	local playerSpawnX = width * 0.1
	local enemySpawnX = width * 0.9
	local laneYs = {
		height * 0.32,
		height * 0.5,
		height * 0.68,
	}

	for laneIndex, laneY in ipairs(laneYs) do
		---@type any
		local playerPath = PathGraph:new("lane_player_" .. tostring(laneIndex), "player")
		playerPath:AddWaypoint(playerSpawnX, laneY)
		playerPath:AddWaypoint(width * 0.3, laneY)
		playerPath:AddWaypoint(width * 0.5, laneY)
		playerPath:AddWaypoint(width * 0.7, laneY)
		playerPath:AddWaypoint(enemySpawnX, laneY)

		---@type any
		local enemyPath = PathGraph:new("lane_enemy_" .. tostring(laneIndex), "enemy")
		enemyPath:AddWaypoint(enemySpawnX, laneY)
		enemyPath:AddWaypoint(width * 0.7, laneY)
		enemyPath:AddWaypoint(width * 0.5, laneY)
		enemyPath:AddWaypoint(width * 0.3, laneY)
		enemyPath:AddWaypoint(playerSpawnX, laneY)

		map:AddPath(playerPath)
		map:AddPath(enemyPath)
	end

	map:SetSpawnPoint("player", playerSpawnX, laneYs[2])
	map:SetSpawnPoint("enemy", enemySpawnX, laneYs[2])
	local centerY = laneYs[2]

	map:AddStartingStructure("TownHall", playerSpawnX, centerY, "player")
	map:AddStartingStructure("TownHall", enemySpawnX, centerY, "enemy")
	map:AddStartingStructure("ArcherTower", enemySpawnX - 150, centerY - 85, "enemy")
	map:AddStartingStructure("MageTower", enemySpawnX - 185, centerY + 95, "enemy")
	map:AddStartingStructure("ArcherTower", enemySpawnX - 255, centerY + 5, "enemy")

	map:AddBoundary(Boundary:Rect(width * 0.47, height * 0.08, width * 0.06, height * 0.2, true, true, { "forest" }))
	map:AddBoundary(Boundary:Rect(width * 0.47, height * 0.72, width * 0.06, height * 0.2, true, true, { "forest" }))
	map:AddBoundary(Boundary:Circle(width * 0.52, height * 0.18, math.max(16, height * 0.04), true, true, { "tree" }))
	map:AddBoundary(Boundary:Circle(width * 0.52, height * 0.82, math.max(16, height * 0.04), true, true, { "tree" }))

	return map
end

return DefaultMap
