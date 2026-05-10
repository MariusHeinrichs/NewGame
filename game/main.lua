local MainMenuInterface = require("Interfaces.mainMenuInterface")
local PauseInterface = require("Interfaces.pauseInterface")
local MatchSetup = require("Systems.matchSetup")
local GameStateModes = require("src.gameStateModes")
local GameStateTransitions = require("src.gameStateTransitions")

local gameState = {
	Mode = GameStateModes.START,
}

---@type { World: World | nil, Resources: Resources | nil, HasInitializedMatch: boolean }
local runtime = {
	World = nil,
	Resources = nil,
	HasInitializedMatch = false,
}

---@type { Battle: BattleInterface | nil, MainMenu: MainMenuInterface | nil, Pause: any }
local interfaces = {
	Battle = nil,
	MainMenu = nil,
	Pause = nil,
}

local function resetRuntimeState()
	local world, resources, battleInterface, hasInitializedMatch = MatchSetup.CreateDefaultRuntimeState()
	runtime.World = world
	runtime.Resources = resources
	runtime.HasInitializedMatch = hasInitializedMatch
	interfaces.Battle = battleInterface
end

function love.load()
	love.graphics.setColor(1, 1, 1)
	interfaces.MainMenu = MainMenuInterface.new(MainMenuInterface, gameState, resetRuntimeState)
	interfaces.Pause = PauseInterface.new(PauseInterface, gameState)
end

function love.update(dt)
	if gameState.Mode == GameStateModes.RUNNING then
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
		local width, height = love.graphics.getDimensions()
		local font = love.graphics.getFont()
		local startPrompt = "Press enter to start the game."
		love.graphics.printf(startPrompt,
			width / 2 - font:getWidth(startPrompt) / 2, height / 2, width, "left")
	end

	if gameState.Mode == GameStateModes.MENU then
		interfaces.MainMenu:Draw()
	end

	if gameState.Mode == GameStateModes.RUNNING then
		runtime.World:Draw()
		interfaces.Battle:Draw()
	end

	if gameState.Mode == GameStateModes.PAUSE then
		runtime.World:Draw()
		interfaces.Battle:Draw()
		interfaces.Pause:Draw()
	end
end

function love.keypressed(key)
	if key == "escape" and gameState.Mode == GameStateModes.RUNNING then
		GameStateTransitions.EnterPause(gameState)
		return
	end

	if key == "escape" and gameState.Mode == GameStateModes.PAUSE then
		GameStateTransitions.EnterRunning(gameState)
		return
	end

	if key == "escape" and gameState.Mode == GameStateModes.START then
		love.event.quit()
		return
	end

	if key == "escape" and gameState.Mode == GameStateModes.MENU then
		GameStateTransitions.EnterStart(gameState)
		return
	end

	if gameState.Mode == GameStateModes.START then
		if key == "return" then
			GameStateTransitions.EnterMenu(gameState)
		end
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	if gameState.Mode == GameStateModes.MENU then
		if button == 1 then
			local uiClickHandled = interfaces.MainMenu:IsPressed({ X = x, Y = y }, 0)
			if uiClickHandled then
				return
			end
		end
	end

	if gameState.Mode == GameStateModes.RUNNING then
		if button == 1 then
			local uiClickHandled = interfaces.Battle:IsPressed({ X = x, Y = y }, 0)
			if not uiClickHandled then
				local placed, reason = runtime.World:PlaceStructure(interfaces.Battle:GetSelectedStructureType(), runtime.Resources,
					x, y)
				if not placed then
					interfaces.Battle:ShowPlacementFailure(reason)
				end
			end
		end
	end

	if gameState.Mode == GameStateModes.PAUSE then
		if button == 1 then
			interfaces.Pause:IsPressed({ X = x, Y = y }, 0)
		end
	end
end

function love.resize(w, h)
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
