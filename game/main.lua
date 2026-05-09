local Unit = require("Objects.Units.unit")
local MainMenuButtons = require("Buttons.mainMenuButtons")

local units = {
}

local gameState = {
	StartMenu = true,
	MainMenu = false,
	Running = false,
}

local buttons = {
}

function love.load()
	width, height = love.graphics.getDimensions()
	font = love.graphics.getFont()
	love.graphics.setColor(1, 1, 1)

	table.insert(units, Unit:new("Unit1", 100, 10, 5, 20, 10))
	table.insert(units, Unit:new("Unit2", 150, 15, 10, 1, 40))
	buttons.MainMenu = MainMenuButtons:new(gameState)
end

function love.update(dt)
	if gameState.Running then
		for _, unit in ipairs(units) do
			unit:Move("right")
		end
	end
end

function love.draw()
	love.graphics.printf("FPS: " .. love.timer.getFPS(), 10, 10, 200, "left")

	if gameState.StartMenu then
		love.graphics.printf("Press enter to start the game.",
			width / 2 - font:getWidth("Press enter to start the game...") / 2, height / 2, width, "left")
	end

	if gameState.MainMenu then
		buttons.MainMenu:Draw()
	end

	if gameState.Running then
		for _, unit in ipairs(units) do
			unit:Draw()
		end
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end

	if gameState.MainMenu then
		if key == "return" then
			gameState.MainMenu = false
			gameState.Running = true
		end
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
			buttons.MainMenu:IsPressed({ X = x, Y = y }, 0)
		end
	end
end
