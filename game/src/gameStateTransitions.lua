local GameStateModes = require("src.gameStateModes")

local GameStateTransitions = {}

--- Enters the main menu from the start screen.
---@param gameState {Mode: string}
function GameStateTransitions.EnterMenu(gameState)
	gameState.Mode = GameStateModes.MENU
end

--- Enters running mode and resets runtime using the provided callback.
---@param gameState {Mode: string}
---@param resetRuntimeState fun() | nil
function GameStateTransitions.EnterRunning(gameState, resetRuntimeState)
	if resetRuntimeState then
		resetRuntimeState()
	end
	gameState.Mode = GameStateModes.RUNNING
end

--- Enters pause mode from running gameplay.
---@param gameState {Mode: string}
function GameStateTransitions.EnterPause(gameState)
	gameState.Mode = GameStateModes.PAUSE
end

--- Enters the start screen from the main menu.
--- @param gameState {Mode: string}
function GameStateTransitions.EnterStart(gameState)
	gameState.Mode = GameStateModes.START
end

return GameStateTransitions
