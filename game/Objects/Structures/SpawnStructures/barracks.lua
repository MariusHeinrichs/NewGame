--- Barracks structure — spawns Knights.

local SpawningStructure = require("Objects.Structures.base.spawningStructure")
local UnitRegistry = require("Objects.Units.registry.unitRegistry")

local Knight = UnitRegistry.GetByType("Knight")

---@class Barracks : SpawningStructure
local Barracks = {}
Barracks.__index = Barracks

Barracks.Size  = 32
Barracks.Costs = { Gold = 50, Metal = 40, Aether = 0 }
Barracks.IncomeBonusGold = 2
Barracks.IncomeBonusMetal = 2

setmetatable(Barracks, { __index = SpawningStructure })

---Creates a new Barracks.
---@return Barracks
function Barracks:new()
	local instance = SpawningStructure.new(self, "Barracks",
		280,            -- Health
		18,             -- Armor
		Barracks.Size,  -- Size
		3,              -- SpawnRate
		Knight,
		Barracks.Costs,
		Barracks.IncomeBonusGold,
		Barracks.IncomeBonusMetal,
		0
	)
	return instance
end

return Barracks
