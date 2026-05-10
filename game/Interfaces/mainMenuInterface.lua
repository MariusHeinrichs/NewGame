--- MainMenuButtons module

local Button = require("BaseClasses.button")
local GameStateTransitions = require("src.gameStateTransitions")

local BASE_BUTTON_WIDTH = 200
local BASE_BUTTON_HEIGHT = 50
local BASE_SPACING_Y = 60

local function onStartGamePressed(gameState, resetRuntimeState)
	GameStateTransitions.EnterRunning(gameState, resetRuntimeState)
end

--- @class MainMenuInterface
--- @field StartButton Button
--- @field SettingsButton Button
--- @field QuitButton Button
local MainMenuInterface = {}
MainMenuInterface.__index = MainMenuInterface

--- Creates a new MainMenuInterface table.
---@param gameState table The game state table to be modified by button actions.
---@param resetRuntimeState fun() | nil An optional callback function to reset runtime state when starting the game.
---@return MainMenuInterface
function MainMenuInterface:new(gameState, resetRuntimeState)
	local newButtons = setmetatable({}, self)

	local definitions = {
		{ key = "StartButton",    name = "Start",    text = "Start Game", action = function() onStartGamePressed(gameState, resetRuntimeState) end },
		{ key = "SettingsButton", name = "Settings", text = "Settings" },
		{ key = "QuitButton",     name = "Quit",     text = "Quit Game",  action = function() love.event.quit() end },
	}

	for index, definition in ipairs(definitions) do
		newButtons[definition.key] = Button:new(
			definition.name,
			definition.action,
			BASE_BUTTON_WIDTH,
			BASE_BUTTON_HEIGHT,
			definition.text,
			{ X = 0, Y = 0 },
			{ X = 0, Y = 15 }
		)
	end

	newButtons:RebuildLayout()

	return newButtons
end

--- Recomputes button positions based on current window size.
function MainMenuInterface:RebuildLayout()
	local width, height = love.graphics.getDimensions()
	local scale = math.min(width / 1280, height / 720)
	scale = math.max(0.75, math.min(1.6, scale))

	local buttonWidth = math.floor(BASE_BUTTON_WIDTH * scale + 0.5)
	local buttonHeight = math.floor(BASE_BUTTON_HEIGHT * scale + 0.5)
	local spacingY = math.floor(BASE_SPACING_Y * scale + 0.5)

	local startY = height / 2
	local centerX = width / 2 - buttonWidth / 2
	local textOffsetY = math.floor(buttonHeight * 0.3 + 0.5)

	self.StartButton.Width = buttonWidth
	self.StartButton.Height = buttonHeight
	self.StartButton.PositionText.Y = textOffsetY

	self.StartButton.PositionButton.X = centerX
	self.StartButton.PositionButton.Y = startY

	self.SettingsButton.Width = buttonWidth
	self.SettingsButton.Height = buttonHeight
	self.SettingsButton.PositionText.Y = textOffsetY

	self.SettingsButton.PositionButton.X = centerX
	self.SettingsButton.PositionButton.Y = startY + spacingY

	self.QuitButton.Width = buttonWidth
	self.QuitButton.Height = buttonHeight
	self.QuitButton.PositionText.Y = textOffsetY

	self.QuitButton.PositionButton.X = centerX
	self.QuitButton.PositionButton.Y = startY + (2 * spacingY)
end

--- Draws all the Menu buttons
function MainMenuInterface:Draw()
	self.StartButton:Draw()
	self.SettingsButton:Draw()
	self.QuitButton:Draw()
end

--- Checks if any of the buttons are pressed based on the mouse position and cursor radius.
--- if a button is pressed, its associated action will be executed.
---@param PositionMouse {X: number, Y: number}
---@param CursorRadius number
---@return boolean True if any menu button was pressed, otherwise false.
function MainMenuInterface:IsPressed(PositionMouse, CursorRadius)
	if self.StartButton:IsPressed(PositionMouse, CursorRadius) then
		return true
	end
	if self.SettingsButton:IsPressed(PositionMouse, CursorRadius) then
		return true
	end
	if self.QuitButton:IsPressed(PositionMouse, CursorRadius) then
		return true
	end
	return false
end


return MainMenuInterface
