--- Barbarian unit — melee, balanced stats, moderate attack speed.

local MeleeUnit = require("Objects.Units.base.meleeUnit")

---@class Barbarian : MeleeUnit
local Barbarian = {}
Barbarian.__index = Barbarian

setmetatable(Barbarian, { __index = MeleeUnit })

---Creates a new Barbarian.
---@param name string | nil
---@return Barbarian
function Barbarian:new(name)
	return MeleeUnit.new(self, name,
		120,  -- Health
		15,   -- Damage
		5,    -- Armor
		2.5,  -- Speed
		10,   -- Size
		40,   -- AttackRange
		130,  -- AggroRange
		1.0,   -- AttackSpeed
		"unit" -- PreferedTarget
	)
end

return Barbarian
