--- TownHall structure — the player's base, does not spawn units.

local MeleeStructure = require("Objects.Structures.base.meleeStructure")

---@class TownHall : MeleeStructure
local TownHall = {}
TownHall.__index = TownHall

TownHall.Size  = 70
TownHall.Costs = { Gold = 0, Metal = 0, Aether = 0 }
TownHall.IncomeBonusGold = 0
TownHall.IncomeBonusMetal = 0

setmetatable(TownHall, { __index = MeleeStructure })

---Creates a new TownHall.
---@return TownHall
function TownHall:new()
	local instance = MeleeStructure.new(self, "TownHall",
		500,           -- Health
		20,            -- Armor
		TownHall.Size, -- Size
		12,            -- Damage
		42,            -- AttackRange
		1.1,           -- AttackSpeed
		TownHall.Costs,
		TownHall.IncomeBonusGold,
		TownHall.IncomeBonusMetal
	)
	return instance
end

return TownHall
