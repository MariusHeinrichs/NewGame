--- Knight unit — melee tank, high health and armor, slow attack speed.

local MeleeUnit = require("Objects.Units.base.meleeUnit")

---@class Knight : MeleeUnit
local Knight = {}
Knight.__index = Knight

setmetatable(Knight, { __index = MeleeUnit })

---Creates a new Knight.
---@param name string | nil
---@return Knight
function Knight:new(name)
	return MeleeUnit.new(self, name,
		200,  -- Health
		12,   -- Damage
		15,   -- Armor
		1.5,  -- Speed
		12,   -- Size
		30,   -- AttackRange
		120,  -- AggroRange
		0.8   -- AttackSpeed
	)
end

return Knight
