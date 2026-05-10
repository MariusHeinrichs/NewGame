--- BarbarianCamp structure — spawns Barbarians.

local SpawningStructure = require("Objects.Structures.base.spawningStructure")
local UnitRegistry = require("Objects.Units.registry.unitRegistry")

local Barbarian = UnitRegistry.GetByType("Barbarian")

---@class BarbarianCamp : SpawningStructure
local BarbarianCamp = {}
BarbarianCamp.__index = BarbarianCamp

BarbarianCamp.Size  = 28
BarbarianCamp.Costs = { Gold = 30, Metal = 20, Aether = 0 }
BarbarianCamp.IncomeBonusGold = 2
BarbarianCamp.IncomeBonusMetal = 1

setmetatable(BarbarianCamp, { __index = SpawningStructure })

---Creates a new BarbarianCamp.
---@return BarbarianCamp
function BarbarianCamp:new()
	local instance = SpawningStructure.new(self, "BarbarianCamp",
		220,                 -- Health
		12,                  -- Armor
		BarbarianCamp.Size,  -- Size
		2,                   -- SpawnRate
		Barbarian,
		BarbarianCamp.Costs,
		BarbarianCamp.IncomeBonusGold,
		BarbarianCamp.IncomeBonusMetal,
		0
	)
	return instance
end

return BarbarianCamp
