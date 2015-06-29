require("vector")

entity = {}
entity.p = vector()
entity.pp = vector(entity.p.x, entity.p.y)
entity.w = vector(50, 100)
entity.hw = entity.w / 2
entity.v = vector()
entity.a = vector()
entity.cj = false
entity.iw = {}

function entity:update()

   -- Test for a collision with the terrain and project out of it if necessary
   local projection, intersections = terrain:collide(self.p, self.hw, self.iw)
   self.p = self.p + projection
   self.iw = intersections

   -- BUG: entity passes through convex corners
   -- possible fix: make it so some walls are solid on both sides
   
   -- Only allow jumping when the entity was projected out of a wall
   -- There might be a corner case here for multiple projections
   if projection:normalize().y < -0.5 then
      self.cj = true
   else
      self.cj = false
   end
   
   -- Verlet integration: entities keep their momentum
   local v = self.p - self.pp
   self.pp.x = self.p.x
   self.pp.y = self.p.y

   -- Friction
   if self.cj then
      self.p = self.p + (v * 0.9)
   else
      self.p = self.p + (v * 0.99)
   end
   
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
   if self.cj then
      -- TODO: function to change velocity
      self.pp.y = self.pp.y + 15
      self.cj = false
   end
end

function entity:move(x, y)
   local c = 0.2
   if self.cj then
      c = 1
   end
   if type(x) == "table" then
      self.p = self.p + c * x
   else
      self.p.x = self.p.x + c * (x or 0)
      self.p.y = self.p.y + c * (y or 0)
   end
end

function entity:reset()
   self.p = vector()
   self.pp = vector()
end

player = entity
