--- Simple AI that periodically places enemy structures on the enemy side.

local GameContext = require("src.gameContext")

local EnemyBuilderAI = {}
EnemyBuilderAI.__index = EnemyBuilderAI

local DEFAULT_STRUCTURE_TYPES = {
	"BarbarianCamp",
	"Barracks",
	"ArcherCamp",
	"Library",
	"ArcherTower",
	"MageTower",
}

local function randomBetween(minValue, maxValue)
	return minValue + (love.math.random() * (maxValue - minValue))
end

---@param structureTypes string[]
---@return string
local function pickRandomStructureType(structureTypes)
	local randomIndex = love.math.random(1, #structureTypes)
	return structureTypes[randomIndex]
end

---@class EnemyBuilderAI
---@field PlacementInterval number
---@field PlacementTimer number
---@field MaxPlacementAttempts number
---@field StructureTypes string[]
---@field EnemyResourcesProxy table

---@param config {PlacementInterval: number | nil, MaxPlacementAttempts: number | nil, StructureTypes: string[] | nil} | nil
---@return EnemyBuilderAI
function EnemyBuilderAI:new(config)
	config = config or {}

	local enemyBuilderAI = setmetatable({}, self)
	enemyBuilderAI.PlacementInterval = config.PlacementInterval or 8
	enemyBuilderAI.PlacementTimer = 0
	enemyBuilderAI.MaxPlacementAttempts = config.MaxPlacementAttempts or 16
	enemyBuilderAI.StructureTypes = config.StructureTypes or DEFAULT_STRUCTURE_TYPES

	-- Enemy placements should not consume player resources.
	enemyBuilderAI.EnemyResourcesProxy = {
		Spend = function(_self, _costs)
			return true
		end,
		AddIncomeBonus = function(_self, _goldBonus, _metalBonus)
			return
		end,
	}

	return enemyBuilderAI
end

---@return boolean
function EnemyBuilderAI:TryPlaceEnemyStructure()
	if #self.StructureTypes == 0 then
		return false
	end

	local world = GameContext.Runtime.World
	if not world then
		return false
	end

	local width, height = love.graphics.getDimensions()
	local minX = width * 0.58
	local maxX = width * 0.92
	local minY = height * 0.12
	local maxY = height * 0.88

	for _ = 1, self.MaxPlacementAttempts do
		local structureType = pickRandomStructureType(self.StructureTypes)
		local x = randomBetween(minX, maxX)
		local y = randomBetween(minY, maxY)
		local placed = world:PlaceStructure(structureType, self.EnemyResourcesProxy, x, y, "enemy")
		if placed then
			return true
		end
	end

	return false
end

---@param dt number
function EnemyBuilderAI:Update(dt)
	if not GameContext.Runtime.World then
		return
	end

	self.PlacementTimer = self.PlacementTimer + dt
	while self.PlacementTimer >= self.PlacementInterval do
		self.PlacementTimer = self.PlacementTimer - self.PlacementInterval
		self:TryPlaceEnemyStructure()
	end
end

return EnemyBuilderAI