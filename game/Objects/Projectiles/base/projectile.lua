--- Projectile entity used by ranged units.

---@class Projectile
---@field Position { X: number, Y: number }
---@field Velocity { X: number, Y: number }
---@field Speed number
---@field Radius number
---@field Damage number
---@field SplashRadius number
---@field SplashDamageMultiplier number
---@field Style string
---@field Team "player" | "enemy"
---@field Target Unit | Structure | nil
---@field Active boolean
local Projectile = {}
Projectile.__index = Projectile

---@param target Unit | Structure | nil
---@return number
local function getTargetRadius(target)
	if target == nil then
		return 0
	end
	if target.SpawnRate ~= nil then
		return (target.Size or 0) / 2
	end
	return target.Size or 0
end

---@param x number
---@param y number
---@param target Unit | Structure
---@param speed number
---@param radius number
---@param damage number
---@param splashRadius number | nil
---@param splashDamageMultiplier number | nil
---@param style string | nil
---@param team "player" | "enemy"
---@return Projectile
function Projectile:new(x, y, target, speed, radius, damage, splashRadius, splashDamageMultiplier, style, team)
	return setmetatable({
		Position = { X = x, Y = y },
		Velocity = { X = 0, Y = 0 },
		Speed = speed,
		Radius = radius,
		Damage = damage,
		SplashRadius = splashRadius or 0,
		SplashDamageMultiplier = splashDamageMultiplier or 0,
		Style = style or "orb",
		Team = team,
		Target = target,
		Active = true,
	}, self)
end

---@return boolean
function Projectile:IsActive()
	return self.Active
end

---@param target Unit | Structure | nil
---@return boolean
local function isTargetAlive(target)
	return target ~= nil and (target.Health or 0) > 0
end

---@param target Unit | Structure
function Projectile:ApplyHit(target)
	local dmg = math.max(1, self.Damage - (target.Armor or 0))
	target.Health = target.Health - dmg
	self.Active = false
end

---@param entities WorldEntities | nil
---@param impactX number
---@param impactY number
---@param directTarget Unit | Structure | nil
function Projectile:ApplySplash(entities, impactX, impactY, directTarget)
	if self.SplashRadius <= 0 or self.SplashDamageMultiplier <= 0 then
		return
	end
	if entities == nil then
		return
	end

	local splashDamage = math.max(1, math.floor(self.Damage * self.SplashDamageMultiplier))
	local splashRadiusSq = self.SplashRadius * self.SplashRadius

	local function applySplashToTarget(target)
		if target == nil or target == directTarget then
			return
		end
		if target.Team == self.Team then
			return
		end
		if (target.Health or 0) <= 0 then
			return
		end

		local dx = target.Position.X - impactX
		local dy = target.Position.Y - impactY
		if (dx * dx + dy * dy) <= splashRadiusSq then
			local dmg = math.max(1, splashDamage - (target.Armor or 0))
			target.Health = target.Health - dmg
		end
	end

	for _, unit in ipairs(entities:GetUnits()) do
		applySplashToTarget(unit)
	end
	for _, structure in ipairs(entities:GetStructures()) do
		applySplashToTarget(structure)
	end
end

---@param dt number
---@param entities WorldEntities | nil
function Projectile:Update(dt, entities)
	local target = self.Target
	if target == nil then
		self.Active = false
		return
	end
	if not isTargetAlive(target) then
		self.Active = false
		return
	end
	---@type Unit | Structure
	local liveTarget = target

	local tx = liveTarget.Position.X - self.Position.X
	local ty = liveTarget.Position.Y - self.Position.Y
	local distSq = tx * tx + ty * ty
	local hitRadius = self.Radius + getTargetRadius(liveTarget)
	if distSq <= (hitRadius * hitRadius) then
		local impactX = self.Position.X
		local impactY = self.Position.Y
		self:ApplyHit(liveTarget)
		self:ApplySplash(entities, impactX, impactY, liveTarget)
		return
	end

	local dist = math.sqrt(distSq)
	if dist == 0 then
		local impactX = self.Position.X
		local impactY = self.Position.Y
		self:ApplyHit(liveTarget)
		self:ApplySplash(entities, impactX, impactY, liveTarget)
		return
	end

	self.Velocity.X = (tx / dist) * self.Speed
	self.Velocity.Y = (ty / dist) * self.Speed

	local step = self.Speed * dt
	if step >= dist then
		self.Position.X = liveTarget.Position.X
		self.Position.Y = liveTarget.Position.Y
		local impactX = self.Position.X
		local impactY = self.Position.Y
		self:ApplyHit(liveTarget)
		self:ApplySplash(entities, impactX, impactY, liveTarget)
		return
	end

	self.Position.X = self.Position.X + (tx / dist) * step
	self.Position.Y = self.Position.Y + (ty / dist) * step
end

function Projectile:Draw()
	if self.Style == "fireball" then
		local x, y, r = self.Position.X, self.Position.Y, self.Radius
		love.graphics.setColor(1, 0.22, 0.04, 0.28)
		love.graphics.circle("fill", x, y, r * 2.5)
		love.graphics.setColor(1, 0.52, 0.12, 0.62)
		love.graphics.circle("fill", x, y, r * 1.75)
		love.graphics.setColor(1, 0.78, 0.23, 0.95)
		love.graphics.circle("fill", x, y, r * 1.2)
		love.graphics.setColor(1, 0.95, 0.62, 1)
		love.graphics.circle("fill", x, y, math.max(1.2, r * 0.62))
		love.graphics.setColor(1, 1, 1)
		return
	end

	if self.Style == "arrow" then
		local x, y = self.Position.X, self.Position.Y
		local dx = self.Velocity.X
		local dy = self.Velocity.Y
		local len = math.sqrt(dx * dx + dy * dy)
		if len < 0.001 then
			dx, dy = 1, 0
			len = 1
		end
		local ux, uy = dx / len, dy / len
		local px, py = -uy, ux
		local shaft = self.Radius * 3.0
		local wing = self.Radius * 0.9

		if self.Team == "enemy" then
			love.graphics.setColor(1, 0.78, 0.38)
		else
			love.graphics.setColor(0.62, 0.88, 1)
		end
		love.graphics.line(x - ux * shaft * 0.5, y - uy * shaft * 0.5, x + ux * shaft * 0.5, y + uy * shaft * 0.5)
		love.graphics.polygon(
			"fill",
			x + ux * shaft * 0.5,
			y + uy * shaft * 0.5,
			x + px * wing,
			y + py * wing,
			x - px * wing,
			y - py * wing
		)
		love.graphics.setColor(1, 1, 1)
		return
	end

	if self.Team == "enemy" then
		love.graphics.setColor(1, 0.65, 0.2)
	else
		love.graphics.setColor(0.2, 0.8, 1)
	end
	love.graphics.circle("fill", self.Position.X, self.Position.Y, self.Radius)
	love.graphics.setColor(1, 1, 1)
end

return Projectile