local MapDebugRenderer = {}

---@param path table | nil
local function drawPathDebug(path)
	if not path or type(path.GetWaypoints) ~= "function" then
		return
	end

	local waypoints = path:GetWaypoints()
	if not waypoints or #waypoints == 0 then
		return
	end

	if path.Team == "enemy" then
		love.graphics.setColor(0.95, 0.35, 0.35, 0.8)
	else
		love.graphics.setColor(0.2, 0.85, 0.35, 0.8)
	end

	for i = 1, #waypoints - 1 do
		local startPoint = waypoints[i]
		local endPoint = waypoints[i + 1]
		love.graphics.line(startPoint.X, startPoint.Y, endPoint.X, endPoint.Y)
	end

	for _, point in ipairs(waypoints) do
		love.graphics.circle("fill", point.X, point.Y, 3)
	end
end

---@param boundary table | nil
local function drawBoundaryDebug(boundary)
	if not boundary or not boundary.Shape then
		return
	end

	if boundary.BlocksMovement == false and boundary.BlocksPlacement == false then
		love.graphics.setColor(0.6, 0.6, 0.6, 0.35)
	elseif boundary.BlocksMovement and boundary.BlocksPlacement then
		love.graphics.setColor(0.95, 0.75, 0.2, 0.4)
	elseif boundary.BlocksMovement then
		love.graphics.setColor(0.95, 0.45, 0.2, 0.4)
	else
		love.graphics.setColor(0.35, 0.75, 0.95, 0.4)
	end

	if boundary.Shape.Type == "rect" then
		love.graphics.rectangle("fill", boundary.Shape.X, boundary.Shape.Y, boundary.Shape.Width, boundary.Shape.Height)
		love.graphics.setColor(1, 1, 1, 0.7)
		love.graphics.rectangle("line", boundary.Shape.X, boundary.Shape.Y, boundary.Shape.Width, boundary.Shape.Height)
		return
	end

	if boundary.Shape.Type == "circle" then
		love.graphics.circle("fill", boundary.Shape.X, boundary.Shape.Y, boundary.Shape.Radius)
		love.graphics.setColor(1, 1, 1, 0.7)
		love.graphics.circle("line", boundary.Shape.X, boundary.Shape.Y, boundary.Shape.Radius)
	end
end

---@param map table | nil
function MapDebugRenderer.Draw(map)
	if not map then
		return
	end

	if map.Paths then
		for _, path in ipairs(map.Paths) do
			drawPathDebug(path)
		end
	end

	if map.Boundaries then
		for _, boundary in ipairs(map.Boundaries) do
			drawBoundaryDebug(boundary)
		end
	end

	love.graphics.setColor(1, 1, 1, 1)
end

return MapDebugRenderer
