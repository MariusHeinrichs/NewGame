--- BattleInterface module

local Button = require("BaseClasses.button")
local GameContext = require("src.gameContext")

local BASE_BUTTON_WIDTH = 170
local BASE_BUTTON_HEIGHT = 50
local BASE_SPACING_X = 20
local BASE_BOTTOM_MARGIN = 24
local PLACEMENT_HINT_DURATION = 2.0

local function onBarbarianButtonPressed(interface)
	interface.SelectedStructureType = "BarbarianCamp"
end

local function onKnightButtonPressed(interface)
	interface.SelectedStructureType = "Barracks"
end

local function onArcherButtonPressed(interface)
	interface.SelectedStructureType = "ArcherCamp"
end

local function onMageButtonPressed(interface)
	interface.SelectedStructureType = "Library"
end

---@class BattleInterface
---@field BarbarianButton Button
---@field KnightButton Button
---@field ArcherButton Button
---@field MageButton Button
---@field SelectedStructureType string | nil
---@field Resources Resources | nil
---@field PlacementHintText string | nil
---@field PlacementHintTimeLeft number
local BattleInterface = {}
BattleInterface.__index = BattleInterface

---@param reason string | nil
---@return string
local function getPlacementFailureMessage(reason)
	if reason == "invalid_type" then
		return "Bitte zuerst eine Struktur auswaehlen."
	end
	if reason == "invalid_class" then
		return "Diese Struktur kann aktuell nicht platziert werden."
	end
	if reason == "invalid_resources" then
		return "Ressourcen sind nicht initialisiert."
	end
	if reason == "blocked_by_collision" then
		return "Platzierung blockiert: Zu nah an Einheiten oder Strukturen."
	end
	if reason == "out_of_bounds" then
		return "Platzierung ausserhalb der Karte ist nicht erlaubt."
	end
	if reason == "wrong_side" then
		return "Platzierung nur auf der eigenen Spielfeldhaelfte erlaubt."
	end
	if reason == "not_affordable" then
		return "Nicht genug Ressourcen fuer diese Struktur."
	end
	return "Struktur konnte nicht platziert werden."
end

--- Creates a new BattleInterface table.
---@param resources table | nil
---@return BattleInterface
function BattleInterface:new(resources)
	local battleInterface = setmetatable({}, self)
	battleInterface.SelectedStructureType = nil
	battleInterface.Resources = resources
	battleInterface.PlacementHintText = nil
	battleInterface.PlacementHintTimeLeft = 0

	local definitions = {
		{ key = "BarbarianButton", name = "Barbarian", text = "Barbarian", action = function() onBarbarianButtonPressed(
			battleInterface) end },
		{ key = "KnightButton",    name = "Knight",    text = "Knight",    action = function() onKnightButtonPressed(
			battleInterface) end },
		{ key = "ArcherButton",    name = "Archer",    text = "Archer",    action = function() onArcherButtonPressed(
			battleInterface) end },
		{ key = "MageButton",      name = "Mage",      text = "Mage",      action = function() onMageButtonPressed(
			battleInterface) end },
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

---@param dt number
function BattleInterface:Update(dt)
	if self.PlacementHintTimeLeft > 0 then
		self.PlacementHintTimeLeft = math.max(0, self.PlacementHintTimeLeft - dt)
		if self.PlacementHintTimeLeft == 0 then
			self.PlacementHintText = nil
		end
	end
end

---@param reason string | nil
function BattleInterface:ShowPlacementFailure(reason)
	self.PlacementHintText = getPlacementFailureMessage(reason)
	self.PlacementHintTimeLeft = PLACEMENT_HINT_DURATION
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
	if self.PlacementHintText and self.PlacementHintTimeLeft > 0 then
		local width = love.graphics.getDimensions()
		love.graphics.setColor(1, 0.3, 0.3, 1)
		love.graphics.printf(self.PlacementHintText, 0, 36, width, "center")
		love.graphics.setColor(1, 1, 1, 1)
	end

	if self.Resources then
		local width = love.graphics.getDimensions()
		local rightX = width - 20
		local columnWidth = 120
		local topY = 10
		local incomeY = topY + 16
		local incomeInterval = self.Resources.IncomeInterval or 5
		local goldIncome = self.Resources.BaseGoldIncomeValue or 0
		local metalIncome = self.Resources.BaseMetalIncomeValue or 0
		local aetherIncome = rawget(self.Resources, "BaseAetherIncomeValue") or 0

		local goldColumnX = rightX - (columnWidth * 3)
		local metalColumnX = rightX - (columnWidth * 2)
		local aetherColumnX = rightX - columnWidth

		love.graphics.printf(string.format("Gold: %d", self.Resources.Gold), goldColumnX, topY, columnWidth, "right")
		love.graphics.printf(string.format("Metal: %d", self.Resources.Metal), metalColumnX, topY, columnWidth, "right")
		love.graphics.printf(string.format("Aether: %d", self.Resources.Aether), aetherColumnX, topY, columnWidth,
			"right")

		love.graphics.printf(string.format("+%d / %ds", goldIncome, incomeInterval), goldColumnX, incomeY, columnWidth,
			"right")
		love.graphics.printf(string.format("+%d / %ds", metalIncome, incomeInterval), metalColumnX, incomeY, columnWidth,
			"right")
		love.graphics.printf(string.format("+%d / %ds", aetherIncome, incomeInterval), aetherColumnX, incomeY, columnWidth,
			"right")
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

--- Handles a raw mouse press event for battle UI and structure placement.
---@param x number
---@param y number
---@param button number
---@return boolean True when any click path was processed.
function BattleInterface:HandleMousePressed(x, y, button)
	if button ~= 1 then
		return false
	end

	local uiClickHandled = self:IsPressed({ X = x, Y = y }, 0)
	if uiClickHandled then
		return true
	end

	local world = GameContext.Runtime.World
	local resources = GameContext.Runtime.Resources
	if not world or not resources then
		self:ShowPlacementFailure("invalid_resources")
		return true
	end

	local placed, reason = world:PlaceStructure(self:GetSelectedStructureType(), resources, x, y)
	if not placed then
		self:ShowPlacementFailure(reason)
	end
	return true
end

---@return string | nil
function BattleInterface:GetSelectedStructureType()
	return self.SelectedStructureType
end

return BattleInterface
