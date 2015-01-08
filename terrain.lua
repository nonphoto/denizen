require("vector")
require("util")

local Terrain = {}

function t0()
   local result = {}
   local edges = {}
   edges.up = "empty"
   edges.down = "empty"
   edges.left = "empty"
   edges.right = "empty"
   result.edges = edges
   result.vertices = false
   return result
end

function t1()
   local result = {}
   local edges = {}
   edges.up = "solid"
   edges.down = "solid"
   edges.left = "solid"
   edges.right = "solid"
   result.edges = edges
   result.vertices = {0, 0, 1, 0, 1, 1, 0, 1}
   return result
end

function t2()
   local result = {}
   local edges = {}
   edges.up = "partial"
   edges.down = "solid"
   edges.left = "solid"
   edges.right = "partial"
   result.edges = edges
   result.vertices = {0, 0, 1, 1, 0, 1}
   return result
end

function t3()
   local result = {}
   local edges = {}
   edges.up = "partial"
   edges.down = "solid"
   edges.left = "partial"
   edges.right = "solid"
   result.edges = edges
   result.height = function(x)
      local y = 1 - x
      return y
   end
   result.vertices = {0, 1, 1, 0, 1, 1}
   return result
end

Terrain.data = {
   {t1(), t1(), t1(), t1(), t1(), t1(), t1(), t1(), t1(), t1(), t1(), t1(), t1()},
   {t1(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t1()},
   {t1(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t1()},
   {t1(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t1()},
   {t1(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t1()},
   {t1(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t1()},
   {t1(), t0(), t0(), t0(), t0(), t0(), t0(), t3(), t0(), t0(), t3(), t0(), t1()},
   {t1(), t0(), t0(), t0(), t0(), t0(), t3(), t1(), t0(), t0(), t0(), t3(), t1()},
   {t1(), t1(), t1(), t1(), t1(), t1(), t1(), t1(), t1(), t1(), t1(), t1(), t1()},
}

Terrain.data.w = #Terrain.data[1]
Terrain.data.h = #Terrain.data

Terrain.lines = {
   {
      p = vector(200, 200),
      hw = vector(100, 50),
      normal = -1 * vector.normalize(vector.perpendicular(vector(100, 50)))
   }
}

for y = 1, Terrain.data.h do
   for x = 1, Terrain.data.w do
      local tile = Terrain.data[y][x]
      
      if y > 1 then
	 local up = Terrain.data[y - 1][x]
	 if tile.edges.up == "solid" and up.edges.down == "solid" then
	    tile.edges.up = "empty"
	 end
      end

      if y < Terrain.data.h - 1 then
	 local down = Terrain.data[y + 1][x]	 
	 if tile.edges.down == "solid" and down.edges.up == "solid" then
	    tile.edges.down = "empty"
	 end
      end
      
      if x > 1 then
	 local left = Terrain.data[y][x - 1]
	 if tile.edges.left == "solid" and left.edges.right == "solid" then
	    tile.edges.left = "empty"
	 end
      end
      
      if x < Terrain.data.w - 1 then
	 local right = Terrain.data[y][x + 1]
	 if tile.edges.right == "solid" and right.edges.left == "solid" then
	    tile.edges.right = "empty"
	 end
      end
   end
end

Terrain.p = vector()
Terrain.hw = vector()

Terrain.draw = function(self)
   if false then
      for y = 1, self.data.h do
	 for x = 1, self.data.w do
	    love.graphics.push()
	    love.graphics.translate((x - 1) * tileSize, (y - 1) * tileSize)
	 
	    local tile = self.data[y][x]
	    if tile.vertices then
	       local vertices = map(function(i) return i * tileSize end, tile.vertices)
	       love.graphics.setColor(100, 100, 100, 255)
	       love.graphics.polygon("fill", vertices)
	    end
	  
	    if self.data[y][x].outline then
	       love.graphics.setColor(0, 0, 255)
	       love.graphics.polygon("line",
				     0, 0,
				     0, tileSize,
				     tileSize, tileSize,
				     tileSize, 0)
	       tile.outline = false
	    end
	 
	    love.graphics.pop()
	 end
      end
   end

   for k, v in ipairs(self.lines) do
      if v.color then
	 love.graphics.setColor(255, 0, 0)
	 v.color = false
      else
	 love.graphics.setColor(255, 255, 255)
      end
      
      love.graphics.line(v.p.x - v.hw.x,
			 v.p.y - v.hw.y,
			 v.p.x + v.hw.x,
			 v.p.y + v.hw.y)
      
      local d = (v.p - self.p):projectOn(v.normal)
      local w = (self.hw):projectOn(vector.abs(v.normal))

      love.graphics.setColor(255, 0, 0)
      love.graphics.line(v.p.x,
			 v.p.y,
			 v.p.x + v.normal.x * 10,
			 v.p.y + v.normal.y * 10)
      
      love.graphics.setColor(0, 0, 255)
      love.graphics.line(self.p.x,
			 self.p.y,
			 self.p.x + d.x,
			 self.p.y + d.y)

      love.graphics.setColor(0, 255, 0)
      love.graphics.line(self.p.x,
			 self.p.y,
			 self.p.x + w.x,
			 self.p.y + w.y)


      love.graphics.setColor(255, 255, 255)
   end
   
end

function Terrain.collide(self, position, velocity, halfwidth)
   local p = position + velocity
   local hw = halfwidth

   local a = Vector.floor((p - hw) / tileSize) + 1
   local b = Vector.floor((p + hw) / tileSize) + 1

   for y = a.y, b.y do
      for x = a.x, b.x do
	 local tile = self.data[y][x]
	 tile.outline = true

	 if tile.vertices then
	    local thw = Vector.new(0.5 * tileSize, 0.5 * tileSize)
	    local tp = (Vector.new(x, y) - 1) * tileSize + (0.5 * tileSize)

	    local dp = p - tp
	    local dw = hw + thw
	    local dd = dw - Vector.abs(dp)
	    if dd.x > 0 and dd.y > 0 then
	       if dd.x < dd.y then
		  if dp.x > 0 then
		     p.x = p.x + dd.x
		  else
		     p.x = p.x - dd.x
		  end
	       else
		  if dp.y > 0 then
		     p.y = p.y + dd.y
		  else
		     p.y = p.y - dd.y
		  end
	       end
	    end
	 end
      end
   end

   return p
end

function Terrain.collideHorizontal(self, position, halfwidth)
   local p = position
   local hw = halfwidth

   terrain.p = p
   terrain.hw = hw
   
   local a = Vector.floor((player.p - player.hw) / tileSize) + 1
   local b = Vector.floor((player.p + player.hw) / tileSize) + 1
   
   for y = a.y, b.y do
      for x = a.x, b.x do
	 local tile = self.data[y][x]
	 tile.outline = true

	 if tile.type == "solid" then
	    local thw = 0.5 * tileSize
	    local tpx = (x - 1) * tileSize + thw
	    local dx = hw.x + thw - math.abs(p.x - tpx)
	    dx = dx * (p.x - tpx) / math.abs(p.x - tpx)
	    p.x = p.x + dx
	 end
      end
   end

   return p
end

function Terrain.collideVertical(self, position, halfwidth)
   local p = position
   local hw = halfwidth

   local a = Vector.floor((player.p - player.hw) / tileSize) + 1
   local b = Vector.floor((player.p + player.hw) / tileSize) + 1
   
   for y = a.y, b.y do
      for x = a.x, b.x do
	 local tile = self.data[y][x]
	 tile.outline = true

	 if tile.type == "solid" then
	    local thw = 0.5 * tileSize
	    local tpy = (y - 1) * tileSize + thw
	    local dy = hw.y + thw - math.abs(p.y - tpy)
	    dy = dy * (p.y - tpy) / math.abs(p.y - tpy)
	    p.y = p.y + dy
	 end
      end
   end

   return p
end

Terrain.distanceToFloor = function(self, x, y)
   local index = {
      x = math.floor(x / tileSize),
      y = math.floor(y / tileSize),
   }

   local tile = {
      x = x - index.x * tileSize,
      y = y - index.y * tileSize,
   }

   if index.x > self.data.w or index.y > self.data.h then return true end
   
   local left = self.data[index.y][index.x][1]
   local right = self.data[index.y][index.x][2]
   
   local val = left + (left - right) * tile.x / tileSize
   local result = tile.y < tileSize * math.floor(val)
   return false
end

Terrain.collide = function(self, position, halfwidth)
   local p = position
   local hw = halfwidth

   self.p = position
   self.hw = halfwidth
   
   local result = vector()
   for k, v in ipairs(self.lines) do
      -- x axis
      local dx = math.abs(p.x - v.p.x)
      local wx = hw.x + v.hw.x
      if dx < wx then
	 -- y axis
	 local dy = math.abs(p.y - v.p.y)
	 local wy = hw.y + v.hw.y
	 if dy < wy then
	    -- angle axis
	    local da = vector.len((v.p - p):projectOn(v.normal))
	    local wa = vector.len((hw):projectOn(vector.abs(v.normal)))
	    if da < wa then
	       -- this line intersects the rectangle
	       v.color = true
	       result = result + v.normal * (wa - da)
	    end
	 end
      end
   end
   return result
end

return Terrain
