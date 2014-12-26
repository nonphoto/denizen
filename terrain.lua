require("vector")
require("util")

local Terrain = {}

function t0()
   local result = {}
   result.type = "empty"
   result.vertices = false
   return result
end

function t1()
   local result = {}
   result.type = "solid"
   result.vertices = {0, 0, 1, 0, 1, 1, 0, 1}
   return result
end

function t2()
   local result = {}
   result.type = "partial"
   result.vertices = {0, 0, 1, 1, 0, 1}
   return result
end

function t3()
   local result = {}
   result.type = "partial"
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
   {t1(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t1()},
   {t1(), t2(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t0(), t3(), t1()},
   {t1(), t1(), t1(), t1(), t1(), t1(), t1(), t1(), t1(), t1(), t1(), t1(), t1()},
}

Terrain.data.w = #Terrain.data[1]
Terrain.data.h = #Terrain.data

Terrain.draw = function(self)

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

function Terrain.collide(self, position, velocity, halfwidth)
   local p = position + velocity
   local hw = halfwidth

   local a = Vector.new()
   local b = Vector.new()

   local xstep = 0
   local ystep = 0
   
   if velocity.x > 0 then
      a.x = p.x - hw.x
      b.x = p.x + hw.x
      xstep = 1
   else
      a.x = p.x + hw.x
      b.x = p.x - hw.x
      xstep = -1
   end

   if velocity.y > 0 then
      a.y = p.y - hw.y
      b.y = p.y + hw.y
      ystep = 1
   else
      a.y = p.y + hw.y
      b.y = p.y - hw.y
      ystep = -1
   end

   a = Vector.floor(a / tileSize) + 1
   b = Vector.floor(b / tileSize) + 1
   
   -- local a = Vector.floor((p - hw) / tileSize) + 1
   -- local b = Vector.floor((p + hw) / tileSize) + 1

   for y = a.y, b.y, ystep do
      for x = a.x, b.x, xstep do
	 local tile = self.data[y][x]
	 tile.outline = true

	 print(x..", "..y)
	 
	 if tile.type == "solid" then
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

   return p - position
end

function Terrain.collideHorizontal(self, position, halfwidth)
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
return Terrain
