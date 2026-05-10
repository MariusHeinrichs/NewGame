--- Knight unit — melee tank, high health and armor, slow attack speed.

local Unit = require("Objects.Units.base.unit")

---@class Knight : Unit
local Knight = {}
Knight.__index = Knight

setmetatable(Knight, { __index = Unit })

---Creates a new Knight.
---@param name string | nil
---@return Knight
function Knight:new(name)
	return Unit.new(self, name,
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
