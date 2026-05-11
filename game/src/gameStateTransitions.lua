local GameStateModes = require("src.gameStateModes")
local GameContext = require("src.gameContext")
local MatchSetup = require("Systems.matchSetup")

local GameStateTransitions = {}

--- Resets runtime and battle interface for a fresh match.
---@param startResources {Gold: number, Metal: number, Aether: number} | nil
function GameStateTransitions.ResetForNewMatch(startResources)
	local world, resources, battleInterface, hasInitializedMatch, enemyBuilderAI = MatchSetup.CreateDefaultRuntimeState(
		startResources)

	GameContext.Runtime.World = world
	GameContext.Runtime.Resources = resources
	GameContext.Runtime.HasInitializedMatch = hasInitializedMatch
	GameContext.Runtime.EnemyBuilderAI = enemyBuilderAI
	GameContext.Interfaces.Battle = battleInterface
end

--- Enters the main menu from the start screen.
function GameStateTransitions.EnterMenu()
	GameContext.GameState.Mode = GameStateModes.MENU
end

--- Starts a completely fresh match and enters running mode.
---@param startResources {Gold: number, Metal: number, Aether: number} | nil
function GameStateTransitions.EnterNewGame(startResources)
	GameStateTransitions.ResetForNewMatch(startResources or { Gold = 999, Metal = 999, Aether = 999 })
	GameContext.GameState.Won = false
	GameContext.GameState.Mode = GameStateModes.RUNNING
end

--- Enters running mode.
function GameStateTransitions.EnterRunning()
	if not GameContext.Runtime.World or not GameContext.Runtime.Resources or not GameContext.Interfaces.Battle then
		GameStateTransitions.EnterNewGame({ Gold = 999, Metal = 999, Aether = 999 })
		return
	end
	GameContext.GameState.Mode = GameStateModes.RUNNING
end

--- Enters pause mode from running gameplay.
function GameStateTransitions.EnterPause()
	GameContext.GameState.Mode = GameStateModes.PAUSE
end

--- Enters the start screen from the main menu.
function GameStateTransitions.EnterStart()
	GameContext.GameState.Mode = GameStateModes.START
end

--- Enters the game over screen from running gameplay.
function GameStateTransitions.EnterGameOver()
	GameContext.GameState.Mode = GameStateModes.GAME_OVER
end

return GameStateTransitions
