Player = {
   x = tileSize * 2,
   y = tileSize * 2,
   w = tileSize,
   h = tileSize * 1.5,
   vx = 0,
   vy = 0
}

Player.update = function(self)
   self.vy = self.vy + 1
   self.y = self.y + self.vy
end

Player.draw = function(self)
   love.graphics.setColor(255, 255, 255)
   love.graphics.rectangle("fill",
			   self.x - (self.w / 2),
			   self.y - self.h,
			   self.w,
			   self.h)
end

return Player
