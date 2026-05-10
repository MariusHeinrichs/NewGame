--- ArcherTower structure — spawns Archers.

local Structure = require("Objects.Structures.base.structure")
local UnitRegistry = require("Objects.Units.registry.unitRegistry")

local Archer = UnitRegistry.GetByType("Archer")

---@class ArcherTower : Structure
local ArcherTower = {}
ArcherTower.__index = ArcherTower

ArcherTower.Size  = 24
ArcherTower.Costs = { Gold = 25, Metal = 10, Aether = 5 }

setmetatable(ArcherTower, { __index = Structure })

---Creates a new ArcherTower.
---@return ArcherTower
function ArcherTower:new()
	local instance = Structure.new(self, "ArcherTower",
		180,                -- Health
		8,                  -- Armor
		ArcherTower.Size,   -- Size
		1.5,                -- SpawnRate
		ArcherTower.Costs
	)
	instance.UnitClass = Archer
	return instance
end

return ArcherTower
