--- Structure class representing a game structure with health, armor, and size attributes.

local Object = require("BaseClasses.object")
local TargetingSystem = require("src.targetingSystem")
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
---@field PathId string | nil
---@field CurrentTarget Unit | Structure | nil
---@field RetaliationTarget Unit | Structure | nil
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
	newStructure.PathId = nil
	newStructure.CurrentTarget = nil
	newStructure.RetaliationTarget = nil
	return newStructure
end

--- Checks if the target is alive.
---@param target Unit | Structure | nil
---@return boolean
function Structure:IsTargetAlive(target)
	return TargetingSystem.IsTargetAlive(target)
end

--- Checks if the target is an enemy.
---@param target Unit | Structure | nil
---@return boolean
function Structure:IsTargetEnemy(target)
	return TargetingSystem.IsTargetEnemy(self, target)
end

--- Gets the radius of the target.
---@param target Unit | Structure
---@return number
function Structure:GetTargetRadius(target)
	return TargetingSystem.GetTargetRadius(target)
end

--- Checks if the target is within attack range.
---@param target Unit | Structure
---@return boolean
function Structure:IsTargetInRange(target)
	return TargetingSystem.IsTargetWithinRange(self, target, rawget(self, "AttackRange") or 0)
end

--- Checks if the target is within aggro range.
---@param target Unit | Structure
---@return boolean
function Structure:IsTargetInAggroRange(target)
	return TargetingSystem.IsTargetWithinRange(self, target, rawget(self, "AggroRange") or 0)
end

--- Searches for the closest enemy within aggro range.
---@param entities WorldEntities
---@return Unit | Structure | nil
function Structure:SearchForEnemy(entities)
	return TargetingSystem.SearchForEnemy(self, entities, function(target)
		return self:IsTargetInAggroRange(target)
	end)
end

--- Searches for the closest enemy within attack range.
---@param entities WorldEntities
---@return Unit | Structure | nil
function Structure:SearchForEnemyToAttack(entities)
	return TargetingSystem.SearchForEnemy(self, entities, function(target)
		return self:IsTargetInRange(target)
	end)
end

--- Checks if the structure can keep its current target.
---@param target Unit | Structure | nil
---@return boolean
function Structure:CanKeepCurrentTarget(target)
	return TargetingSystem.CanKeepTarget(self, target, {
		range = rawget(self, "AggroRange") or 0,
	})
end

--- Checks if the structure can keep its retaliation target.
---@param target Unit | Structure | nil
---@return boolean
function Structure:CanKeepRetaliationTarget(target)
	return TargetingSystem.CanKeepTarget(self, target, {
		range = rawget(self, "AttackRange") or 0,
	})
end

--- Locks retaliation to the first valid attacker until that target becomes invalid.
---@param attacker Unit | Structure | nil
function Structure:OnDamaged(attacker)
	TargetingSystem.OnDamaged(self, attacker, Structure.CanKeepRetaliationTarget)
end

--- Refreshes the current target of the structure.
---@param entities WorldEntities
---@return Unit | Structure | nil
function Structure:RefreshTarget(entities)
	return TargetingSystem.RefreshTarget(self, entities, {
		canKeepCurrentTarget = Structure.CanKeepCurrentTarget,
		canKeepRetaliationTarget = Structure.CanKeepRetaliationTarget,
		searchForEnemy = Structure.SearchForEnemy,
	})
end

--- Updates the combat state of the structure.
---@param dt number
---@param entities WorldEntities
function Structure:UpdateCombat(dt, entities)
	local _ = dt
	local _entities = entities
	return
end

--- Spawns a unit if the spawn timer has reached the spawn rate.
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
