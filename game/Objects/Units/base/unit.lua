--- Unit class representing a game unit with health, damage, armor, speed, size, aggro range, attack range, and attack speed attributes.

local Object = require("BaseClasses.object")
local NavigationSystem = require("src.navigationSystem")
local SteeringSystem = require("src.steeringSystem")

local DEFAULTS = {
	Health = 100,
	Damage = 10,
	Armor = 5,
	Speed = 2,
	Size = 10,
	AttackRange = 50,
	AggroRange = 120,
	AttackSpeed = 1,
}

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@return number
local function distanceSquared(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	return dx * dx + dy * dy
end

---@class Unit : Object
---@field Health number
---@field MaxHealth number
---@field Damage number
---@field Armor number
---@field Speed number
---@field Size number
---@field AttackRange number
---@field AggroRange number
---@field AttackSpeed number
---@field Team "player" | "enemy"
---@field PathId string | nil
---@field PathWaypointIndex number | nil
---@field HadAggroTarget boolean
---@field CurrentTarget Unit | Structure | nil
---@field RetaliationTarget Unit | Structure | nil
local Unit = {}
Unit.__index = Unit

setmetatable(Unit, { __index = Object })

---Creates a new Unit.
---@generic T : Unit
---@param self T
---@param Name string | nil
---@param Health number | nil
---@param Damage number | nil
---@param Armor number | nil
---@param Speed number | nil
---@param Size number | nil
---@param AttackRange number | nil
---@param AggroRange number | nil
---@param AttackSpeed number | nil
---@param Team "player" | "enemy" | nil
---@return T
function Unit:new(Name, Health, Damage, Armor, Speed, Size, AttackRange, AggroRange, AttackSpeed, Team)
	local newUnit = Object.new(self, Name)
	newUnit.Health = Health or DEFAULTS.Health
	newUnit.MaxHealth = newUnit.Health
	newUnit.Damage = Damage or DEFAULTS.Damage
	newUnit.Armor = Armor or DEFAULTS.Armor
	newUnit.Speed = Speed or DEFAULTS.Speed
	newUnit.Size = Size or DEFAULTS.Size
	newUnit.AttackRange = AttackRange or DEFAULTS.AttackRange
	newUnit.AggroRange = AggroRange or DEFAULTS.AggroRange
	newUnit.AttackSpeed = AttackSpeed or DEFAULTS.AttackSpeed
	newUnit.Team = Team or "player"
	newUnit.PathId = nil
	newUnit.PathWaypointIndex = nil
	newUnit.HadAggroTarget = false
	newUnit.CurrentTarget = nil
	newUnit.RetaliationTarget = nil
	return newUnit
end

---@param target Unit | Structure | nil
---@return boolean
function Unit:CanKeepRetaliationTarget(target)
	if not target then
		return false
	end
	if not self:IsTargetAlive(target) or not self:IsTargetEnemy(target) then
		return false
	end
	return true
end

--- Locks retaliation to the first valid attacker until that target is no longer valid.
---@param attacker Unit | Structure | nil
function Unit:OnDamaged(attacker)
	if not attacker then
		return
	end
	if not self:IsTargetEnemy(attacker) then
		return
	end
	if self:CanKeepRetaliationTarget(self.RetaliationTarget) then
		return
	end
	self.RetaliationTarget = attacker
	self.CurrentTarget = attacker
end

---@param target Unit | Structure | nil
---@return boolean
function Unit:IsTargetAlive(target)
	return target ~= nil and (target.Health or 0) > 0
end

---@param target Unit | Structure | nil
---@return boolean
function Unit:IsTargetEnemy(target)
	return target ~= nil and target.Team ~= nil and target.Team ~= self.Team
end

--- Returns the next position for the given direction without applying it.
---@param direction "up" | "down" | "left" | "right"
---@return number, number
function Unit:GetNextPosition(direction)
	local nextX = self.Position.X
	local nextY = self.Position.Y

	if direction == "up" then
		nextY = nextY - self.Speed
	elseif direction == "down" then
		nextY = nextY + self.Speed
	elseif direction == "left" then
		nextX = nextX - self.Speed
	elseif direction == "right" then
		nextX = nextX + self.Speed
	end

	return nextX, nextY
end

--- Moves the unit to an absolute position.
---@param x number
---@param y number
function Unit:MoveTo(x, y)
	self.Position.X = x
	self.Position.Y = y
	self:UpdateHealthFromWindowBounds()
end

--- Sets Health to 0 when the unit leaves the current window.
function Unit:UpdateHealthFromWindowBounds()
	local width, height = love.graphics.getDimensions()
	if self.Position.X < 0 or self.Position.X > width or self.Position.Y < 0 or self.Position.Y > height then
		self.Health = 0
	end
end

--- Returns target radius used for range checks.
---@param target Unit | Structure
---@return number
function Unit:GetTargetRadius(target)
	if target.IsStructure == true then
		return (target.Size or 0) / 2
	end
	return target.Size or 0
end

--- Returns true when target is inside attack range.
---@param target Unit | Structure
---@return boolean
function Unit:IsTargetInRange(target)
	local distSq = distanceSquared(self.Position.X, self.Position.Y, target.Position.X, target.Position.Y)
	local range = self.AttackRange + self:GetTargetRadius(target)
	return distSq <= (range * range)
end

--- Returns true when target is inside aggro range.
---@param target Unit | Structure
---@return boolean
function Unit:IsTargetInAggroRange(target)
	local distSq = distanceSquared(self.Position.X, self.Position.Y, target.Position.X, target.Position.Y)
	local range = self.AggroRange + self:GetTargetRadius(target)
	return distSq <= (range * range)
end

--- Searches for the closest enemy unit or structure within aggro range.
---@param entities WorldEntities
---@return Unit | Structure | nil
function Unit:SearchForEnemy(entities)
	return entities:FindClosestEnemy(self, function(target)
		return self:IsTargetInAggroRange(target)
	end)
end

--- Searches for the closest enemy unit or structure within attack range.
---@param entities WorldEntities
---@return Unit | Structure | nil
function Unit:SearchForEnemyToAttack(entities)
	return entities:FindClosestEnemy(self, function(target)
		return self:IsTargetInRange(target)
	end)
end

--- Returns the enemy TownHall if one exists.
---@param entities WorldEntities
---@return Structure | nil
function Unit:GetEnemyTownHall(entities)
	return entities:GetEnemyTownHall(self.Team)
end

--- Returns true when a target can be kept as the current target.
---@param target Unit | Structure | nil
---@return boolean
function Unit:CanKeepCurrentTarget(target)
	local checkedTarget = target
	if not checkedTarget then
		return false
	end

	if not self:IsTargetAlive(checkedTarget) or not self:IsTargetEnemy(checkedTarget) then
		return false
	end
	if checkedTarget.Name == "TownHall" then
		return true
	end
	return self:IsTargetInAggroRange(checkedTarget)
end

--- Refreshes and returns the unit's current target.
---@param entities WorldEntities
---@return Unit | Structure | nil
function Unit:RefreshTarget(entities)
	if self:CanKeepRetaliationTarget(self.RetaliationTarget) then
		self.CurrentTarget = self.RetaliationTarget
		return self.CurrentTarget
	end
	self.RetaliationTarget = nil

	if self:CanKeepCurrentTarget(self.CurrentTarget) then
		return self.CurrentTarget
	end

	local aggroTarget = self:SearchForEnemy(entities)
	if aggroTarget then
		self.CurrentTarget = aggroTarget
		return aggroTarget
	end

	-- Keep lane/path movement active when no nearby enemy is in aggro range.
	self.CurrentTarget = nil
	return self.CurrentTarget
end

--- Executes the unit-specific attack behavior.
--- Base Unit is abstract for attack execution and must be specialized.
---@param target Unit | Structure
---@param entities WorldEntities
function Unit:PerformAttack(target, entities)
	error("Unit:PerformAttack must be implemented by a subclass")
end

--- Returns the next desired position based on aggro and attack ranges.
---@param entities WorldEntities
---@return number, number
function Unit:CalculateNextPosition(entities)
	local aggroTarget = self:RefreshTarget(entities)
	local hasAggroTarget = aggroTarget ~= nil
	if self.HadAggroTarget and not hasAggroTarget then
		self.PathId = nil
		self.PathWaypointIndex = nil
	end
	self.HadAggroTarget = hasAggroTarget

	local targetX, targetY = nil, nil

	if aggroTarget and self:IsTargetInRange(aggroTarget) then
		return self.Position.X, self.Position.Y
	elseif aggroTarget then
		targetX = aggroTarget.Position.X
		targetY = aggroTarget.Position.Y
	else
		targetX, targetY = NavigationSystem.GetPathTargetPoint(self, entities)
		if not targetX or not targetY then
			local fallbackDirection = (self.Team == "enemy") and "left" or "right"
			targetX, targetY = self:GetNextPosition(fallbackDirection)
		end
	end

	return SteeringSystem.GetNextPosition(self, entities, targetX, targetY)
end

--- Updates attack cooldown and attacks enemies in attack range.
---@param dt number
---@param entities WorldEntities
function Unit:UpdateCombat(dt, entities)
	self.AttackTimer = (self.AttackTimer or 0) + dt
	if self.AttackTimer < self.AttackSpeed then
		return
	end

	local target = self:RefreshTarget(entities)
	if target and not self:IsTargetInRange(target) then
		if self:CanKeepRetaliationTarget(self.RetaliationTarget) then
			return
		end
		target = self:SearchForEnemyToAttack(entities)
		if target then
			self.CurrentTarget = target
		end
	end

	if not target then
		return
	end

	self.AttackTimer = 0
	self:PerformAttack(target, entities)
end

--- Draws the unit at its current position.
function Unit:Draw()
	if self.Team == "enemy" then
		love.graphics.setColor(1, 0.2, 0.2)
	else
		love.graphics.setColor(0, 1, 0)
	end

	love.graphics.circle("fill", self.Position.X, self.Position.Y, self.Size)

	love.graphics.setColor(1, 1, 1)
end

return Unit
