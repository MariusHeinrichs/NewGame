--- Unit class representing a game unit with health, damage, armor, speed, size, aggro range, attack range, and attack speed attributes.

local Object = require("BaseClasses.object")

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

---@class Unit : Object
---@field Health number
---@field Damage number
---@field Armor number
---@field Speed number
---@field Size number
---@field AttackRange number
---@field AggroRange number
---@field AttackSpeed number
---@field Team "player" | "enemy"
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
	newUnit.Damage = Damage or DEFAULTS.Damage
	newUnit.Armor = Armor or DEFAULTS.Armor
	newUnit.Speed = Speed or DEFAULTS.Speed
	newUnit.Size = Size or DEFAULTS.Size
	newUnit.AttackRange = AttackRange or DEFAULTS.AttackRange
	newUnit.AggroRange = AggroRange or DEFAULTS.AggroRange
	newUnit.AttackSpeed = AttackSpeed or DEFAULTS.AttackSpeed
	newUnit.Team = Team or "player"
	return newUnit
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
	if target.SpawnRate ~= nil then
		return (target.Size or 0) / 2
	end
	return target.Size or 0
end

--- Returns true when target is inside attack range.
---@param target Unit | Structure
---@return boolean
function Unit:IsTargetInRange(target)
	local dx = target.Position.X - self.Position.X
	local dy = target.Position.Y - self.Position.Y
	local distSq = dx * dx + dy * dy
	local range = self.AttackRange + self:GetTargetRadius(target)
	return distSq <= (range * range)
end

--- Returns true when target is inside aggro range.
---@param target Unit | Structure
---@return boolean
function Unit:IsTargetInAggroRange(target)
	local dx = target.Position.X - self.Position.X
	local dy = target.Position.Y - self.Position.Y
	local distSq = dx * dx + dy * dy
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

--- Attacks a target, dealing damage reduced by the target's armor.
---@param target Unit | Structure
function Unit:Attack(target)
	local dmg = math.max(1, self.Damage - (target.Armor or 0))
	target.Health = target.Health - dmg
end

--- Returns an alternative nearby position when the direct path is blocked.
---@param entities WorldEntities
---@param nextX number
---@param nextY number
---@return number, number
function Unit:GetCollisionAvoidancePosition(entities, nextX, nextY)
	local dx = nextX - self.Position.X
	local dy = nextY - self.Position.Y
	local dist = math.sqrt(dx * dx + dy * dy)

	if dist == 0 then
		return self.Position.X, self.Position.Y
	end

	local stepX = dx / dist
	local stepY = dy / dist
	local sideX = -stepY
	local sideY = stepX
	local offset = math.max(self.Speed, self.Size * 0.5)
	local candidates = {
		{ x = nextX + sideX * offset, y = nextY + sideY * offset },
		{ x = nextX - sideX * offset, y = nextY - sideY * offset },
		{ x = self.Position.X + sideX * offset, y = self.Position.Y + sideY * offset },
		{ x = self.Position.X - sideX * offset, y = self.Position.Y - sideY * offset },
		{ x = nextX + sideX * offset * 1.5, y = nextY + sideY * offset * 1.5 },
		{ x = nextX - sideX * offset * 1.5, y = nextY - sideY * offset * 1.5 },
	}

	for _, candidate in ipairs(candidates) do
		if not entities:WillUnitCollide(self, candidate.x, candidate.y) then
			return candidate.x, candidate.y
		end
	end

	return self.Position.X, self.Position.Y
end

--- Returns the next desired position based on aggro and attack ranges.
---@param entities WorldEntities
---@return number, number
function Unit:CalculateNextPosition(entities)
	local aggroTarget = self:SearchForEnemy(entities)
	local nextX, nextY

	if aggroTarget and self:IsTargetInRange(aggroTarget) then
		nextX, nextY = self.Position.X, self.Position.Y
	elseif aggroTarget then
		local dx = aggroTarget.Position.X - self.Position.X
		local dy = aggroTarget.Position.Y - self.Position.Y
		local dist = math.sqrt(dx * dx + dy * dy)
		if dist > 0 then
			nextX = self.Position.X + (dx / dist) * self.Speed
			nextY = self.Position.Y + (dy / dist) * self.Speed
		else
			nextX, nextY = self.Position.X, self.Position.Y
		end
	else
		local enemyTownHall = self:GetEnemyTownHall(entities)
		if enemyTownHall then
			local dx = enemyTownHall.Position.X - self.Position.X
			local dy = enemyTownHall.Position.Y - self.Position.Y
			local dist = math.sqrt(dx * dx + dy * dy)
			if dist > 0 then
				nextX = self.Position.X + (dx / dist) * self.Speed
				nextY = self.Position.Y + (dy / dist) * self.Speed
			else
				nextX, nextY = self.Position.X, self.Position.Y
			end
		else
			local direction = (self.Team == "enemy") and "left" or "right"
			nextX, nextY = self:GetNextPosition(direction)
		end
	end

	if entities:WillUnitCollide(self, nextX, nextY) then
		return self:GetCollisionAvoidancePosition(entities, nextX, nextY)
	end

	return nextX, nextY
end

--- Updates attack cooldown and attacks enemies in attack range.
---@param dt number
---@param entities WorldEntities
function Unit:UpdateCombat(dt, entities)
	self.AttackTimer = (self.AttackTimer or 0) + dt
	if self.AttackTimer >= self.AttackSpeed then
		local target = self:SearchForEnemyToAttack(entities)
		if target then
			self.AttackTimer = 0
			self:Attack(target)
		end
	end
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
