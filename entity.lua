require("vector")

entity = {}
entity.p = vector(200, 200)
entity.pp = vector(entity.p.x, entity.p.y)
entity.w = vector(50, 100)
entity.hw = entity.w / 2
entity.v = vector()
entity.a = vector()
entity.cs = "none"

entity.update = function(self)
   local collideState, wallid, projection = terrain:collide(self.p, self.hw, false)
   if collideState == "none" then
      self.cs = "none"
   elseif collideState == "intersecting" then
      self.cs = "intersecting"
   elseif collideState == "projected" then
      if self.cs ~= "intersecting" then
	 self.p = self.p + projection
	 self.cs = "projected"
      end
   end

   local v = self.p - self.pp
   self.pp.x = self.p.x
   self.pp.y = self.p.y
   self.p = self.p + (v * 0.9)
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
      self.p = self.p + x
   else
      self.p.x = self.p.x + (x or 0)
      self.p.y = self.p.y + (y or 0)
   end
end

return entity
