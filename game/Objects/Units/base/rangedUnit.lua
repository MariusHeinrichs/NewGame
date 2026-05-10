--- RangedUnit base class for ranged attack behavior.

local Unit = require("Objects.Units.base.unit")
local Projectile = require("Objects.Projectiles.base.projectile")

---@class RangedUnit : Unit
---@field ProjectileSpeed number | nil
---@field ProjectileRadius number | nil
---@field SplashRadius number | nil
---@field SplashDamageMultiplier number | nil
---@field ProjectileStyle string | nil
local RangedUnit = {}
RangedUnit.__index = RangedUnit

setmetatable(RangedUnit, { __index = Unit })

--- Executes ranged attack behavior.
---@param target Unit | Structure
---@param entities WorldEntities
function RangedUnit:PerformAttack(target, entities)
	if not entities or type(entities.AddProjectile) ~= "function" then
		return
	end

	local projectileSpeed = self.ProjectileSpeed or 230
	local projectileRadius = self.ProjectileRadius or math.max(2, self.Size * 0.3)
	local projectile = Projectile:new(
		self.Position.X,
		self.Position.Y,
		target,
		projectileSpeed,
		projectileRadius,
		self.Damage,
		self.SplashRadius,
		self.SplashDamageMultiplier,
		self.ProjectileStyle,
		self.Team
	)
	entities:AddProjectile(projectile)
end

return RangedUnit
