require("vector")

entity = {}
entity.p = vector()
entity.pp = vector(entity.p.x, entity.p.y)
entity.w = vector(50, 100)
entity.hw = entity.w / 2
entity.v = vector()
entity.a = vector()
entity.cs = "none"
entity.canJump = false

function entity:update()
   -- Test for a collision with the terrain and project out of it if necessary
   local collideState, wall, projection = terrain:collide(self.p, self.hw)
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

   if self.cs == "projected" and projection:normalize().y < -0.5 then
      self.canJump = true
   end
   
   -- Verlet integration: entities keep their momentum
   local v = self.p - self.pp
   self.pp.x = self.p.x
   self.pp.y = self.p.y

   -- Friction
   self.p = self.p + (v * 0.9)

   -- Gravity
   if gravity then
      self.p.y = self.p.y + 1
   end
end

function entity:draw()
   love.graphics.setColor(255, 255, 255, 100)
   love.graphics.rectangle("fill",
			   self.p.x - self.hw.x,
			   self.p.y - self.hw.y,
			   self.w.x,
			   self.w.y)
end

function entity:jump()
   if self.canJump then
      self.pp.y = self.pp.y + 10
      self.canJump = false
   end
end

function entity:move(x, y)
   if type(x) == "table" then
      self.p = self.p + x
   else
      self.p.x = self.p.x + (x or 0)
      self.p.y = self.p.y + (y or 0)
   end
end

function entity:reset()
   self.p = vector()
   self.pp = vector()
end

return entity
