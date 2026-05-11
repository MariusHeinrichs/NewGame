local WorldTransformSystem = {}

---@param entity table | nil
---@param deltaX number
---@param deltaY number
local function translateEntityPosition(entity, deltaX, deltaY)
	if not entity or not entity.Position then
		return
	end
	entity.Position.X = entity.Position.X + deltaX
	entity.Position.Y = entity.Position.Y + deltaY
end

---@param entities WorldEntities
---@param deltaX number
---@param deltaY number
function WorldTransformSystem.TranslateEntities(entities, deltaX, deltaY)
	if deltaX == 0 and deltaY == 0 then
		return
	end

	for _, unit in ipairs(entities:GetUnits()) do
		translateEntityPosition(unit, deltaX, deltaY)
	end
	for _, structure in ipairs(entities:GetStructures()) do
		translateEntityPosition(structure, deltaX, deltaY)
	end
	for _, projectile in ipairs(entities:GetProjectiles()) do
		translateEntityPosition(projectile, deltaX, deltaY)
	end
	entities:RebuildSpatialIndex()
end

return WorldTransformSystem