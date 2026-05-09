local Unit = require("Objects.Units.unit")
local Structure = require("Objects.Structures.structure")
local MainMenuInterface = require("Interfaces.mainMenuInterface")
local BattleInterface = require("Interfaces.battleInterface")

local units = {
}

local structures = {
}

local gameState = {
	StartMenu = true,
	MainMenu = false,
	Running = false,
}

local interfaces = {
}

function love.load()
	love.graphics.setColor(1, 1, 1)

	table.insert(units, Unit:new("Unit1", 100, 10, 5, 20, 10))
	table.insert(units, Unit:new("Unit2", 150, 15, 10, 1, 40))
	table.insert(structures, Structure:new("Structure1", 200, 20, 30, 2))
	table.insert(structures, Structure:new("Structure2", 300, 30, 50, 5))
	interfaces.MainMenu = MainMenuInterface:new(gameState)
	interfaces.Battle = BattleInterface:new(gameState)
end

function love.update(dt)
	if gameState.Running then
		for i = #units, 1, -1 do
			local unit = units[i]
			unit:Move("right")
			if unit.Health <= 0 then
				table.remove(units, i)
			end
		end

		for _, structure in ipairs(structures) do
			local spawnedUnit = structure:SpawnUnit(dt)
			if spawnedUnit then
				table.insert(units, spawnedUnit)
			end
		end
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
		for _, unit in ipairs(units) do
			unit:Draw()
		end
		for _, structure in ipairs(structures) do
			structure:Place({ X = 100, Y = 100 + _* 80 })
			structure:Draw()
		end
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
end
