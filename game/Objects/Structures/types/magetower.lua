--- MageTower structure — spawns Mages.

local Structure = require("Objects.Structures.base.structure")
local UnitRegistry = require("Objects.Units.registry.unitRegistry")

local Mage = UnitRegistry.GetByType("Mage")

---@class MageTower : Structure
local MageTower = {}
MageTower.__index = MageTower

MageTower.Size  = 26
MageTower.Costs = { Gold = 20, Metal = 5, Aether = 15 }

setmetatable(MageTower, { __index = Structure })

---Creates a new MageTower.
---@return MageTower
function MageTower:new()
	local instance = Structure.new(self, "MageTower",
		160,              -- Health
		6,                -- Armor
		MageTower.Size,   -- Size
		1.2,              -- SpawnRate
		MageTower.Costs
	)
	instance.UnitClass = Mage
	return instance
end

return MageTower
