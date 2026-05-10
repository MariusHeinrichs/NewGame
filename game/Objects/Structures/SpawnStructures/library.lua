--- Library structure - spawns Mages.

local SpawningStructure = require("Objects.Structures.base.spawningStructure")
local UnitRegistry = require("Objects.Units.registry.unitRegistry")

local Mage = UnitRegistry.GetByType("Mage")

---@class Library : SpawningStructure
local Library = {}
Library.__index = Library

Library.Size  = 26
Library.Costs = { Gold = 20, Metal = 5, Aether = 15 }
Library.IncomeBonusGold = 1
Library.IncomeBonusMetal = 1

setmetatable(Library, { __index = SpawningStructure })

---Creates a new Library.
---@return Library
function Library:new()
	local instance = SpawningStructure.new(self, "Library",
		160,            -- Health
		6,              -- Armor
		Library.Size,   -- Size
		1.2,            -- SpawnRate
		Mage,
		Library.Costs,
		Library.IncomeBonusGold,
		Library.IncomeBonusMetal,
		0
	)
	return instance
end

return Library
