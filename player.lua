require("vector")

Player = {}
Player.p = Vector.new(tileSize * 2, tileSize * 2)
Player.w = Vector.new(tileSize * 0.6, tileSize * 1.2)
Player.hw = Player.w / 2
Player.v = Vector.new()
Player.a = Vector.new()

Player.update = function(self)
      -- self.v.y = self.v.y + 1
   if self.v:len() > tileSize / 2 then
      self.v = self.v:normalize()
      self.v = self.v * tileSize / 2
   end
   
   local p = terrain:collide(self.p, self.v, self.hw)
   self.p = self.p + p

   if false then
      if p.x ~= 0 then
	 self.v.x = 0
      end
      if p.y ~= 0 then
	 self.v.y = 0
      end
   end

   self.v = self.v * 0.9
end

Player.draw = function(self)
   love.graphics.setColor(255, 255, 255)
   love.graphics.rectangle("fill",
			   self.p.x - self.hw.x,
			   self.p.y - self.hw.y,
			   self.w.x,
			   self.w.y)
end

Player.move = function(self, x, y)
   if type(x) == "table" then
      self.v = self.v + x
   else
      self.v.x = self.v.x + (x or 0)
      self.v.y = self.v.y + (y or 0)
   end
end

return Player
