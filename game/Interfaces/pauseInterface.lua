--- PauseInterface module

local Button = require("BaseClasses.button")
local GameStateTransitions = require("src.gameStateTransitions")

local BASE_BUTTON_WIDTH = 220
local BASE_BUTTON_HEIGHT = 52
local BASE_SPACING_Y = 64

--- @class PauseInterface
--- @field ResumeButton Button
--- @field MenuButton Button
--- @field QuitButton Button
local PauseInterface = {}
PauseInterface.__index = PauseInterface

local function onResumePressed(gameState)
	GameStateTransitions.EnterRunning(gameState)
end

local function onMenuPressed(gameState)
	GameStateTransitions.EnterMenu(gameState)
end

--- Creates a new PauseInterface table.
---@param gameState {Mode: string}
---@return PauseInterface
function PauseInterface:new(gameState)
	local pauseInterface = setmetatable({}, self)

	local definitions = {
		{ key = "ResumeButton", text = "Resume", action = function() onResumePressed(gameState) end },
		{ key = "MenuButton", text = "Main Menu", action = function() onMenuPressed(gameState) end },
		{ key = "QuitButton", text = "Quit Game", action = function() love.event.quit() end },
	}

	for _, definition in ipairs(definitions) do
		pauseInterface[definition.key] = Button:new(
			definition.key,
			definition.action,
			BASE_BUTTON_WIDTH,
			BASE_BUTTON_HEIGHT,
			definition.text,
			{ X = 0, Y = 0 },
			{ X = 0, Y = 15 }
		)
	end

	pauseInterface:RebuildLayout()
	return pauseInterface
end

--- Recomputes button positions based on current window size.
function PauseInterface:RebuildLayout()
	local width, height = love.graphics.getDimensions()
	local scale = math.min(width / 1280, height / 720)
	scale = math.max(0.75, math.min(1.6, scale))

	local buttonWidth = math.floor(BASE_BUTTON_WIDTH * scale + 0.5)
	local buttonHeight = math.floor(BASE_BUTTON_HEIGHT * scale + 0.5)
	local spacingY = math.floor(BASE_SPACING_Y * scale + 0.5)

	local startY = height / 2 - spacingY
	local centerX = width / 2 - buttonWidth / 2
	local textOffsetY = math.floor(buttonHeight * 0.3 + 0.5)

	self.ResumeButton.Width = buttonWidth
	self.ResumeButton.Height = buttonHeight
	self.ResumeButton.PositionText.Y = textOffsetY
	self.ResumeButton.PositionButton.X = centerX
	self.ResumeButton.PositionButton.Y = startY

	self.MenuButton.Width = buttonWidth
	self.MenuButton.Height = buttonHeight
	self.MenuButton.PositionText.Y = textOffsetY
	self.MenuButton.PositionButton.X = centerX
	self.MenuButton.PositionButton.Y = startY + spacingY

	self.QuitButton.Width = buttonWidth
	self.QuitButton.Height = buttonHeight
	self.QuitButton.PositionText.Y = textOffsetY
	self.QuitButton.PositionButton.X = centerX
	self.QuitButton.PositionButton.Y = startY + (2 * spacingY)
end

--- Draws pause overlay and buttons.
function PauseInterface:Draw()
	local width, height = love.graphics.getDimensions()
	love.graphics.setColor(0, 0, 0, 0.35)
	love.graphics.rectangle("fill", 0, 0, width, height)
	love.graphics.setColor(1, 1, 1, 1)

	local title = "Paused"
	local subtitle = "Press ESC to resume"
	local font = love.graphics.getFont()
	love.graphics.printf(title, width / 2 - font:getWidth(title) / 2, height / 2 - 130, width, "left")
	love.graphics.printf(subtitle, width / 2 - font:getWidth(subtitle) / 2, height / 2 - 100, width, "left")

	self.ResumeButton:Draw()
	self.MenuButton:Draw()
	self.QuitButton:Draw()
end

--- Checks if any pause button is pressed.
---@param PositionMouse {X: number, Y: number}
---@param CursorRadius number
---@return boolean
function PauseInterface:IsPressed(PositionMouse, CursorRadius)
	if self.ResumeButton:IsPressed(PositionMouse, CursorRadius) then
		return true
	end
	if self.MenuButton:IsPressed(PositionMouse, CursorRadius) then
		return true
	end
	if self.QuitButton:IsPressed(PositionMouse, CursorRadius) then
		return true
	end
	return false
end

return PauseInterface
