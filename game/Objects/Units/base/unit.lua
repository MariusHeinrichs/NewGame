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

local AVOIDANCE = {
	LockSwitchPenalty = 4200, -- High penalty while a lock is active to prevent rapid direction flips.
	SoftSwitchPenalty = 700, -- Smaller penalty after lock to keep short-term directional stability.
	StickTicksNew = 6, -- Initial lock duration when a new vertical avoidance direction is chosen.
	StickTicksKeep = 5, -- Minimum lock duration when continuing in the same avoidance direction.
	TieEpsilon = 120, -- Score window where candidates are treated as equivalent and tie-break rules apply.
}

---@return number
local function random01()
	if love and love.math and love.math.random then
		return love.math.random()
	end
	return math.random()
end

---@return number
local function randomVerticalSign()
	return (random01() < 0.5) and -1 or 1
end

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

---@param x number
---@param y number
---@return number, number
local function normalizeVector(x, y)
	local len = math.sqrt(x * x + y * y)
	if len == 0 then
		return 0, 0
	end
	return x / len, y / len
end

---@param dy number
---@return integer
local function toVerticalDirection(dy)
	if dy > 0.01 then
		return 1
	end
	if dy < -0.01 then
		return -1
	end
	return 0
end

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
---@field CurrentTarget Unit | Structure | nil
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
	newUnit.CurrentTarget = nil
	newUnit.AvoidancePreferredY = 0
	newUnit.AvoidanceStickTicks = 0
	newUnit.AvoidanceLastVerticalY = 0 -- Initial tie-break falls back to random up/down.
	return newUnit
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
	if self:CanKeepCurrentTarget(self.CurrentTarget) then
		return self.CurrentTarget
	end

	local aggroTarget = self:SearchForEnemy(entities)
	if aggroTarget then
		self.CurrentTarget = aggroTarget
		return aggroTarget
	end

	self.CurrentTarget = self:GetEnemyTownHall(entities)
	return self.CurrentTarget
end

--- Executes the unit-specific attack behavior.
--- Base Unit is abstract for attack execution and must be specialized.
---@param target Unit | Structure
---@param entities WorldEntities
function Unit:PerformAttack(target, entities)
	error("Unit:PerformAttack must be implemented by a subclass")
end

