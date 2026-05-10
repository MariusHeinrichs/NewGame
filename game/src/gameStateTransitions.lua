local GameStateModes = require("src.gameStateModes")
local GameContext = require("src.gameContext")
local MatchSetup = require("Systems.matchSetup")

local GameStateTransitions = {}

--- Resets runtime and battle interface for a fresh match.
---@param startResources {Gold: number, Metal: number, Aether: number} | nil
function GameStateTransitions.ResetForNewMatch(startResources)
	local world, resources, battleInterface, hasInitializedMatch = MatchSetup.CreateDefaultRuntimeState(startResources)

	GameContext.Runtime.World = world
	GameContext.Runtime.Resources = resources
	GameContext.Runtime.HasInitializedMatch = hasInitializedMatch
	GameContext.Interfaces.Battle = battleInterface
end

--- Enters the main menu from the start screen.
function GameStateTransitions.EnterMenu()
	GameContext.GameState.Mode = GameStateModes.MENU
end

--- Enters running mode.
function GameStateTransitions.EnterRunning()
	if not GameContext.Runtime.World or not GameContext.Runtime.Resources or not GameContext.Interfaces.Battle then
		GameStateTransitions.ResetForNewMatch({Gold = 999, Metal = 999, Aether = 999})
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

return GameStateTransitions
