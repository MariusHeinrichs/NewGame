--- Mage unit — ranged, fragile, high damage, slow attack speed.

local RangedUnit = require("Objects.Units.base.rangedUnit")

---@class Mage : RangedUnit
local Mage = {}
Mage.__index = Mage

setmetatable(Mage, { __index = RangedUnit })

---Creates a new Mage.
---@param name string | nil
---@return Mage
function Mage:new(name)
	local instance = RangedUnit.new(self, name,
		70,   -- Health
		25,   -- Damage
		2,    -- Armor
		1.8,  -- Speed
		9,    -- Size
		100,  -- AttackRange
		200,  -- AggroRange
		0.6,   -- AttackSpeed
		"unit" -- PreferedTarget
	)
	instance.ProjectileSpeed = 190
	instance.ProjectileRadius = 3.5
	instance.SplashRadius = 22
	instance.SplashDamageMultiplier = 0.55
	instance.ProjectileStyle = "fireball"
	return instance
end

return Mage
