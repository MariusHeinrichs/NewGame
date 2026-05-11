local MovementSystem = {}

---@param entities WorldEntities
---@param units table
function MovementSystem.Update(entities, units)
	entities:RebuildSpatialIndex()

	for _, unit in ipairs(units) do
		local nextX, nextY = unit:CalculateNextPosition(entities)
		unit:MoveTo(nextX, nextY)
	end

	entities:RemoveDeadUnits()
	entities:RebuildSpatialIndex()
end

return MovementSystem