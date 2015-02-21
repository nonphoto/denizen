require("vector")
require("util")

local terrain = {}

terrain.newLine = function(self, a, b)
   local result = {}
   result.a = a
   result.b = b
   result.ahandle = ui:newid()
   result.bhandle = ui:newid()
   result.p = (a + b) / 2
   result.line = (b - a) / 2
   result.hw = vector.abs(result.line)
   result.normal = -1 * vector.normalize(vector.perpendicular(result.line))
   table.insert(self, result)
end

local setA = function(result, a)
   result.a = a
   result.p = (result.a + result.b) / 2
   result.line = (result.b - result.a) / 2
   result.hw = vector.abs(result.line)
   result.normal = -1 * vector.normalize(vector.perpendicular(result.line))
end

local setB = function(result, b)
   result.b = b
   result.p = (result.a + result.b) / 2
   result.line = (result.b - result.a) / 2
   result.hw = vector.abs(result.line)
   result.normal = -1 * vector.normalize(vector.perpendicular(result.line))
end

terrain.pointInRadius = function(self, point, radius)
   for k, v in ipairs(self) do
      if vector.lenSq(v.a - point) <= radius * radius and v.a ~= point then
	 return v.a
      elseif vector.lenSq(v.b - point) <= radius * radius and v.b ~= point then
	 return v.b
      end
   end
end

terrain.update = function(self)
   for k, v in ipairs(self) do
      local a = ui:handle(v.ahandle, v.a, 7)
      if a then
	 setA(v, a)
      end
      a = self:pointInRadius(v.a, 7)
      if a then
	 setA(v, a)
      end

      local b = ui:handle(v.bhandle, v.b, 7)
      if b then
	 setB(v, b)
      end
      b = self:pointInRadius(v.b, 7)
      if b then
	 setB(v, b)
      end
   end
end

terrain.draw = function(self)
   for k, v in ipairs(self) do
      if v.color then
	 love.graphics.setColor(255, 0, 0)
	 v.color = false
      else
	 love.graphics.setColor(255, 255, 255)
      end
      
      love.graphics.line(v.p.x - v.line.x,
			 v.p.y - v.line.y,
			 v.p.x + v.line.x,
			 v.p.y + v.line.y)

      love.graphics.setColor(255, 0, 0)
      love.graphics.line(v.p.x,
			 v.p.y,
			 v.p.x + v.normal.x * 10,
			 v.p.y + v.normal.y * 10)
   end
end

terrain.collideSolid = function(self, position, halfwidth)
   local p = position
   local hw = halfwidth
   
   local result = vector()
   for k, v in ipairs(self) do

      -- x axis
      local xaxis = false
      local dx = v.p.x - p.x
      local wx = v.hw.x + hw.x
      if math.abs(dx) < wx then
	 if dx > 0 then
	    xaxis = dx - wx
	 else
	    xaxis = dx + wx
	 end
      end

      -- y axis
      local yaxis = false
      local dy = v.p.y - p.y
      local wy = v.hw.y + hw.y
      if math.abs(dy) < wy then
	 if dy > 0 then
	    yaxis = dy - wy
	 else
	    yaxis = dy + wy
	 end
      end

      -- hypotenuse
      local haxis = false
      local dh = vector.len((p - v.p):projectOn(v.normal))
      local wh = vector.len((hw):projectOn(vector.abs(v.normal)))
      if dh < wh then
	 if dh > 0 then
	    haxis = wh - dh
	 else
	    haxis = dh + wh
	 end
      end

      if xaxis and yaxis and haxis then
	 v.color = true
	 local a = math.min(math.abs(haxis), math.min(math.abs(xaxis), (math.abs(yaxis))))
	 if a == math.abs(xaxis) then
	    p.x = p.x + xaxis
	 elseif a == math.abs(yaxis) then
	    p.y = p.y + yaxis
	 elseif a == math.abs(haxis) then
	    p = p + v.normal * haxis
	 else
	    -- impossible
	 end
      end
   end
   
   return p - position
end

terrain.collide = function(self, position, halfwidth, colliding)
   local p = vector(position.x, position.y)
   local hw = halfwidth
   local state = "none"
   
   local result = vector()
   for k, v in ipairs(self) do

      -- x axis
      local xaxis = false
      local dx = v.p.x - p.x
      local wx = v.hw.x + hw.x
      if math.abs(dx) < wx then
	 if dx > 0 then
	    xaxis = dx - wx
	 else
	    xaxis = dx + wx
	 end
      end

      -- y axis
      local yaxis = false
      local dy = v.p.y - p.y
      local wy = v.hw.y + hw.y
      if math.abs(dy) < wy then
	 if dy > 0 then
	    yaxis = dy - wy
	 else
	    yaxis = dy + wy
	 end
      end

      -- hypotenuse
      local haxis = false
      local d = (v.p - p):projectOn(v.normal)
      local dh = vector.len(d)
      local wh = vector.len((hw):projectOn(vector.abs(v.normal)))
      if dh < wh then
	 if (v.normal.y >= 0 and d.y >= 0) or (v.normal.y <= 0 and d.y <= 0) then
	    haxis = -(wh - dh)
	 else
	    haxis = wh - dh
	 end
      end
      
      if xaxis and yaxis and haxis then
	 v.color = true
	 state = "intersecting"
	 local a = math.min(math.abs(haxis), math.min(math.abs(xaxis), (math.abs(yaxis))))
	 if a == math.abs(xaxis) and math.sign(xaxis) == math.sign(v.normal.x) then
	    p.x = p.x + xaxis
	    state = "projected"
	 elseif a == math.abs(yaxis) and math.sign(yaxis) == math.sign(v.normal.y) then
	    p.y = p.y + yaxis
	    state = "projected"
	 elseif a == math.abs(haxis) and haxis > 0 then
	    p = p + v.normal * haxis
	    state = "projected"
	 end
      end
   end
   
   return state, p - position
end

return terrain
