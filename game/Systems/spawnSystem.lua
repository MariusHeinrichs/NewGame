local SpawnSystem = {}

---@param entities WorldEntities
---@param team string
---@return boolean
local function canTeamSpawnUnit(entities, team)
	local count = 0
	for _, unit in ipairs(entities.Units) do
		if (unit.Team or "player") == team then
			count = count + 1
		end
	end
	return count < entities.MaxUnitsPerTeam
end

---@param entities WorldEntities
---@param structures table
---@param dt number
function SpawnSystem.Update(entities, structures, dt)
	for _, structure in ipairs(structures) do
		if structure and type(structure.SpawnUnit) == "function"
			and (structure.Health or 0) > 0
			and canTeamSpawnUnit(entities, structure.Team or "player") then
			local spawnedUnit = structure:SpawnUnit(dt, entities)
			if spawnedUnit then
				entities:AddUnit(spawnedUnit)
			end
		end
	end

	entities:RemoveDeadStructures()
end

return SpawnSystem
