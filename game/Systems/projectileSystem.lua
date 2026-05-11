local ProjectileSystem = {}

---@param entities WorldEntities
---@param splashImpact table | nil
local function applyProjectileSplash(entities, splashImpact)
	if splashImpact == nil then
		return
	end

	local splashRadiusSq = splashImpact.Radius * splashImpact.Radius

	local function applyToTarget(target)
		if target == nil or target == splashImpact.DirectTarget then
			return
		end
		if target.Team == splashImpact.Team then
			return
		end
		if (target.Health or 0) <= 0 then
			return
		end

		local dx = target.Position.X - splashImpact.X
		local dy = target.Position.Y - splashImpact.Y
		if (dx * dx + dy * dy) <= splashRadiusSq then
			local dmg = math.max(1, splashImpact.Damage - (target.Armor or 0))
			target.Health = target.Health - dmg
			if type(target.OnDamaged) == "function" then
				target:OnDamaged(splashImpact.Source)
			end
		end
	end

	for _, unit in ipairs(entities.Units) do
		applyToTarget(unit)
	end
	for _, structure in ipairs(entities.Structures) do
		applyToTarget(structure)
	end
end

---@param entities WorldEntities
---@param dt number
function ProjectileSystem.Update(entities, dt)
	for i = #entities.Projectiles, 1, -1 do
		local projectile = entities.Projectiles[i]
		local splashImpact = projectile:Update(dt)
		applyProjectileSplash(entities, splashImpact)
		if not projectile:IsActive() then
			table.remove(entities.Projectiles, i)
		end
	end
	entities:RemoveDeadUnits()
end

return ProjectileSystem