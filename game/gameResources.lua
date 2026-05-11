--- Resources module — manages the player's currencies.

local BASE_GOLD_INCOME_VALUE = 8
local BASE_METAL_INCOME_VALUE = 4
local BASE_AETHER_INCOME_VALUE = 0
local INCOME_INTERVAL_SECONDS = 5

---@class Resources
---@field Gold number
---@field Metal number
---@field Aether number
---@field BaseGoldIncomeValue number
---@field BaseMetalIncomeValue number
---@field BaseAetherIncomeValue number
---@field IncomeInterval number
---@field IncomeTimer number
local Resources = {}
Resources.__index = Resources

--- Description of function Resources:new.
---@param gold number | nil
---@param metal number | nil
---@param aether number | nil
---@return Resources
function Resources:new(gold, metal, aether)
	return setmetatable({
		Gold = gold or 0,
		Metal = metal or 0,
		Aether = aether or 0,
		BaseGoldIncomeValue = BASE_GOLD_INCOME_VALUE,
		BaseMetalIncomeValue = BASE_METAL_INCOME_VALUE,
		BaseAetherIncomeValue = BASE_AETHER_INCOME_VALUE,
		IncomeInterval = INCOME_INTERVAL_SECONDS,
		IncomeTimer = 0,
	}, self)
end

--- Adds periodic base income for Gold and Metal.
---@param dt number
function Resources:Update(dt)
	self.IncomeTimer = self.IncomeTimer + dt

	while self.IncomeTimer >= self.IncomeInterval do
		self.IncomeTimer = self.IncomeTimer - self.IncomeInterval
		self:AddGold(self.BaseGoldIncomeValue)
		self:AddMetal(self.BaseMetalIncomeValue)
	end
end

--- Description of function Resources:AddGold.
---@param amount number
function Resources:AddGold(amount)
	self.Gold = self.Gold + amount
end

--- Description of function Resources:AddMetal.
---@param amount number
function Resources:AddMetal(amount)
	self.Metal = self.Metal + amount
end

--- Description of function Resources:AddAether.
---@param amount number
function Resources:AddAether(amount)
	self.Aether = self.Aether + amount
end

--- Increases periodic base income values for Gold and Metal.
---@param goldBonus number | nil
---@param metalBonus number | nil
function Resources:AddIncomeBonus(goldBonus, metalBonus)
	self.BaseGoldIncomeValue = self.BaseGoldIncomeValue + (goldBonus or 0)
	self.BaseMetalIncomeValue = self.BaseMetalIncomeValue + (metalBonus or 0)
end

--- Returns true and deducts cost if the player can afford it, otherwise false.
---@param costs table
---@return boolean
function Resources:Spend(costs)
	costs = costs or {}

	local gold = costs.Gold or 0
	local metal = costs.Metal or 0
	local aether = costs.Aether or 0

	if self.Gold < gold or self.Metal < metal or self.Aether < aether then
		return false
	end

	self.Gold = self.Gold - gold
	self.Metal = self.Metal - metal
	self.Aether = self.Aether - aether
	return true
end

return Resources