--- Returns an alternative nearby position when the direct path is blocked.
---@param entities WorldEntities
---@param nextX number
---@param nextY number
---@param target Unit | Structure | nil
---@return number, number
function Unit:GetCollisionAvoidancePosition(entities, nextX, nextY, target)
	local function buildCandidates(step, forwardX, forwardY)
		local lateralAX, lateralAY = -forwardY, forwardX
		local lateralBX, lateralBY = forwardY, -forwardX
		local backX, backY = -forwardX, -forwardY
		local diagonalScale = 1 / math.sqrt(1 + 0.25)

		return {
			{ x = self.Position.X + lateralAX * step, y = self.Position.Y + lateralAY * step }, -- around obstacle
			{ x = self.Position.X + lateralBX * step, y = self.Position.Y + lateralBY * step },
			{ x = self.Position.X,                    y = self.Position.Y - step },              -- explicit up/down
			{ x = self.Position.X,                    y = self.Position.Y + step },
			{
				x = self.Position.X + (lateralAX + backX * 0.5) * step * diagonalScale,
				y = self.Position.Y + (lateralAY + backY * 0.5) * step * diagonalScale,
			},
			{
				x = self.Position.X + (lateralBX + backX * 0.5) * step * diagonalScale,
				y = self.Position.Y + (lateralBY + backY * 0.5) * step * diagonalScale,
			},
			{ x = self.Position.X + backX * step, y = self.Position.Y + backY * step }, -- opposite direction fallback
		}
	end

	local function scoreCandidate(candidate, candidateDirY, preferredY)
		local directionPenalty = 0
		if preferredY ~= 0 and candidateDirY ~= 0 and candidateDirY ~= preferredY then
			directionPenalty = directionPenalty + AVOIDANCE.LockSwitchPenalty
		elseif self.AvoidancePreferredY ~= 0 and candidateDirY ~= 0 and candidateDirY ~= self.AvoidancePreferredY then
			directionPenalty = directionPenalty + AVOIDANCE.SoftSwitchPenalty
		end

		if target then
			local tx = target.Position.X - candidate.x
			local ty = target.Position.Y - candidate.y
			local distSq = tx * tx + ty * ty
			local range = self.AttackRange + self:GetTargetRadius(target)
			local inRangeGap = math.max(0, distSq - (range * range))
			return directionPenalty + inRangeGap + (distSq * 0.001)
		end

		return directionPenalty + math.abs(candidate.y - nextY)
	end

	local preferredY = 0
	if self.AvoidanceStickTicks > 0 then
		preferredY = self.AvoidancePreferredY
		self.AvoidanceStickTicks = self.AvoidanceStickTicks - 1
	end

	local baseDx = nextX - self.Position.X
	local baseDy = nextY - self.Position.Y
	if baseDx == 0 and baseDy == 0 and target then
		baseDx = target.Position.X - self.Position.X
		baseDy = target.Position.Y - self.Position.Y
	end

	local forwardX, forwardY = normalizeVector(baseDx, baseDy)
	if forwardX == 0 and forwardY == 0 then
		forwardX = (self.Team == "enemy") and -1 or 1
		forwardY = 0
	end

	local step = self.Speed
	local candidates = buildCandidates(step, forwardX, forwardY)

	-- Larger units need more candidate directions to avoid getting trapped by tight local geometry.
	local extraSamples = math.min(18, 6 + math.floor(self.Size / 4))
	local startAngle = random01() * math.pi * 2
	for i = 1, extraSamples do
		local angle = startAngle + ((i - 1) / extraSamples) * math.pi * 2
		candidates[#candidates + 1] = {
			x = self.Position.X + math.cos(angle) * step,
			y = self.Position.Y + math.sin(angle) * step,
		}
	end

	local bestX, bestY = self.Position.X, self.Position.Y
	local bestScore = math.huge
	local bestDirY = 0

	for _, candidate in ipairs(candidates) do
		if not entities:WillUnitCollide(self, candidate.x, candidate.y) then
			local candidateDirY = toVerticalDirection(candidate.y - self.Position.Y)
			local score = scoreCandidate(candidate, candidateDirY, preferredY)

			if score < bestScore then
				bestScore = score
				bestX, bestY = candidate.x, candidate.y
				bestDirY = candidateDirY
			elseif math.abs(score - bestScore) <= AVOIDANCE.TieEpsilon and candidateDirY ~= 0 and bestDirY ~= 0 then
				if candidateDirY ~= bestDirY and random01() < 0.5 then
					bestScore = score
					bestX, bestY = candidate.x, candidate.y
					bestDirY = candidateDirY
				end
			end
		end
	end

	local chosenDirY = toVerticalDirection(bestY - self.Position.Y)

	if chosenDirY ~= 0 then
		self.AvoidanceLastVerticalY = chosenDirY
		if chosenDirY == self.AvoidancePreferredY then
			self.AvoidanceStickTicks = math.max(self.AvoidanceStickTicks, AVOIDANCE.StickTicksKeep)
		else
			self.AvoidancePreferredY = chosenDirY
			self.AvoidanceStickTicks = AVOIDANCE.StickTicksNew
		end
	end

	return bestX, bestY
end

--- Returns the next desired position based on aggro and attack ranges.
---@param entities WorldEntities
---@return number, number
function Unit:CalculateNextPosition(entities)
	local aggroTarget = self:RefreshTarget(entities)
	local nextX, nextY
	local pursuitTarget = nil

	if aggroTarget and self:IsTargetInRange(aggroTarget) then
		return self.Position.X, self.Position.Y
	elseif aggroTarget then
		local dx = aggroTarget.Position.X - self.Position.X
		local dy = aggroTarget.Position.Y - self.Position.Y
		local dist = math.sqrt(dx * dx + dy * dy)
		pursuitTarget = aggroTarget
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

	if entities:WillUnitCollide(self, nextX, nextY) then
		if pursuitTarget then
			return self:GetCollisionAvoidancePosition(entities, nextX, nextY, pursuitTarget)
		end
		return self:GetCollisionAvoidancePosition(entities, nextX, nextY, nil)
	end

	self.AvoidanceStickTicks = math.max(0, self.AvoidanceStickTicks - 1)

	return nextX, nextY
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
