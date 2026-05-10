--- Barracks structure — spawns Knights.

local Structure = require("Objects.Structures.base.structure")
local UnitRegistry = require("Objects.Units.registry.unitRegistry")

local Knight = UnitRegistry.GetByType("Knight")

---@class Barracks : Structure
local Barracks = {}
Barracks.__index = Barracks

Barracks.Size  = 32
Barracks.Costs = { Gold = 50, Metal = 40, Aether = 0 }
Barracks.IncomeBonusGold = 2
Barracks.IncomeBonusMetal = 2

setmetatable(Barracks, { __index = Structure })

---Creates a new Barracks.
---@return Barracks
function Barracks:new()
	local instance = Structure.new(self, "Barracks",
		280,            -- Health
		18,             -- Armor
		Barracks.Size,  -- Size
		3,              -- SpawnRate
		Barracks.Costs
	)
	instance.IncomeBonusGold = Barracks.IncomeBonusGold
	instance.IncomeBonusMetal = Barracks.IncomeBonusMetal
	instance.UnitClass = Knight
	return instance
end

return Barracks
