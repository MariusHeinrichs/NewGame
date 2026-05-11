local TargetingSystem = {}

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

---@param target Unit | Structure | nil
---@return boolean
function TargetingSystem.IsTargetAlive(target)
	return target ~= nil and (target.Health or 0) > 0
end

---@param source Unit | Structure
---@param target Unit | Structure | nil
---@return boolean
function TargetingSystem.IsTargetEnemy(source, target)
	return target ~= nil and target.Team ~= nil and target.Team ~= source.Team
end

---@param target Unit | Structure
---@return number
function TargetingSystem.GetTargetRadius(target)
	if target.IsStructure == true then
		return (target.Size or 0) / 2
	end
	return target.Size or 0
end

---@param source Unit | Structure
---@param target Unit | Structure
---@param range number
---@return boolean
function TargetingSystem.IsTargetWithinRange(source, target, range)
	local distSq = distanceSquared(source.Position.X, source.Position.Y, target.Position.X, target.Position.Y)
	local totalRange = range + TargetingSystem.GetTargetRadius(target)
	return distSq <= (totalRange * totalRange)
end

---@param source Unit | Structure
---@param entities WorldEntities
---@param isTargetInRange fun(target: Unit | Structure): boolean
---@return Unit | Structure | nil
function TargetingSystem.SearchForEnemy(source, entities, isTargetInRange)
	return entities:FindClosestEnemy(source, function(target)
		return isTargetInRange(target)
	end)
end

---@param source Unit | Structure
---@param target Unit | Structure | nil
---@param options { range: number | nil, allowTownHall: boolean | nil }
---@return boolean
function TargetingSystem.CanKeepTarget(source, target, options)
	if not target then
		return false
	end
	if not TargetingSystem.IsTargetAlive(target) or not TargetingSystem.IsTargetEnemy(source, target) then
		return false
	end
	if options.allowTownHall and target.Name == "TownHall" then
		return true
	end
	return TargetingSystem.IsTargetWithinRange(source, target, options.range or 0)
end

---@param source Unit | Structure
---@param attacker Unit | Structure | nil
---@param canKeepRetaliationTarget fun(self: Unit | Structure, target: Unit | Structure | nil): boolean
function TargetingSystem.OnDamaged(source, attacker, canKeepRetaliationTarget)
	if not attacker then
		return
	end
	if not TargetingSystem.IsTargetEnemy(source, attacker) then
		return
	end
	if canKeepRetaliationTarget(source, source.RetaliationTarget) then
		return
	end
	source.RetaliationTarget = attacker
	source.CurrentTarget = attacker
end

---@class TargetRefreshOptions
---@field canKeepCurrentTarget fun(self: Unit | Structure, target: Unit | Structure | nil): boolean
---@field searchForEnemy fun(self: Unit | Structure, entities: WorldEntities): Unit | Structure | nil
---@field canKeepRetaliationTarget fun(self: Unit | Structure, target: Unit | Structure | nil): boolean | nil
---@field clearRetaliationWhenInvalid boolean | nil
---@field preferRetaliation boolean | nil

---@param source Unit | Structure
---@param entities WorldEntities
---@param options TargetRefreshOptions
---@return Unit | Structure | nil
function TargetingSystem.RefreshTarget(source, entities, options)
	if options.preferRetaliation and options.canKeepRetaliationTarget
		and options.canKeepRetaliationTarget(source, source.RetaliationTarget) then
		source.CurrentTarget = source.RetaliationTarget
		return source.CurrentTarget
	end

	if options.clearRetaliationWhenInvalid then
		source.RetaliationTarget = nil
	end

	if options.canKeepCurrentTarget(source, source.CurrentTarget) then
		return source.CurrentTarget
	end

	source.CurrentTarget = options.searchForEnemy(source, entities)
	return source.CurrentTarget
end

return TargetingSystem
