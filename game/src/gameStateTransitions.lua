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

return GameStateTransitions
