--- BattleInterface module

local Button = require("BaseClasses.button")

local function onAttackPressed(gameState)
	if gameState then
		gameState.LastBattleAction = "Attack"
	end
end

local function onDefendPressed(gameState)
	if gameState then
		gameState.LastBattleAction = "Defend"
	end
end

local function onSpecialPressed(gameState)
	if gameState then
		gameState.LastBattleAction = "Special"
	end
end

local function onRetreatPressed(gameState)
	if gameState then
		gameState.LastBattleAction = "Retreat"
	end
end

--- @class BattleInterface
--- @field AttackButton Button
--- @field DefendButton Button
--- @field SpecialButton Button
--- @field RetreatButton Button
local BattleInterface = {}
BattleInterface.__index = BattleInterface

--- Creates a new BattleInterface table.
---@param gameState table | nil
---@return BattleInterface
function BattleInterface:new(gameState)
	local width, height = love.graphics.getDimensions()
	local newButtons = setmetatable({}, self)

	local buttonWidth, buttonHeight = 170, 50
	local spacingX = 20
	local buttonCount = 4
	local totalWidth = buttonCount * buttonWidth + (buttonCount - 1) * spacingX
	local startX = (width - totalWidth) / 2
	local y = height - buttonHeight - 24

	local definitions = {
		{ key = "AttackButton",  name = "Attack",  text = "Attack",  action = function() onAttackPressed(gameState) end },
		{ key = "DefendButton",  name = "Defend",  text = "Defend",  action = function() onDefendPressed(gameState) end },
		{ key = "SpecialButton", name = "Special", text = "Special", action = function() onSpecialPressed(gameState) end },
		{ key = "RetreatButton", name = "Retreat", text = "Retreat", action = function() onRetreatPressed(gameState) end },
	}

	for index, definition in ipairs(definitions) do
		newButtons[definition.key] = Button:new(
			definition.name,
			definition.action,
			buttonWidth,
			buttonHeight,
			definition.text,
			{ X = startX + (index - 1) * (buttonWidth + spacingX), Y = y },
			{ X = 0, Y = 15 }
		)
	end

	return newButtons
end

--- Draws all battle buttons.
function BattleInterface:Draw()
	self.AttackButton:Draw()
	self.DefendButton:Draw()
	self.SpecialButton:Draw()
	self.RetreatButton:Draw()
end

--- Checks if any battle button is pressed.
---@param PositionMouse {X: number, Y: number}
---@param CursorRadius number
function BattleInterface:IsPressed(PositionMouse, CursorRadius)
	self.AttackButton:IsPressed(PositionMouse, CursorRadius)
	self.DefendButton:IsPressed(PositionMouse, CursorRadius)
	self.SpecialButton:IsPressed(PositionMouse, CursorRadius)
	self.RetreatButton:IsPressed(PositionMouse, CursorRadius)
end

return BattleInterface
