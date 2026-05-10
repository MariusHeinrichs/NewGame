local Structure = require("Objects.Structures.structure")
local MainMenuInterface = require("Interfaces.mainMenuInterface")
local BattleInterface = require("Interfaces.battleInterface")
local World = require("world")
local Resources = require("resources")

local world = World:new()
local resources = Resources:new(100, 50, 10)

local gameState = {
	StartMenu = true,
	MainMenu = false,
	Running = false,
}

local interfaces = {
}

function love.load()
	love.graphics.setColor(1, 1, 1)
	interfaces.MainMenu = MainMenuInterface:new(gameState)
	interfaces.Battle = BattleInterface:new(resources)
end

function love.update(dt)
	if gameState.Running then
		world:Update(dt)
	end
end

function love.draw()
	love.graphics.printf("FPS: " .. love.timer.getFPS(), 10, 10, 200, "left")

	if gameState.StartMenu then
		local width, height = love.graphics.getDimensions()
		local font = love.graphics.getFont()
		love.graphics.printf("Press enter to start the game.",
			width / 2 - font:getWidth("Press enter to start the game...") / 2, height / 2, width, "left")
	end

	if gameState.MainMenu then
		interfaces.MainMenu:Draw()
	end

	if gameState.Running then
		interfaces.Battle:Draw()
		world:Draw()
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end

	if gameState.StartMenu then
		if key == "return" then
			gameState.StartMenu = false
			gameState.MainMenu = true
		end
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	if gameState.MainMenu then
		if button == 1 then
			interfaces.MainMenu:IsPressed({ X = x, Y = y }, 0)
		end
	end

	if gameState.Running then
		if button == 1 then
			local uiClickHandled = interfaces.Battle:IsPressed({ X = x, Y = y }, 0)
			if not uiClickHandled then
				world:PlaceStructure(interfaces.Battle:GetSelectedStructureType(), resources, x, y)
			end
		end
	end
end
