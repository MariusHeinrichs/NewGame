local CombatSystem = {}

---@param entities WorldEntities
---@param units table
---@param structures table
---@param dt number
function CombatSystem.Update(entities, units, structures, dt)
	for _, unit in ipairs(units) do
		unit:UpdateCombat(dt, entities)
	end
	for _, structure in ipairs(structures) do
		structure:UpdateCombat(dt, entities)
	end
end

return CombatSystem
