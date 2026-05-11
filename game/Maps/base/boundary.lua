--- Static map boundary definition used for movement and placement blocking.

local Boundary = {}
Boundary.__index = Boundary

---@class Boundary

--- Creates a new Boundary.
---@param shape table
---@param blocksMovement boolean | nil
---@param blocksPlacement boolean | nil
---@param tags table | nil
---@return Boundary
function Boundary:new(shape, blocksMovement, blocksPlacement, tags)
	local boundary = {
		Shape = shape,
		BlocksMovement = blocksMovement ~= false,
		BlocksPlacement = blocksPlacement ~= false,
		Tags = tags or {},
	}
	return setmetatable(boundary, self)
end

--- Creates a rectangular Boundary.
---@param x number
---@param y number
---@param width number
---@param height number
---@param blocksMovement boolean | nil
---@param blocksPlacement boolean | nil
---@param tags table | nil
---@return Boundary
function Boundary:Rect(x, y, width, height, blocksMovement, blocksPlacement, tags)
	return self:new({ Type = "rect", X = x, Y = y, Width = width, Height = height }, blocksMovement, blocksPlacement, tags)
end

--- Creates a circular Boundary.
---@param x number
---@param y number
---@param radius number
---@param blocksMovement boolean | nil
---@param blocksPlacement boolean | nil
---@param tags table | nil
---@return Boundary
function Boundary:Circle(x, y, radius, blocksMovement, blocksPlacement, tags)
	return self:new({ Type = "circle", X = x, Y = y, Radius = radius }, blocksMovement, blocksPlacement, tags)
end

return Boundary
