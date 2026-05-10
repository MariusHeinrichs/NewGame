--- Barbarian unit — melee, balanced stats, moderate attack speed.

local Unit = require("Objects.Units.base.unit")

---@class Barbarian : Unit
local Barbarian = {}
Barbarian.__index = Barbarian

setmetatable(Barbarian, { __index = Unit })

---Creates a new Barbarian.
---@param name string | nil
---@return Barbarian
function Barbarian:new(name)
	return Unit.new(self, name,
		120,  -- Health
		15,   -- Damage
		5,    -- Armor
		2.5,  -- Speed
		10,   -- Size
		40,   -- Range
		1.0   -- AttackSpeed
	)
end

return Barbarian
