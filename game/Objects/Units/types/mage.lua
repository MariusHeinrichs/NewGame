--- Mage unit — ranged, fragile, high damage, slow attack speed.

local Unit = require("Objects.Units.base.unit")

---@class Mage : Unit
local Mage = {}
Mage.__index = Mage

setmetatable(Mage, { __index = Unit })

---Creates a new Mage.
---@param name string | nil
---@return Mage
function Mage:new(name)
	return Unit.new(self, name,
		70,   -- Health
		25,   -- Damage
		2,    -- Armor
		1.8,  -- Speed
		9,    -- Size
		100,  -- Range
		0.6   -- AttackSpeed
	)
end

return Mage
