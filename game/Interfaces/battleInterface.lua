--- BattleInterface module

local Button = require("BaseClasses.button")

local function onBarbarianButtonPressed(interface)
	interface.SelectedStructureType = "Barbarian"
end

local function onKnightButtonPressed(interface)
	interface.SelectedStructureType = "Knight"
end

local function onArcherButtonPressed(interface)
	interface.SelectedStructureType = "Archer"
end

local function onMageButtonPressed(interface)
	interface.SelectedStructureType = "Mage"
end

--- @class BattleInterface
--- @field BarbarianButton Button
--- @field KnightButton Button
--- @field ArcherButton Button
--- @field MageButton Button
--- @field SelectedStructureType string | nil
---@field Resources Resources | nil
local BattleInterface = {}
BattleInterface.__index = BattleInterface

--- Creates a new BattleInterface table.
---@param resources table | nil
---@return BattleInterface
function BattleInterface:new(resources)
	local width, height = love.graphics.getDimensions()
	local battleInterface = setmetatable({}, self)
	battleInterface.SelectedStructureType = nil
	battleInterface.Resources = resources

	local buttonWidth, buttonHeight = 170, 50
	local spacingX = 20
	local buttonCount = 4
	local totalWidth = buttonCount * buttonWidth + (buttonCount - 1) * spacingX
	local startX = (width - totalWidth) / 2
	local y = height - buttonHeight - 24

	local definitions = {
		{ key = "BarbarianButton", name = "Barbarian",        text = "Barbarian",        action = function() onBarbarianButtonPressed(battleInterface) end },
		{ key = "KnightButton",    name = "Knight",        text = "Knight",        action = function() onKnightButtonPressed(battleInterface) end },
		{ key = "ArcherButton",    name = "Archer", text = "Archer", action = function() onArcherButtonPressed(battleInterface) end },
		{ key = "MageButton",      name = "Mage",        text = "Mage",        action = function() onMageButtonPressed(battleInterface) end },
	}

	for index, definition in ipairs(definitions) do
		battleInterface[definition.key] = Button:new(
			definition.name,
			definition.action,
			buttonWidth,
			buttonHeight,
			definition.text,
			{ X = startX + (index - 1) * (buttonWidth + spacingX), Y = y },
			{ X = 0, Y = 15 }
		)
	end

	return battleInterface
end

--- Draws all battle buttons and the HUD.
function BattleInterface:Draw()
	if self.Resources then
		local width = love.graphics.getDimensions()
		local hudText = string.format("Gold: %d   Metal: %d   Aether: %d", self.Resources.Gold, self.Resources.Metal, self.Resources.Aether)
		love.graphics.printf(hudText, 0, 10, width - 20, "right")
	end

	self.BarbarianButton:Draw()
	self.KnightButton:Draw()
	self.ArcherButton:Draw()
	self.MageButton:Draw()
end

--- Checks if any battle button is pressed.
---@param PositionMouse {X: number, Y: number}
---@param CursorRadius number
function BattleInterface:IsPressed(PositionMouse, CursorRadius)
	if self.BarbarianButton:IsPressed(PositionMouse, CursorRadius) then
		return true
	end
	if self.KnightButton:IsPressed(PositionMouse, CursorRadius) then
		return true
	end
	if self.ArcherButton:IsPressed(PositionMouse, CursorRadius) then
		return true
	end
	if self.MageButton:IsPressed(PositionMouse, CursorRadius) then
		return true
	end
	return false
end

---@return string | nil
function BattleInterface:GetSelectedStructureType()
	return self.SelectedStructureType
end

return BattleInterface
