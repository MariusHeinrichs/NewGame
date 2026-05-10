--- ArcherCamp structure - spawns Archers.

local SpawningStructure = require("Objects.Structures.base.spawningStructure")
local UnitRegistry = require("Objects.Units.registry.unitRegistry")

local Archer = UnitRegistry.GetByType("Archer")

---@class ArcherCamp : SpawningStructure
local ArcherCamp = {}
ArcherCamp.__index = ArcherCamp

ArcherCamp.Size  = 24
ArcherCamp.Costs = { Gold = 25, Metal = 10, Aether = 5 }
ArcherCamp.IncomeBonusGold = 1
ArcherCamp.IncomeBonusMetal = 2

setmetatable(ArcherCamp, { __index = SpawningStructure })

---Creates a new ArcherCamp.
---@return ArcherCamp
function ArcherCamp:new()
	local instance = SpawningStructure.new(self, "ArcherCamp",
		180,               -- Health
		8,                 -- Armor
		ArcherCamp.Size,   -- Size
		1.5,               -- SpawnRate
		Archer,
		ArcherCamp.Costs,
		ArcherCamp.IncomeBonusGold,
		ArcherCamp.IncomeBonusMetal,
		0
	)
	return instance
end

return ArcherCamp
