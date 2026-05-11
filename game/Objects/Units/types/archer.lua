--- Archer unit — ranged, fragile, fast attack speed.

local RangedUnit = require("Objects.Units.base.rangedUnit")

---@class Archer : RangedUnit
local Archer = {}
Archer.__index = Archer

setmetatable(Archer, { __index = RangedUnit })

---Creates a new Archer.
---@param name string | nil
---@return Archer
function Archer:new(name)
	local instance = RangedUnit.new(self, name,
		80, -- Health
		18, -- Damage
		3, -- Armor
		2.0, -- Speed
		8, -- Size
		120, -- AttackRange
		220, -- AggroRange
		1.5, -- AttackSpeed
		"unit" -- PreferedTarget
	)
	instance.ProjectileSpeed = 320
	instance.ProjectileRadius = 2.5
	instance.SplashRadius = 0
	instance.SplashDamageMultiplier = 0
	instance.ProjectileStyle = "arrow"
	return instance
end

return Archer
