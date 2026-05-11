local GameStateModes = require("src.gameStateModes")
local GameStateTransitions = require("src.gameStateTransitions")
local GameContext = require("src.gameContext")

local GameInputRouter = {}

--- Routes key presses based on the current game state.
---@param key string
---@return boolean handled
function GameInputRouter.HandleKeyPressed(key)
	local gameState = GameContext.GameState

	if key == "escape" and gameState.Mode == GameStateModes.RUNNING then
		GameStateTransitions.EnterPause()
		return true
	end

	if key == "escape" and gameState.Mode == GameStateModes.PAUSE then
		GameStateTransitions.EnterRunning()
		return true
	end

	if key == "escape" and gameState.Mode == GameStateModes.START then
		love.event.quit()
		return true
	end

	if key == "escape" and gameState.Mode == GameStateModes.MENU then
		GameStateTransitions.EnterStart()
		return true
	end

	if key == "f3" and (gameState.Mode == GameStateModes.RUNNING or gameState.Mode == GameStateModes.PAUSE) then
		local world = GameContext.Runtime.World
		if world and type(world.ToggleMapDebug) == "function" then
			world:ToggleMapDebug()
			return true
		end
	end

	if key == "return" and gameState.Mode == GameStateModes.START then
		GameStateTransitions.EnterMenu()
		return true
	end

	return false
end

--- Routes mouse presses based on the current game state.
---@param x number
---@param y number
---@param button number
---@return boolean handled
function GameInputRouter.HandleMousePressed(x, y, button)
	local gameState = GameContext.GameState
	---@type { MainMenu: MainMenuInterface | nil, Battle: BattleInterface | nil, Pause: PauseInterface | nil }
	local interfaces = GameContext.Interfaces

	if gameState.Mode == GameStateModes.MENU then
		if interfaces.MainMenu then
			interfaces.MainMenu:HandleMousePressed(x, y, button)
		end
		return true
	end

	if gameState.Mode == GameStateModes.RUNNING then
		if interfaces.Battle then
			interfaces.Battle:HandleMousePressed(x, y, button)
		end
		return true
	end

	if gameState.Mode == GameStateModes.PAUSE then
		if interfaces.Pause then
			interfaces.Pause:HandleMousePressed(x, y, button)
		end
		return true
	end

	return false
end

--- Installs the input handlers for peripheral devices.
function GameInputRouter.InitializeHandlers()
	love.keypressed = function(key)
		GameInputRouter.HandleKeyPressed(key)
	end

	love.mousepressed = function(x, y, button, istouch, presses)
		GameInputRouter.HandleMousePressed(x, y, button)
	end
end

return GameInputRouter
