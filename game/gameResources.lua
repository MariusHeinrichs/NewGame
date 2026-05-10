--- Resources module — manages the player's currencies.

---@class Resources
---@field Gold number
---@field Metal number
---@field Aether number
local Resources = {}
Resources.__index = Resources

---@param gold number | nil
---@param metal number | nil
---@param aether number | nil
---@return Resources
function Resources:new(gold, metal, aether)
	return setmetatable({
		Gold = gold or 0,
		Metal = metal or 0,
		Aether = aether or 0,
	}, self)
end

---@param amount number
function Resources:AddGold(amount)
	self.Gold = self.Gold + amount
end

---@param amount number
function Resources:AddMetal(amount)
	self.Metal = self.Metal + amount
end

---@param amount number
function Resources:AddAether(amount)
	self.Aether = self.Aether + amount
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

--- Returns true if the player can afford the given cost.
---@param costs table
---@return boolean
function Resources:CanAfford(costs)
	costs = costs or {}
	return self.Gold >= (costs.Gold or 0)
		and self.Metal >= (costs.Metal or 0)
		and self.Aether >= (costs.Aether or 0)
end

return Resources
