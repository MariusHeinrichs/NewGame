--- MainMenuButtons module

local Button = require("BaseClasses.button")

local function onStartButtonPressed(gameState)
	gameState.MainMenu = false
	gameState.Running = true
end

--- @class MainMenuInterface
--- @field StartButton Button
--- @field SettingsButton Button
--- @field QuitButton Button
local MainMenuInterface = {}
MainMenuInterface.__index = MainMenuInterface

--- Creates a new MainMenuInterface table.
---@param gameState table The game state table to be modified by button actions.
---@return MainMenuInterface
function MainMenuInterface:new(gameState)
	local width, height = love.graphics.getDimensions()
	local newButtons = setmetatable({}, self)

	local buttonWidth, buttonHeight = 200, 50
	local startY = height / 2
	local spacingY = 60
	local centerX = width / 2 - buttonWidth / 2

	local definitions = {
		{ key = "StartButton",    name = "Start",    text = "Start Game", action = function() onStartButtonPressed(gameState) end },
		{ key = "SettingsButton", name = "Settings", text = "Settings" },
		{ key = "QuitButton",     name = "Quit",     text = "Quit Game",  action = function() love.event.quit() end },
	}

	for index, definition in ipairs(definitions) do
		newButtons[definition.key] = Button:new(
			definition.name,
			definition.action,
			buttonWidth,
			buttonHeight,
			definition.text,
			{ X = centerX, Y = startY + (index - 1) * spacingY },
			{ X = 0, Y = 15 }
		)
	end

	return newButtons
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
function MainMenuInterface:IsPressed(PositionMouse, CursorRadius)
	self.StartButton:IsPressed(PositionMouse, CursorRadius)
	self.SettingsButton:IsPressed(PositionMouse, CursorRadius)
	self.QuitButton:IsPressed(PositionMouse, CursorRadius)
end


return MainMenuInterface
