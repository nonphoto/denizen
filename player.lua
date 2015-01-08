require("vector")

local epsilon = 0.0001

entity = {}
entity.p = vector(tileSize * 2, tileSize * 2)
entity.w = vector(tileSize * 0.6, tileSize * 1.2)
entity.hw = entity.w / 2
entity.v = vector()
entity.a = vector()

entity.update = function(self)
   if false then
      self.v.y = self.v.y + 1
      if self.v:len() > tileSize / 2 then
	 self.v = self.v:normalize()
	 self.v = self.v * tileSize / 2
      end

   
      if self.v.y < 0 then
	 self:resolveUp(terrain)
      elseif self.v.y > 0 then
	 self:resolveDown(terrain)
      end
   
      if self.v.x < 0 then
	 self:resolveLeft(terrain)
      elseif self.v.x > 0 then
	 self:resolveRight(terrain)
      end
   
      self.v = self.v * 0.8
   end
   
   self.p = self.p + self.v
   self.p = self.p + terrain:collide(self.p, self.hw)
   self.v = self.v * 0.8
end

entity.draw = function(self)
   love.graphics.setColor(255, 255, 255, 100)
   love.graphics.rectangle("fill",
			   self.p.x - self.hw.x,
			   self.p.y - self.hw.y,
			   self.w.x,
			   self.w.y)
end

entity.move = function(self, x, y)
   if type(x) == "table" then
      self.v = self.v + x
   else
      self.v.x = self.v.x + (x or 0)
      self.v.y = self.v.y + (y or 0)
   end
end

entity.resolveUp = function(self, terrain)
   local result = self.p.y + self.v.y
   local p = vector(self.p.x, result)
   local a = vector.floor((p - self.hw) / tileSize) + 1
   local b = vector.floor((p + self.hw) / tileSize) + 1
   
   for y = a.y, b.y do
      for x = a.x, b.x do

	 local tile = terrain.data[y][x]
	 tile.outline = true
	 if tile.edges.down == "solid" then
	    local tileEdge = y * tileSize
	    local selfEdge = result - self.hw.y
	    if tileEdge > selfEdge then
	       self.v.y = 0
	       result = tileEdge + self.hw.y + 0.0001
	    end
	 end
      end
   end
   self.p.y = result
end

entity.resolveDown = function(self, terrain)
   local result = self.p.y + self.v.y
   local p = vector(self.p.x, result)
   local a = vector.floor((p - self.hw) / tileSize) + 1
   local b = vector.floor((p + self.hw) / tileSize) + 1
   
   for y = a.y, b.y do
      for x = a.x, b.x do
	 local tile = terrain.data[y][x]
	 tile.outline = true
	 if tile.edges.up == "solid" then
	    local tileEdge = (y - 1) * tileSize
	    local selfEdge = result + self.hw.y
	    if tileEdge < selfEdge then
	       self.v.y = 0
	       result = tileEdge - self.hw.y - 0.0001
	    end
	 end
      end
   end
   self.p.y = result
end

entity.resolveLeft = function(self, terrain)
   local result = self.p.x + self.v.x
   local p = vector(result, self.p.y)
   local a = vector.floor((p - self.hw) / tileSize) + 1
   local b = vector.floor((p + self.hw) / tileSize) + 1
   
   for y = a.y, b.y do
      for x = a.x, b.x do
	 local tile = terrain.data[y][x]
	 tile.outline = true
	 if tile.edges.right == "solid" then
	    local tileEdge = x * tileSize
	    local selfEdge = result - self.hw.x
	    if tileEdge > selfEdge then
	       self.v.x = 0
	       result = tileEdge + self.hw.x + 0.0001
	    end
	 end
	 
	 tile.outline = true
      end
   end
   self.p.x = result
end

entity.resolveRight = function(self, terrain)
   local result = self.p + vector(self.v.x, 0)
   local a = vector.floor((result - self.hw) / tileSize) + 1
   local b = vector.floor((result + self.hw) / tileSize) + 1
   
   for y = a.y, b.y do
      for x = a.x, b.x do
	 local tile = terrain.data[y][x]
	 
	 if tile.edges.left == "solid" then
	    local tileEdge = (x - 1) * tileSize
	    local selfEdge = self.p.x + self.hw.x
	    local resultEdge = result.x + self.hw.x
	    
	    if selfEdge < tileEdge and tileEdge < resultEdge then
	       self.v.x = 0
	       result.x = tileEdge - self.hw.x - epsilon
	    end
	    
	 elseif tile.edges.left == "partial" then
	    local tileEdge = (x - 1) * tileSize
	    local resultEdge = result.x + self.hw.x
	    local tileX = resultEdge - tileEdge
	    local tileY = tile.height(tileX) + (y - 1) * tileSize
	    if result.y + self.hw.y > tileY then
	       result.y = tileY - self.hw.y - epsilon
	    end
	 end
	 
	 tile.outline = true 
      end
   end

   self.p = result
end

if false then
   
   if tile.edges.left ~= "empty" then
      local tileEdge = (x - 1) * tileSize
      local selfEdge = self.p.x + self.hw.x
      local resultEdge = result.x + self.hw.x
	    
      if selfEdge < tileEdge and tileEdge < resultEdge then
	 if tile.edges.left == "solid" then
	    self.v.x = 0
	    result.x = tileEdge - self.hw.x - epsilon
	 else
	    local edgeHeight = (tile.height(0) + (y - 1)) * tileSize
	    if result.y + self.hw.y > edgeHeight then
	       self.v.x = 0
	       result.x = tileEdge - self.hw.x - epsilon
	    end
	 end

      elseif tile.edges.left == "partial" then
	 local ratio = (resultEdge - tileEdge) / tileSize
	 local edgeHeight = (tile.height(ratio) + (y - 1)) * tileSize
	 if result.y + self.hw.y > edgeHeight then
	    result.y = edgeHeight - self.hw.y - epsilon
	 end
      end
   end

end


return entity
