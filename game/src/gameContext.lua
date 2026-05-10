local GameStateModes = require("src.gameStateModes")

local GameContext = {
	GameState = {
		Mode = GameStateModes.START,
	},
	Runtime = {
		World = nil,
		Resources = nil,
		HasInitializedMatch = false,
	},
	Interfaces = {
		Battle = nil,
		MainMenu = nil,
		Pause = nil,
	},
}

return GameContext
