--- MeleeUnit base class for direct-hit attacks.

local Unit = require("Objects.Units.base.unit")

---@class MeleeUnit : Unit
local MeleeUnit = {}
MeleeUnit.__index = MeleeUnit

setmetatable(MeleeUnit, { __index = Unit })

--- Executes a melee hit immediately on the target.
---@param target Unit | Structure
---@param entities WorldEntities
function MeleeUnit:PerformAttack(target, entities)
	local _ = entities
	local dmg = math.max(1, self.Damage - (target.Armor or 0))
	target.Health = target.Health - dmg
end

return MeleeUnit
