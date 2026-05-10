--- TownHall structure — the player's base, does not spawn units.

local Structure = require("Objects.Structures.base.structure")

---@class TownHall : Structure
local TownHall = {}
TownHall.__index = TownHall

TownHall.Size  = 70
TownHall.Costs = { Gold = 0, Metal = 0, Aether = 0 }

setmetatable(TownHall, { __index = Structure })

---Creates a new TownHall.
---@return TownHall
function TownHall:new()
	local instance = Structure.new(self, "TownHall",
		500,           -- Health
		20,            -- Armor
		TownHall.Size, -- Size
		0,             -- SpawnRate (no spawning)
		TownHall.Costs
	)
	return instance
end

return TownHall
