local MainMenuInterface = require("Interfaces.mainMenuInterface")
local PauseInterface = require("Interfaces.pauseInterface")
local StartInterface = require("Interfaces.startInterface")
local MatchSetup = require("Systems.matchSetup")
local GameStateModes = require("src.gameStateModes")
local GameContext = require("src.gameContext")
local GameInputRouter = require("src.gameInputRouter")

local gameState = GameContext.GameState
---@type { World: World | nil, Resources: Resources | nil, HasInitializedMatch: boolean }
local runtime = GameContext.Runtime
---@type { Battle: BattleInterface | nil, MainMenu: MainMenuInterface | nil, Pause: PauseInterface | nil, Start: StartInterface | nil }
local interfaces = GameContext.Interfaces

function love.load()
	love.graphics.setColor(1, 1, 1)
	interfaces.Start = StartInterface:new()
	interfaces.MainMenu = MainMenuInterface:new()
	interfaces.Pause = PauseInterface:new()
	GameInputRouter.InitializeHandlers()
end

function love.update(dt)
	if gameState.Mode == GameStateModes.RUNNING then
		if not runtime.World or not runtime.Resources or not interfaces.Battle then
			return
		end

		if not runtime.HasInitializedMatch then
			MatchSetup.InitializeDefault(runtime.World, runtime.Resources)
			runtime.HasInitializedMatch = true
		end
		interfaces.Battle:Update(dt)
		runtime.World:Update(dt)
	end
end

function love.draw()
	love.graphics.printf("FPS: " .. love.timer.getFPS(), 10, 10, 200, "left")

	if gameState.Mode == GameStateModes.START then
		if interfaces.Start then
			interfaces.Start:Draw()
		end
	end

	if gameState.Mode == GameStateModes.MENU then
		interfaces.MainMenu:Draw()
	end

	if gameState.Mode == GameStateModes.RUNNING then
		if runtime.World and interfaces.Battle then
			runtime.World:Draw()
			interfaces.Battle:Draw()
		end
	end

	if gameState.Mode == GameStateModes.PAUSE then
		if runtime.World and interfaces.Battle then
			runtime.World:Draw()
			interfaces.Battle:Draw()
		end
		interfaces.Pause:Draw()
	end
end

function love.resize(w, h)
	if interfaces.Start then
		interfaces.Start:RebuildLayout()
	end
	if interfaces.MainMenu then
		interfaces.MainMenu:RebuildLayout()
	end
	if interfaces.Battle then
		interfaces.Battle:RebuildLayout()
	end
	if interfaces.Pause then
		interfaces.Pause:RebuildLayout()
	end
end
