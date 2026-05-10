--- Structure class representing a game structure with health, armor, and size attributes.

local Object = require("BaseClasses.object")
local DEFAULTS = {
	Health = 100,
	Armor = 5,
	Size = 10,
	Costs = { Gold = 0, Metal = 0, Aether = 0 },
	IncomeBonusGold = 0,
	IncomeBonusMetal = 0,
}

---@class Structure : Object
---@field Health number
---@field MaxHealth number
---@field Armor number
---@field Size number
---@field Costs table
---@field IncomeBonusGold number
---@field IncomeBonusMetal number
---@field IsStructure boolean
---@field Team "player" | "enemy"
local Structure = {}
Structure.__index = Structure

setmetatable(Structure, { __index = Object })

---Creates a new Structure.
---@generic T : Structure
---@param self T
---@param Name string | nil
---@param Health number | nil
---@param Armor number | nil
---@param Size number | nil
---@param Costs table | nil
---@param IncomeBonusGold number | nil
---@param IncomeBonusMetal number | nil
---@param Team "player" | "enemy" | nil
---@return T
function Structure:new(Name, Health, Armor, Size, Costs, IncomeBonusGold, IncomeBonusMetal, Team)
	local newStructure = Object.new(self, Name)
	newStructure.Health = Health or DEFAULTS.Health
	newStructure.MaxHealth = newStructure.Health
	newStructure.Armor = Armor or DEFAULTS.Armor
	newStructure.Size = Size or DEFAULTS.Size
	newStructure.Costs = Costs or DEFAULTS.Costs
	newStructure.IncomeBonusGold = IncomeBonusGold or DEFAULTS.IncomeBonusGold
	newStructure.IncomeBonusMetal = IncomeBonusMetal or DEFAULTS.IncomeBonusMetal
	newStructure.IsStructure = true
	newStructure.Team = Team or "player"
	return newStructure
end

---@param target Unit | Structure | nil
---@return boolean
function Structure:IsTargetAlive(target)
	return target ~= nil and (target.Health or 0) > 0
end

---@param target Unit | Structure | nil
---@return boolean
function Structure:IsTargetEnemy(target)
	return target ~= nil and target.Team ~= nil and target.Team ~= self.Team
end

---@param target Unit | Structure
---@return number
function Structure:GetTargetRadius(target)
	if target.IsStructure == true then
		return (target.Size or 0) / 2
	end
	return target.Size or 0
end

---@param target Unit | Structure
---@return boolean
function Structure:IsTargetInRange(target)
	local dx = target.Position.X - self.Position.X
	local dy = target.Position.Y - self.Position.Y
	local distSq = dx * dx + dy * dy
	local attackRange = rawget(self, "AttackRange") or 0
	local range = attackRange + self:GetTargetRadius(target)
	return distSq <= (range * range)
end

---@param target Unit | Structure
---@return boolean
function Structure:IsTargetInAggroRange(target)
	local dx = target.Position.X - self.Position.X
	local dy = target.Position.Y - self.Position.Y
	local distSq = dx * dx + dy * dy
	local aggroRange = rawget(self, "AggroRange") or 0
	local range = aggroRange + self:GetTargetRadius(target)
	return distSq <= (range * range)
end

---@param entities WorldEntities
---@return Unit | Structure | nil
function Structure:SearchForEnemy(entities)
	return entities:FindClosestEnemy(self, function(target)
		return self:IsTargetInAggroRange(target)
	end)
end

---@param entities WorldEntities
---@return Unit | Structure | nil
function Structure:SearchForEnemyToAttack(entities)
	return entities:FindClosestEnemy(self, function(target)
		return self:IsTargetInRange(target)
	end)
end

---@param target Unit | Structure | nil
---@return boolean
function Structure:CanKeepCurrentTarget(target)
	if not target then
		return false
	end
	if not self:IsTargetAlive(target) or not self:IsTargetEnemy(target) then
		return false
	end
	return self:IsTargetInAggroRange(target)
end

---@param entities WorldEntities
---@return Unit | Structure | nil
function Structure:RefreshTarget(entities)
	if self:CanKeepCurrentTarget(self.CurrentTarget) then
		return self.CurrentTarget
	end
	self.CurrentTarget = self:SearchForEnemy(entities)
	return self.CurrentTarget
end

---@param dt number
---@param entities WorldEntities
function Structure:UpdateCombat(dt, entities)
	local _ = dt
	local _entities = entities
	return
end

---@param dt number
---@return Unit | nil
function Structure:SpawnUnit(dt)
	local _ = dt
	return nil
end

--- Draws the structure at its current position.
function Structure:Draw()
	if self.Team == "enemy" then
		love.graphics.setColor(0.8, 0.3, 0.2)
	else
		love.graphics.setColor(0.5, 0.5, 0.5)
	end
	love.graphics.rectangle("fill", self.Position.X - self.Size / 2, self.Position.Y - self.Size / 2, self.Size,
		self.Size)
	love.graphics.setColor(1, 1, 1)
end

return Structure
