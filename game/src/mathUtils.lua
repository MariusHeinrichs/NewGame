local MathUtils = {}

---@param x number
---@param y number
---@return number, number
function MathUtils.Normalize(x, y)
	local len = math.sqrt(x * x + y * y)
	if len <= 0 then
		return 0, 0
	end
	return x / len, y / len
end

---@param value number
---@param minValue number
---@param maxValue number
---@return number
function MathUtils.Clamp(value, minValue, maxValue)
	if value < minValue then
		return minValue
	end
	if value > maxValue then
		return maxValue
	end
	return value
end

return MathUtils