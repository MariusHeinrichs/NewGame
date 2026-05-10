--- MageTower structure - ranged defense with strong splash.

local RangeStructure = require("Objects.Structures.base.rangeStructure")

---@class MageTower : RangeStructure
local MageTower = {}
MageTower.__index = MageTower

MageTower.Size = 26
MageTower.Costs = { Gold = 55, Metal = 15, Aether = 22 }
MageTower.IncomeBonusGold = 0
MageTower.IncomeBonusMetal = 0

setmetatable(MageTower, { __index = RangeStructure })

---Creates a new MageTower.
---@return MageTower
function MageTower:new()
	local instance = RangeStructure.new(
		self,
		"MageTower",
		150, -- Health
		6, -- Armor
		MageTower.Size,
		16, -- Damage
		190, -- AttackRange
		1.25, -- AttackSpeed
		200, -- ProjectileSpeed
		3.5, -- ProjectileRadius
		"fireball",
		28, -- SplashRadius
		0.55, -- SplashDamageMultiplier
		MageTower.Costs,
		MageTower.IncomeBonusGold,
		MageTower.IncomeBonusMetal
	)
	return instance
end

return MageTower
