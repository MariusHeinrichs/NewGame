--- BarbarianCamp structure — spawns Barbarians.

local Structure = require("Objects.Structures.base.structure")
local UnitRegistry = require("Objects.Units.registry.unitRegistry")

local Barbarian = UnitRegistry.GetByType("Barbarian")

---@class BarbarianCamp : Structure
local BarbarianCamp = {}
BarbarianCamp.__index = BarbarianCamp

BarbarianCamp.Size  = 28
BarbarianCamp.Costs = { Gold = 30, Metal = 20, Aether = 0 }

setmetatable(BarbarianCamp, { __index = Structure })

---Creates a new BarbarianCamp.
---@return BarbarianCamp
function BarbarianCamp:new()
	local instance = Structure.new(self, "BarbarianCamp",
		220,                 -- Health
		12,                  -- Armor
		BarbarianCamp.Size,  -- Size
		2,                   -- SpawnRate
		BarbarianCamp.Costs
	)
	instance.UnitClass = Barbarian
	return instance
end

return BarbarianCamp
