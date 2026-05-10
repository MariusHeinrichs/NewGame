--- Shared collision helper functions.

local Collisions = {}

--- Returns true if two circles overlap.
---@param ax number
---@param ay number
---@param ar number
---@param bx number
---@param by number
---@param br number
---@return boolean
function Collisions.CirclesOverlap(ax, ay, ar, bx, by, br)
	local dx = ax - bx
	local dy = ay - by
	local radiusSum = ar + br
	return (dx * dx + dy * dy) < (radiusSum * radiusSum)
end

--- Returns true if a circle intersects an axis-aligned rectangle.
---@param cx number
---@param cy number
---@param radius number
---@param rx number
---@param ry number
---@param rw number
---@param rh number
---@return boolean
function Collisions.CircleIntersectsRect(cx, cy, radius, rx, ry, rw, rh)
	local closestX = math.max(rx, math.min(cx, rx + rw))
	local closestY = math.max(ry, math.min(cy, ry + rh))
	local dx = cx - closestX
	local dy = cy - closestY
	return (dx * dx + dy * dy) < (radius * radius)
end

--- Returns true if two axis-aligned rectangles overlap.
---@param ax number
---@param ay number
---@param aw number
---@param ah number
---@param bx number
---@param by number
---@param bw number
---@param bh number
---@return boolean
function Collisions.RectsOverlap(ax, ay, aw, ah, bx, by, bw, bh)
	return ax < bx + bw and ax + aw > bx and ay < by + bh and ay + ah > by
end

--- Returns the bounds (x, y, w, h) of a centered square entity.
---@param centerX number
---@param centerY number
---@param size number
---@return number, number, number, number
function Collisions.GetRectBounds(centerX, centerY, size)
	local halfSize = size / 2
	return centerX - halfSize, centerY - halfSize, size, size
end

return Collisions
