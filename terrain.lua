require("vector")
require("util")

local terrain = {}
terrain.walls = {}

function terrain:newWall(a, b)
   local result = {}
   result.a = a
   result.b = b
   result.ahandle = ui.button(a)
   result.bhandle = ui.button(b)
   result.p = (a + b) / 2
   result.line = (b - a) / 2
   result.hw = vector.abs(result.line)
   result.normal = -1 * vector.normalize(vector.perpendicular(result.line))
   table.insert(self.walls, result)
end

local setA = function(wall, a)
   wall.a = a
   wall.p = (wall.a + wall.b) / 2
   wall.line = (wall.b - wall.a) / 2
   wall.hw = vector.abs(wall.line)
   wall.normal = -1 * vector.normalize(vector.perpendicular(wall.line))
   wall.ahandle.position = a
end

local setB = function(wall, b)
   wall.b = b
   wall.p = (wall.a + wall.b) / 2
   wall.line = (wall.b - wall.a) / 2
   wall.hw = vector.abs(wall.line)
   wall.normal = -1 * vector.normalize(vector.perpendicular(wall.line))
   wall.bhandle.position = b
end

function terrain:deleteWall(wall)
   wall.deleted = true
end

function terrain:pointInRadius(point, radius)
   for k, v in ipairs(self.walls) do
      local da = vector.lenSq(v.a - point)
      if da <= radius * radius and da >= 0.1 then
	 return v.a
      end

      local db = vector.lenSq(v.b - point)
      if db <= radius * radius and db >= 0.1 then
	 return v.b
      end
   end
end

function terrain:update()
   for k, v in ipairs(self.walls) do
      if v.deleted then
	 table.remove(self.walls, k)
      end
      if currentMode == "edit" then
	 local a = v.ahandle()
	 if a then
	    setA(v, a)
	    local x = self:pointInRadius(v.a, 7)
	    if x then
	       setA(v, x)
	    end
	 end

	 local b = v.bhandle(v.b, 7)
	 if b then
	    setB(v, b)
	    local x = self:pointInRadius(v.b, 7)
	    if x then
	       setB(v, x)
	    end
	 end
      end
   end
end

function terrain:draw()
   for k, v in ipairs(self.walls) do
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

function terrain:collide(position, halfwidth)
   local p = vector(position.x, position.y)
   local hw = halfwidth
   local state = "none"
   local wall = nil
   
   local result = vector()
   for k, v in ipairs(self.walls) do

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
	 wall = v
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
   
   return state, wall, p - position
end

return terrain

-- terrain.collideSolid = function(self, position, halfwidth)
--    local p = position
--    local hw = halfwidth
   
--    local result = vector()
--    for k, v in ipairs(self) do

--       -- x axis
--       local xaxis = false
--       local dx = v.p.x - p.x
--       local wx = v.hw.x + hw.x
--       if math.abs(dx) < wx then
-- 	 if dx > 0 then
-- 	    xaxis = dx - wx
-- 	 else
-- 	    xaxis = dx + wx
-- 	 end
--       end

--       -- y axis
--       local yaxis = false
--       local dy = v.p.y - p.y
--       local wy = v.hw.y + hw.y
--       if math.abs(dy) < wy then
-- 	 if dy > 0 then
-- 	    yaxis = dy - wy
-- 	 else
-- 	    yaxis = dy + wy
-- 	 end
--       end

--       -- hypotenuse
--       local haxis = false
--       local dh = vector.len((p - v.p):projectOn(v.normal))
--       local wh = vector.len((hw):projectOn(vector.abs(v.normal)))
--       if dh < wh then
-- 	 if dh > 0 then
-- 	    haxis = wh - dh
-- 	 else
-- 	    haxis = dh + wh
-- 	 end
--       end

--       if xaxis and yaxis and haxis then
-- 	 v.color = true
-- 	 local a = math.min(math.abs(haxis), math.min(math.abs(xaxis), (math.abs(yaxis))))
-- 	 if a == math.abs(xaxis) then
-- 	    p.x = p.x + xaxis
-- 	 elseif a == math.abs(yaxis) then
-- 	    p.y = p.y + yaxis
-- 	 elseif a == math.abs(haxis) then
-- 	    p = p + v.normal * haxis
-- 	 else
-- 	    -- impossible
-- 	 end
--       end
--    end
   
--    return p - position
-- end
