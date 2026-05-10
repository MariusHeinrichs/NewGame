--- RangeStructure class for structures that attack using projectiles.

local Structure = require("Objects.Structures.base.structure")
local Projectile = require("Objects.Projectiles.base.projectile")

local DEFAULTS = {
	Damage = 0,
	AttackRange = 0,
	AttackSpeed = 1,
	ProjectileSpeed = 220,
	ProjectileStyle = "orb",
	SplashRadius = 0,
	SplashDamageMultiplier = 0,
}

---@class RangeStructure : Structure
---@field Damage number
---@field AttackRange number
---@field AttackSpeed number
---@field CurrentTarget Unit | Structure | nil
---@field ProjectileSpeed number
---@field ProjectileRadius number
---@field ProjectileStyle string
---@field SplashRadius number
---@field SplashDamageMultiplier number
local RangeStructure = {}
RangeStructure.__index = RangeStructure

setmetatable(RangeStructure, { __index = Structure })

---@generic T : RangeStructure
---@param self T
---@param Name string | nil
---@param Health number | nil
---@param Armor number | nil
---@param Size number | nil
---@param Damage number | nil
---@param AttackRange number | nil
---@param AttackSpeed number | nil
---@param ProjectileSpeed number | nil
---@param ProjectileRadius number | nil
---@param ProjectileStyle string | nil
---@param SplashRadius number | nil
---@param SplashDamageMultiplier number | nil
---@param Costs table | nil
---@param IncomeBonusGold number | nil
---@param IncomeBonusMetal number | nil
---@param Team "player" | "enemy" | nil
---@return T
function RangeStructure:new(Name, Health, Armor, Size, Damage, AttackRange, AttackSpeed, ProjectileSpeed, ProjectileRadius, ProjectileStyle, SplashRadius, SplashDamageMultiplier, Costs, IncomeBonusGold, IncomeBonusMetal, Team)
	local newStructure = Structure.new(self, Name, Health, Armor, Size, Costs, IncomeBonusGold, IncomeBonusMetal, Team)
	newStructure.Damage = Damage or DEFAULTS.Damage
	newStructure.AttackRange = AttackRange or DEFAULTS.AttackRange
	newStructure.AttackSpeed = AttackSpeed or DEFAULTS.AttackSpeed
	newStructure.CurrentTarget = nil
	newStructure.ProjectileSpeed = ProjectileSpeed or DEFAULTS.ProjectileSpeed
	newStructure.ProjectileRadius = ProjectileRadius or math.max(2, (newStructure.Size or 10) * 0.2)
	newStructure.ProjectileStyle = ProjectileStyle or DEFAULTS.ProjectileStyle
	newStructure.SplashRadius = SplashRadius or DEFAULTS.SplashRadius
	newStructure.SplashDamageMultiplier = SplashDamageMultiplier or DEFAULTS.SplashDamageMultiplier
	return newStructure
end

---@param target Unit | Structure
---@param entities WorldEntities
function RangeStructure:PerformAttack(target, entities)
	if not entities or type(entities.AddProjectile) ~= "function" then
		return
	end

	local projectile = Projectile:new(
		self.Position.X,
		self.Position.Y,
		target,
		self.ProjectileSpeed or DEFAULTS.ProjectileSpeed,
		self.ProjectileRadius or math.max(2, self.Size * 0.2),
		self.Damage,
		self.SplashRadius or DEFAULTS.SplashRadius,
		self.SplashDamageMultiplier or DEFAULTS.SplashDamageMultiplier,
		self.ProjectileStyle or DEFAULTS.ProjectileStyle,
		self.Team
	)
	entities:AddProjectile(projectile)
end

---@param dt number
---@param entities WorldEntities
function RangeStructure:UpdateCombat(dt, entities)
	if self.Damage <= 0 or self.AttackRange <= 0 or self.AttackSpeed <= 0 then
		return
	end

	self.AttackTimer = (self.AttackTimer or 0) + dt
	if self.AttackTimer < self.AttackSpeed then
		return
	end

	local target = self.CurrentTarget
	if not target or not self:IsTargetAlive(target) or not self:IsTargetEnemy(target) or not self:IsTargetInRange(target) then
		target = self:SearchForEnemyToAttack(entities)
		self.CurrentTarget = target
	end

	if not target then
		return
	end

	self.AttackTimer = 0
	self:PerformAttack(target, entities)
end

return RangeStructure
