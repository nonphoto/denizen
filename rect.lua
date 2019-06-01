require("vector")

rect = {}
rect.__index = rect

function rect.new(x, y, w, h)
	local instance = {}
	instance.position = vector.new(x or 0, y or 0)
	instance.halfwidth = vector.new(w / 2, h / 2)
	return setmetatable(instance, rect)
end

function rect.__add(a, b)
	if type(a) == "number" then
		return rect.new(
