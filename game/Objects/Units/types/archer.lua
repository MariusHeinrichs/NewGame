--- Archer unit — ranged, fragile, fast attack speed.

local Unit = require("Objects.Units.base.unit")

---@class Archer : Unit
local Archer = {}
Archer.__index = Archer

setmetatable(Archer, { __index = Unit })

---Creates a new Archer.
---@param name string | nil
---@return Archer
function Archer:new(name)
	return Unit.new(self, name,
		80,   -- Health
		18,   -- Damage
		3,    -- Armor
		2.0,  -- Speed
		8,    -- Size
		120,  -- AttackRange
		220,  -- AggroRange
		1.5   -- AttackSpeed
	)
end

return Archer
