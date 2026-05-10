--- ArcherTower structure - ranged defense without splash.

local RangeStructure = require("Objects.Structures.base.rangeStructure")

---@class ArcherTower : RangeStructure
local ArcherTower = {}
ArcherTower.__index = ArcherTower

ArcherTower.Size = 24
ArcherTower.Costs = { Gold = 40, Metal = 20, Aether = 8 }
ArcherTower.IncomeBonusGold = 0
ArcherTower.IncomeBonusMetal = 0

setmetatable(ArcherTower, { __index = RangeStructure })

---Creates a new ArcherTower.
---@return ArcherTower
function ArcherTower:new()
	local instance = RangeStructure.new(
		self,
		"ArcherTower",
		170, -- Health
		9, -- Armor
		ArcherTower.Size,
		10, -- Damage
		185, -- AttackRange
		0.9, -- AttackSpeed
		340, -- ProjectileSpeed
		2.4, -- ProjectileRadius
		"arrow",
		0, -- SplashRadius
		0, -- SplashDamageMultiplier
		ArcherTower.Costs,
		ArcherTower.IncomeBonusGold,
		ArcherTower.IncomeBonusMetal
	)
	return instance
end

return ArcherTower
