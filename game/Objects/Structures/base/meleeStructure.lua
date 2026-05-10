--- MeleeStructure class for structures that attack in close range.

local Structure = require("Objects.Structures.base.structure")

local DEFAULTS = {
	Damage = 0,
	AttackRange = 0,
	AttackSpeed = 1,
}

---@class MeleeStructure : Structure
---@field Damage number
---@field AttackRange number
---@field AttackSpeed number
---@field CurrentTarget Unit | Structure | nil
local MeleeStructure = {}
MeleeStructure.__index = MeleeStructure

setmetatable(MeleeStructure, { __index = Structure })

---@generic T : MeleeStructure
---@param self T
---@param Name string | nil
---@param Health number | nil
---@param Armor number | nil
---@param Size number | nil
---@param Damage number | nil
---@param AttackRange number | nil
---@param AttackSpeed number | nil
---@param Costs table | nil
---@param IncomeBonusGold number | nil
---@param IncomeBonusMetal number | nil
---@param Team "player" | "enemy" | nil
---@return T
function MeleeStructure:new(Name, Health, Armor, Size, Damage, AttackRange, AttackSpeed, Costs, IncomeBonusGold, IncomeBonusMetal, Team)
	local newStructure = Structure.new(self, Name, Health, Armor, Size, Costs, IncomeBonusGold, IncomeBonusMetal, Team)
	newStructure.Damage = Damage or DEFAULTS.Damage
	newStructure.AttackRange = AttackRange or DEFAULTS.AttackRange
	newStructure.AttackSpeed = AttackSpeed or DEFAULTS.AttackSpeed
	newStructure.CurrentTarget = nil
	return newStructure
end

---@param target Unit | Structure
function MeleeStructure:PerformAttack(target)
	local dmg = math.max(1, self.Damage - (target.Armor or 0))
	target.Health = target.Health - dmg
	if type(target.OnDamaged) == "function" then
		target:OnDamaged(self)
	end
end

---@param dt number
---@param entities WorldEntities
function MeleeStructure:UpdateCombat(dt, entities)
	if self.Damage <= 0 or self.AttackRange <= 0 or self.AttackSpeed <= 0 then
		return
	end

	self.AttackTimer = (self.AttackTimer or 0) + dt
	if self.AttackTimer < self.AttackSpeed then
		return
	end

	local target = self.CurrentTarget
	if self:CanKeepRetaliationTarget(self.RetaliationTarget) then
		target = self.RetaliationTarget
		self.CurrentTarget = target
	elseif not target or not self:IsTargetAlive(target) or not self:IsTargetEnemy(target) or not self:IsTargetInRange(target) then
		self.RetaliationTarget = nil
		target = self:SearchForEnemyToAttack(entities)
		self.CurrentTarget = target
	end

	if not target then
		return
	end

	self.AttackTimer = 0
	self:PerformAttack(target)
end

return MeleeStructure
