--- BattleInterface module

local Button = require("BaseClasses.button")

local BASE_BUTTON_WIDTH = 170
local BASE_BUTTON_HEIGHT = 50
local BASE_SPACING_X = 20
local BASE_BOTTOM_MARGIN = 24

local function onBarbarianButtonPressed(interface)
	interface.SelectedStructureType = "BarbarianCamp"
end

local function onKnightButtonPressed(interface)
	interface.SelectedStructureType = "Barracks"
end

local function onArcherButtonPressed(interface)
	interface.SelectedStructureType = "ArcherTower"
end

local function onMageButtonPressed(interface)
	interface.SelectedStructureType = "MageTower"
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
	local battleInterface = setmetatable({}, self)
	battleInterface.SelectedStructureType = nil
	battleInterface.Resources = resources

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
			BASE_BUTTON_WIDTH,
			BASE_BUTTON_HEIGHT,
			definition.text,
			{ X = 0, Y = 0 },
			{ X = 0, Y = 15 }
		)
	end

	battleInterface:RebuildLayout()

	return battleInterface
end

--- Recomputes battle button positions based on current window size.
function BattleInterface:RebuildLayout()
	local width, height = love.graphics.getDimensions()
	local scale = math.min(width / 1280, height / 720)
	scale = math.max(0.75, math.min(1.6, scale))

	local buttonWidth = math.floor(BASE_BUTTON_WIDTH * scale + 0.5)
	local buttonHeight = math.floor(BASE_BUTTON_HEIGHT * scale + 0.5)
	local spacingX = math.floor(BASE_SPACING_X * scale + 0.5)
	local bottomMargin = math.floor(BASE_BOTTOM_MARGIN * scale + 0.5)

	local buttonCount = 4
	local totalWidth = buttonCount * buttonWidth + (buttonCount - 1) * spacingX
	local startX = (width - totalWidth) / 2
	local y = height - buttonHeight - bottomMargin
	local textOffsetY = math.floor(buttonHeight * 0.3 + 0.5)

	self.BarbarianButton.Width = buttonWidth
	self.BarbarianButton.Height = buttonHeight
	self.BarbarianButton.PositionText.Y = textOffsetY

	self.BarbarianButton.PositionButton.X = startX
	self.BarbarianButton.PositionButton.Y = y

	self.KnightButton.Width = buttonWidth
	self.KnightButton.Height = buttonHeight
	self.KnightButton.PositionText.Y = textOffsetY

	self.KnightButton.PositionButton.X = startX + (buttonWidth + spacingX)
	self.KnightButton.PositionButton.Y = y

	self.ArcherButton.Width = buttonWidth
	self.ArcherButton.Height = buttonHeight
	self.ArcherButton.PositionText.Y = textOffsetY

	self.ArcherButton.PositionButton.X = startX + (2 * (buttonWidth + spacingX))
	self.ArcherButton.PositionButton.Y = y

	self.MageButton.Width = buttonWidth
	self.MageButton.Height = buttonHeight
	self.MageButton.PositionText.Y = textOffsetY

	self.MageButton.PositionButton.X = startX + (3 * (buttonWidth + spacingX))
	self.MageButton.PositionButton.Y = y
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
