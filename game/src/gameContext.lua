local GameStateModes = require("src.gameStateModes")

local GameContext = {
	GameState = {
		Mode = GameStateModes.START,
	},
	Runtime = {
		World = nil,
		Resources = nil,
		HasInitializedMatch = false,
		EnemyBuilderAI = nil,
	},
	Interfaces = {
		Battle = nil,
		CombatOverlay = nil,
		Start = nil,
		MainMenu = nil,
		Pause = nil,
	},
}

return GameContext
