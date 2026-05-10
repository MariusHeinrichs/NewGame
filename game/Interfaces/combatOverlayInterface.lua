--- CombatOverlayInterface draws health bars for units and key structures.

---@class CombatOverlayInterface
local CombatOverlayInterface = {}
CombatOverlayInterface.__index = CombatOverlayInterface

local BAR_WIDTH = 22
local BAR_HEIGHT = 4
local BAR_Y_OFFSET_UNIT = 12
local BAR_Y_OFFSET_STRUCTURE = 10
local BG_ALPHA = 0.7

---@return CombatOverlayInterface
function CombatOverlayInterface:new()
	return setmetatable({}, self)
end

---@param value number | nil
---@param fallback number
---@return number
local function safeNumber(value, fallback)
	if type(value) == "number" then
		return value
	end
	return fallback
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param ratio number
---@param team "player" | "enemy" | nil
local function drawBar(x, y, width, height, ratio, team)
	love.graphics.setColor(0.08, 0.08, 0.08, BG_ALPHA)
	love.graphics.rectangle("fill", x, y, width, height)

	local clamped = math.max(0, math.min(1, ratio))
	if team == "enemy" then
		love.graphics.setColor(0.95, 0.28, 0.24, 0.95)
	else
		love.graphics.setColor(0.2, 0.9, 0.38, 0.95)
	end
	love.graphics.rectangle("fill", x + 1, y + 1, (width - 2) * clamped, height - 2)
	love.graphics.setColor(1, 1, 1, 1)
end

---@param entity Unit | Structure
---@param maxHealth number
---@param yOffset number
local function drawEntityBar(entity, maxHealth, yOffset)
	if not entity or not entity.Position then
		return
	end
	if (entity.Health or 0) <= 0 then
		return
	end

	local barX = entity.Position.X - (BAR_WIDTH * 0.5)
	local barY = entity.Position.Y - yOffset
	local ratio = (entity.Health or 0) / math.max(1, maxHealth)
	drawBar(barX, barY, BAR_WIDTH, BAR_HEIGHT, ratio, entity.Team)
end

---@param world World | nil
function CombatOverlayInterface:Draw(world)
	if not world or not world.Entities then
		return
	end

	for _, unit in ipairs(world.Entities:GetUnits()) do
		local maxHealth = safeNumber(unit.MaxHealth, safeNumber(unit.Health, 1))
		drawEntityBar(unit, maxHealth, BAR_Y_OFFSET_UNIT + safeNumber(unit.Size, 8))
	end

	for _, structure in ipairs(world.Entities:GetStructures()) do
		if structure.Name == "TownHall"
			or structure.Name == "ArcherTower"
			or structure.Name == "MageTower"
			or structure.SpawnRate ~= nil then
			local maxHealth = safeNumber(structure.MaxHealth, safeNumber(structure.Health, 1))
			drawEntityBar(structure, maxHealth, BAR_Y_OFFSET_STRUCTURE + ((structure.Size or 0) * 0.5))
		end
	end
end

return CombatOverlayInterface
